#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import argparse
import json
import os
import re
import time
from typing import Dict, Any, Optional, Tuple, List


def load_json(path: str):
    with open(path, "r", encoding="utf-8") as f:
        return json.load(f)


def save_json(path: str, data):
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
        f.write("\n")


def load_do_not_translate(path: Optional[str]) -> Dict[str, Any]:
    if not path or not os.path.exists(path):
        return {"exact": [], "prefix": [], "regex": []}
    cfg = load_json(path)
    return {
        "exact": cfg.get("exact", []),
        "prefix": cfg.get("prefix", []),
        "regex": cfg.get("regex", []),
    }


def is_non_translatable(word: str, item: Dict[str, Any], dnt: Dict[str, Any]) -> bool:
    if item.get("dont_translate") is True:
        return True

    w = (word or "").strip()
    if not w:
        return True

    if w in dnt["exact"]:
        return True

    for p in dnt["prefix"]:
        if w.startswith(p):
            return True

    for rgx in dnt["regex"]:
        try:
            if re.search(rgx, w):
                return True
        except re.error:
            pass

    if any(ch.isdigit() for ch in w):
        return True
    if "@" in w or w.startswith("http"):
        return True
    if re.fullmatch(r"[A-ZÄÖÜ]{2,}", w):
        return True

    return False


def load_cache(path: str) -> Dict[str, str]:
    if os.path.exists(path):
        try:
            data = load_json(path)
            if isinstance(data, dict):
                return {str(k): str(v) for k, v in data.items()}
        except Exception:
            pass
    return {}


def save_cache(path: str, cache: Dict[str, str]):
    save_json(path, cache)


def cache_key(item: Dict[str, Any]) -> str:
    return f"{item.get('id','')}|{item.get('word','')}|{item.get('translation_en','')}"


DEFAULT_API_KEY_FILE = os.path.join(".secrets", "openai_api_key.txt")


def _read_first_secret_line(path: str) -> Optional[str]:
    if not path or not os.path.exists(path):
        return None
    with open(path, "r", encoding="utf-8") as f:
        for raw in f.read().splitlines():
            line = raw.strip()
            if not line or line.startswith("#"):
                continue
            if "=" in line:
                k, v = line.split("=", 1)
                if k.strip() == "OPENAI_API_KEY" and v.strip():
                    return v.strip().strip('"').strip("'")
            return line.strip().strip('"').strip("'")
    return None


def resolve_openai_api_key(api_key_file: Optional[str]) -> str:
    api_key = os.environ.get("OPENAI_API_KEY")
    if api_key and api_key.strip():
        return api_key.strip()

    for candidate in [api_key_file, DEFAULT_API_KEY_FILE]:
        secret = _read_first_secret_line(candidate) if candidate else None
        if secret:
            return secret

    raise RuntimeError(
        "OPENAI_API_KEY is not set. Set env var OPENAI_API_KEY or create "
        f"{DEFAULT_API_KEY_FILE} (gitignored) containing the key."
    )


def call_openai_chat(
    *,
    api_key: str,
    model: str,
    messages: List[Dict[str, str]],
    temperature: float,
    timeout_sec: float,
    retries: int,
    retry_backoff_sec: float,
) -> str:
    import urllib.request

    payload = {
        "model": model,
        "messages": messages,
        "temperature": temperature,
    }

    req = urllib.request.Request(
        "https://api.openai.com/v1/chat/completions",
        data=json.dumps(payload).encode("utf-8"),
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
    )

    attempt = 0
    while True:
        try:
            with urllib.request.urlopen(req, timeout=timeout_sec) as r:
                res = json.loads(r.read().decode("utf-8"))
            return res["choices"][0]["message"]["content"]
        except Exception:
            attempt += 1
            if attempt > retries:
                raise
            time.sleep(retry_backoff_sec * attempt)


def translate_to_pashto_single(
    *,
    api_key: str,
    model: str,
    de: str,
    en: str,
    fa: str,
    timeout_sec: float,
    retries: int,
    retry_backoff_sec: float,
) -> str:
    content = call_openai_chat(
        api_key=api_key,
        model=model,
        messages=[
            {
                "role": "system",
                "content": (
                    "You are a professional translator. "
                    "Return ONLY a natural Pashto (ps) translation as plain text. "
                    "If the term should stay in German (proper noun/brand), return it unchanged."
                ),
            },
            {
                "role": "user",
                "content": f"German: {de}\nEnglish: {en}\nPersian: {fa}",
            },
        ],
        temperature=0.2,
        timeout_sec=timeout_sec,
        retries=retries,
        retry_backoff_sec=retry_backoff_sec,
    )
    return content.strip().strip('"').strip("'")


def _extract_json(payload: str) -> Optional[str]:
    s = payload.strip()
    if s.startswith("[") and s.endswith("]"):
        return s
    start = s.find("[")
    end = s.rfind("]")
    if start != -1 and end != -1 and end > start:
        return s[start : end + 1]
    return None


def translate_to_pashto_batch(
    *,
    api_key: str,
    model: str,
    items: List[Dict[str, str]],
    timeout_sec: float,
    retries: int,
    retry_backoff_sec: float,
) -> Dict[str, str]:
    content = call_openai_chat(
        api_key=api_key,
        model=model,
        messages=[
            {
                "role": "system",
                "content": (
                    "You are a professional translator.\n"
                    "Return ONLY valid JSON (no markdown, no extra text).\n"
                    "Input: a JSON array of items, each has {key,de,en,fa}.\n"
                    "Output: a JSON array of objects {key,ps} with a natural Pashto (ps) translation.\n"
                    "If the term should stay in German (proper noun/brand), return it unchanged.\n"
                ),
            },
            {
                "role": "user",
                "content": json.dumps(items, ensure_ascii=False),
            },
        ],
        temperature=0.2,
        timeout_sec=timeout_sec,
        retries=retries,
        retry_backoff_sec=retry_backoff_sec,
    )

    json_text = _extract_json(content) or ""
    data = json.loads(json_text)
    out: Dict[str, str] = {}
    if isinstance(data, list):
        for row in data:
            if not isinstance(row, dict):
                continue
            key = str(row.get("key", "") or "").strip()
            ps = str(row.get("ps", "") or "").strip().strip('"').strip("'")
            if key and ps:
                out[key] = ps
    return out


