#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import json
import os
import time
from typing import Dict, Any, List, Optional, Tuple

DEFAULT_API_KEY_FILE = os.path.join('.secrets', 'openai_api_key.txt')
DEFAULT_CACHE_FILE = 'fr_tr_cache.json'


def load_json(path: str):
    with open(path, 'r', encoding='utf-8') as f:
        return json.load(f)


def save_json(path: str, data: Any):
    with open(path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write('\n')


def read_secret(path: str) -> Optional[str]:
    if not path or not os.path.exists(path):
        return None
    with open(path, 'r', encoding='utf-8') as f:
        for raw in f.read().splitlines():
            line = raw.strip()
            if not line or line.startswith('#'):
                continue
            if '=' in line:
                k, v = line.split('=', 1)
                if k.strip() == 'OPENAI_API_KEY' and v.strip():
                    return v.strip().strip('"').strip("'")
            return line.strip().strip('"').strip("'")
    return None


def resolve_api_key(api_key_file: Optional[str]) -> str:
    env_key = os.environ.get('OPENAI_API_KEY', '').strip()
    if env_key:
        return env_key
    for p in [api_key_file, DEFAULT_API_KEY_FILE]:
        if not p:
            continue
        secret = read_secret(p)
        if secret:
            return secret
    raise RuntimeError('OPENAI_API_KEY not found (env or .secrets/openai_api_key.txt)')


def call_openai_chat(*, api_key: str, model: str, messages: List[Dict[str, str]], temperature: float, timeout_sec: float, retries: int, retry_backoff_sec: float) -> str:
    import urllib.request

    payload = {
        'model': model,
        'messages': messages,
        'temperature': temperature,
    }

    req = urllib.request.Request(
        'https://api.openai.com/v1/chat/completions',
        data=json.dumps(payload).encode('utf-8'),
        headers={
            'Authorization': f'Bearer {api_key}',
            'Content-Type': 'application/json',
        },
    )

    attempt = 0
    while True:
        try:
            with urllib.request.urlopen(req, timeout=timeout_sec) as r:
                res = json.loads(r.read().decode('utf-8'))
            return res['choices'][0]['message']['content']
        except Exception:
            attempt += 1
            if attempt > retries:
                raise
            time.sleep(retry_backoff_sec * attempt)


def extract_json_array(payload: str) -> str:
    s = (payload or '').strip()
    if s.startswith('[') and s.endswith(']'):
        return s
    i = s.find('[')
    j = s.rfind(']')
    if i != -1 and j != -1 and j > i:
        return s[i:j + 1]
    raise ValueError('No JSON array found in model response')


def translate_batch(*, api_key: str, model: str, rows: List[Dict[str, str]], timeout_sec: float, retries: int, retry_backoff_sec: float) -> Dict[str, Dict[str, str]]:
    content = call_openai_chat(
        api_key=api_key,
        model=model,
        messages=[
            {
                'role': 'system',
                'content': (
                    'You are a professional translator. '\
                    'Return ONLY valid JSON (no markdown). '\
                    'Input is an array of {key,de,en,fa,ps}. '\
                    'Output must be an array of {key,fr,tr}. '\
                    'French must be natural and concise. '\
                    'Turkish must be natural and concise. '\
                    'If a term is a proper noun/brand/code, keep it unchanged. '
                )
            },
            {
                'role': 'user',
                'content': json.dumps(rows, ensure_ascii=False),
            }
        ],
        temperature=0.2,
        timeout_sec=timeout_sec,
        retries=retries,
        retry_backoff_sec=retry_backoff_sec,
    )

    arr_text = extract_json_array(content)
    arr = json.loads(arr_text)
    out: Dict[str, Dict[str, str]] = {}
    if isinstance(arr, list):
        for row in arr:
            if not isinstance(row, dict):
                continue
            key = str(row.get('key', '')).strip()
            fr = str(row.get('fr', '')).strip().strip('"').strip("'")
            tr = str(row.get('tr', '')).strip().strip('"').strip("'")
            if key:
                out[key] = {'fr': fr, 'tr': tr}
    return out


def build_cache_key(item: Dict[str, Any]) -> str:
    words = item.get('words') if isinstance(item.get('words'), dict) else {}
    de = str(words.get('de', '')).strip()
    en = str(words.get('en', '')).strip()
    fa = str(words.get('fa', '')).strip()
    ps = str(words.get('ps', '')).strip()
    return f"{item.get('id','')}|{de}|{en}|{fa}|{ps}"


def load_cache(path: str) -> Dict[str, Dict[str, str]]:
    if not os.path.exists(path):
        return {}
    try:
        data = load_json(path)
    except Exception:
        return {}
    if not isinstance(data, dict):
        return {}
    out: Dict[str, Dict[str, str]] = {}
    for k, v in data.items():
        if isinstance(v, dict):
            out[str(k)] = {
                'fr': str(v.get('fr', '')).strip(),
                'tr': str(v.get('tr', '')).strip(),
            }
    return out


def save_cache(path: str, cache: Dict[str, Dict[str, str]]):
    save_json(path, cache)


def ensure_words_obj(item: Dict[str, Any]) -> Dict[str, str]:
    words = item.get('words')
    if not isinstance(words, dict):
        words = {}
        item['words'] = words
    out: Dict[str, str] = {}
    for k, v in words.items():
        out[str(k).strip().lower()] = str(v or '').strip()
    item['words'] = out
    return out


def process_file(*, path: str, api_key: str, model: str, cache: Dict[str, Dict[str, str]], cache_path: str, batch_size: int, timeout_sec: float, retries: int, retry_backoff_sec: float, max_items_left: int, sleep_sec: float) -> Tuple[int, int, int]:
    data = load_json(path)
    if not isinstance(data, list):
        return 0, 0, 0

    changed = 0
    skipped = 0
    translated = 0

    pending: List[Tuple[Dict[str, Any], str, Dict[str, str]]] = []

    for item in data:
        if not isinstance(item, dict):
            skipped += 1
            continue

        words = ensure_words_obj(item)
        de = words.get('de', '').strip()
        en = words.get('en', '').strip()
        if not de:
            skipped += 1
            continue

        fr_now = words.get('fr', '').strip()
        tr_now = words.get('tr', '').strip()
        if fr_now and tr_now:
            skipped += 1
            continue

        key = build_cache_key(item)
        cached = cache.get(key)
        if cached:
            fr_cached = cached.get('fr', '').strip()
            tr_cached = cached.get('tr', '').strip()
            if fr_cached and not fr_now:
                words['fr'] = fr_cached
                changed += 1
            if tr_cached and not tr_now:
                words['tr'] = tr_cached
                changed += 1
            if words.get('fr', '').strip() and words.get('tr', '').strip():
                continue

        if not en:
            # without EN context we still try, but keep this item in batch with available context
            pass

        pending.append((item, key, words))

    if max_items_left == 0:
        max_items_left = 1_000_000_000

    i = 0
    while i < len(pending) and max_items_left > 0:
        chunk = pending[i:i + max(1, batch_size)]
        chunk = chunk[:max_items_left]
        i += len(chunk)
        max_items_left -= len(chunk)

        rows = []
        for item, key, words in chunk:
            rows.append({
                'key': key,
                'de': words.get('de', ''),
                'en': words.get('en', ''),
                'fa': words.get('fa', ''),
                'ps': words.get('ps', ''),
            })

        results: Dict[str, Dict[str, str]] = {}
        try:
            results = translate_batch(
                api_key=api_key,
                model=model,
                rows=rows,
                timeout_sec=timeout_sec,
                retries=retries,
                retry_backoff_sec=retry_backoff_sec,
            )
        except Exception:
            results = {}

        for item, key, words in chunk:
            pair = results.get(key, {})
            fr_new = str(pair.get('fr', '')).strip()
            tr_new = str(pair.get('tr', '')).strip()

            if not fr_new or not tr_new:
                # single fallback for reliability
                try:
                    one = translate_batch(
                        api_key=api_key,
                        model=model,
                        rows=[{
                            'key': key,
                            'de': words.get('de', ''),
                            'en': words.get('en', ''),
                            'fa': words.get('fa', ''),
                            'ps': words.get('ps', ''),
                        }],
                        timeout_sec=timeout_sec,
                        retries=retries,
                        retry_backoff_sec=retry_backoff_sec,
                    ).get(key, {})
                except Exception:
                    one = {}
                fr_new = fr_new or str(one.get('fr', '')).strip()
                tr_new = tr_new or str(one.get('tr', '')).strip()

            if fr_new and not words.get('fr', '').strip():
                words['fr'] = fr_new
                changed += 1
            if tr_new and not words.get('tr', '').strip():
                words['tr'] = tr_new
                changed += 1

            if fr_new or tr_new:
                cache[key] = {'fr': fr_new, 'tr': tr_new}
                translated += 1

        save_cache(cache_path, cache)
        save_json(path, data)
        if sleep_sec:
            time.sleep(sleep_sec)

    save_json(path, data)
    return changed, skipped, translated


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--dir', required=True, help='Path to assets/words')
    ap.add_argument('--cache', default=DEFAULT_CACHE_FILE)
    ap.add_argument('--api-key-file', default=None)
    ap.add_argument('--model', default=None, help='OpenAI model, defaults to OPENAI_MODEL or gpt-4.1-mini')
    ap.add_argument('--batch-size', type=int, default=15)
    ap.add_argument('--max-items', type=int, default=0, help='0 means no limit')
    ap.add_argument('--timeout', type=float, default=120.0)
    ap.add_argument('--retries', type=int, default=3)
    ap.add_argument('--retry-backoff', type=float, default=1.0)
    ap.add_argument('--sleep', type=float, default=0.05)
    args = ap.parse_args()

    api_key = resolve_api_key(args.api_key_file)
    model = args.model or os.environ.get('OPENAI_MODEL', 'gpt-4.1-mini')
    cache = load_cache(args.cache)

    total_changed = 0
    total_skipped = 0
    total_translated = 0
    max_items_left = args.max_items

    for file_name in sorted(os.listdir(args.dir)):
        if not file_name.endswith('.json'):
            continue
        path = os.path.join(args.dir, file_name)
        c, s, t = process_file(
            path=path,
            api_key=api_key,
            model=model,
            cache=cache,
            cache_path=args.cache,
            batch_size=args.batch_size,
            timeout_sec=args.timeout,
            retries=args.retries,
            retry_backoff_sec=args.retry_backoff,
            max_items_left=max_items_left,
            sleep_sec=args.sleep,
        )
        total_changed += c
        total_skipped += s
        total_translated += t

        if max_items_left:
            max_items_left = max(0, max_items_left - t)
            if max_items_left == 0:
                break

    save_cache(args.cache, cache)
    print(f'Done. changed={total_changed}, skipped={total_skipped}, translated={total_translated}')


if __name__ == '__main__':
    main()