def process_file(
    path: str,
    dnt: Dict[str, Any],
    cache: Dict[str, str],
    sleep_sec: float,
    cache_path: str,
    api_key: str,
    model: str,
    batch_size: int,
    max_items_left: int,
    timeout_sec: float,
    retries: int,
    retry_backoff_sec: float,
) -> Tuple[int, int, int]:
    data = load_json(path)
    if not isinstance(data, list):
        return 0, 0, 0

    changed = 0
    skipped = 0
    translated = 0

    pending: List[Tuple[Dict[str, Any], str, str, str, str]] = []

    for item in data:
        if not isinstance(item, dict):
            skipped += 1
            continue
        if "translation_en" not in item or "translation_fa" not in item:
            skipped += 1
            continue

        if "translation_ps" in item and str(item["translation_ps"]).strip():
            skipped += 1
            continue

        de = str(item.get("word", "") or "").strip()
        en = str(item.get("translation_en", "") or "").strip()
        fa = str(item.get("translation_fa", "") or "").strip()

        if is_non_translatable(de, item, dnt):
            item["translation_ps"] = de
            changed += 1
            continue

        key = cache_key(item)
        if key in cache:
            item["translation_ps"] = cache[key]
            changed += 1
            continue

        pending.append((item, key, de, en, fa))

    if max_items_left == 0:
        max_items_left = 1_000_000_000

    i = 0
    while i < len(pending) and max_items_left > 0:
        chunk = pending[i : i + max(1, batch_size)]
        chunk = chunk[:max_items_left]
        i += len(chunk)
        max_items_left -= len(chunk)

        request_items = [{"key": key, "de": de, "en": en, "fa": fa} for _, key, de, en, fa in chunk]
        results: Dict[str, str] = {}

        if len(request_items) == 1:
            one = request_items[0]
            results[one["key"]] = translate_to_pashto_single(
                api_key=api_key,
                model=model,
                de=one["de"],
                en=one["en"],
                fa=one["fa"],
                timeout_sec=timeout_sec,
                retries=retries,
                retry_backoff_sec=retry_backoff_sec,
            )
        else:
            try:
                results = translate_to_pashto_batch(
                    api_key=api_key,
                    model=model,
                    items=request_items,
                    timeout_sec=timeout_sec,
                    retries=retries,
                    retry_backoff_sec=retry_backoff_sec,
                )
            except Exception:
                results = {}

        for item, key, de, en, fa in chunk:
            ps = results.get(key, "").strip()
            if not ps:
                ps = translate_to_pashto_single(
                    api_key=api_key,
                    model=model,
                    de=de,
                    en=en,
                    fa=fa,
                    timeout_sec=timeout_sec,
                    retries=retries,
                    retry_backoff_sec=retry_backoff_sec,
                )
            item["translation_ps"] = ps
            cache[key] = ps
            changed += 1
            translated += 1

        save_cache(cache_path, cache)

        if sleep_sec:
            time.sleep(sleep_sec)

    save_json(path, data)
    return changed, skipped, translated


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--dir", required=True, help="Path to assets/words")
    ap.add_argument("--do-not-translate", default=None)
    ap.add_argument("--cache", default="ps_cache.json")
    ap.add_argument("--sleep", type=float, default=0.1)
    ap.add_argument("--api-key-file", default=None, help=f"Defaults to {DEFAULT_API_KEY_FILE} if present")
    ap.add_argument("--model", default=None, help="OpenAI model name (or set OPENAI_MODEL)")
    ap.add_argument("--batch-size", type=int, default=10, help="Number of items per API call (fallbacks to single on errors)")
    ap.add_argument("--max-items", type=int, default=0, help="Max translated items this run (0 = no limit)")
    ap.add_argument("--timeout", type=float, default=120.0, help="HTTP timeout seconds per request")
    ap.add_argument("--retries", type=int, default=3, help="Retry count for transient failures")
    ap.add_argument("--retry-backoff", type=float, default=1.0, help="Retry backoff base seconds")
    args = ap.parse_args()

    api_key = resolve_openai_api_key(args.api_key_file)
    model = args.model or os.environ.get("OPENAI_MODEL", "gpt-4.1-mini")

    dnt = load_do_not_translate(args.do_not_translate)
    cache = load_cache(args.cache)

    total_changed = 0
    total_skipped = 0
    max_items_left = args.max_items

    for root, _, files in os.walk(args.dir):
        for f in files:
            if not f.endswith(".json"):
                continue
            path = os.path.join(root, f)
            c, s, t = process_file(
                path,
                dnt,
                cache,
                args.sleep,
                args.cache,
                api_key,
                model,
                args.batch_size,
                max_items_left,
                args.timeout,
                args.retries,
                args.retry_backoff,
            )
            total_changed += c
            total_skipped += s
            if max_items_left:
                max_items_left = max(0, max_items_left - t)
                if max_items_left == 0:
                    save_cache(args.cache, cache)
                    print(f"Stopped (max-items reached). changed={total_changed}, skipped={total_skipped}")
                    return

    save_cache(args.cache, cache)
    print(f"Done. changed={total_changed}, skipped={total_skipped}")


if __name__ == "__main__":
    main()
