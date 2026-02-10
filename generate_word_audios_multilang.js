#!/usr/bin/env node
// Generates word audio for selected languages from assets/words/*.json
// using ElevenLabs and updates audios.<lang> in the same JSON files.
//
// Current schema:
// {
//   "words": { "de": "...", "fr": "...", ... },
//   "audios": { "de": "https://...", "fr": "https://...", ... }
// }

require("dotenv").config();
const fs = require("fs");
const path = require("path");
const fetch = require("node-fetch");

const SUPPORTED_LANGS = new Set(["de", "en", "fa", "ps", "fr", "tr"]);

function parseArgs(argv) {
  const out = {
    langs: [],
    dir: path.join(__dirname, "assets", "words"),
    file: "",
    outDir: path.join(__dirname, "generated_audio", "words"),
    baseUrl: "",
    limit: 0,
    regenerate: false,
    dryRun: false,
    delayMs: 0,
    modelId: process.env.ELEVENLABS_MODEL_ID || "eleven_multilingual_v2",
    updateJson: true,
  };

  for (let i = 2; i < argv.length; i++) {
    const arg = argv[i];
    const next = argv[i + 1];

    if (arg === "--langs" && next) {
      out.langs = next
        .split(",")
        .map((s) => s.trim().toLowerCase())
        .filter(Boolean);
      i++;
      continue;
    }
    if (arg === "--dir" && next) {
      out.dir = path.isAbsolute(next) ? next : path.join(__dirname, next);
      i++;
      continue;
    }
    if (arg === "--file" && next) {
      out.file = String(next).trim();
      i++;
      continue;
    }
    if (arg === "--out" && next) {
      out.outDir = path.isAbsolute(next) ? next : path.join(__dirname, next);
      i++;
      continue;
    }
    if (arg === "--base-url" && next) {
      out.baseUrl = String(next).trim();
      i++;
      continue;
    }
    if (arg === "--limit" && next) {
      out.limit = Number(next) || 0;
      i++;
      continue;
    }
    if (arg === "--delay-ms" && next) {
      out.delayMs = Number(next) || 0;
      i++;
      continue;
    }
    if (arg === "--model" && next) {
      out.modelId = String(next).trim();
      i++;
      continue;
    }
    if (arg === "--regenerate") {
      out.regenerate = true;
      continue;
    }
    if (arg === "--dry-run") {
      out.dryRun = true;
      continue;
    }
    if (arg === "--no-json-update") {
      out.updateJson = false;
      continue;
    }
    if (arg === "--help" || arg === "-h") {
      printUsage();
      process.exit(0);
    }
  }

  return out;
}

function printUsage() {
  console.log(`
Usage:
  node generate_word_audios_multilang.js --langs fr[,tr,...] [options]

Options:
  --langs <list>       Required. Comma-separated language codes.
  --dir <path>         Words JSON directory. Default: assets/words
  --file <name|path>   Process only one JSON file (e.g. a1_1.json).
  --out <path>         Output audio directory. Default: generated_audio/words
  --base-url <url>     Public base URL for generated files (optional).
                       If set, audios.<lang> is updated to this URL.
  --limit <n>          Max number of new audios to generate (0 = unlimited).
  --regenerate         Regenerate even when audios.<lang> already exists.
  --delay-ms <n>       Delay between requests in milliseconds.
  --model <id>         ElevenLabs model id.
  --dry-run            Print what would be generated without calling API.
  --no-json-update     Do not modify JSON files.
  -h, --help           Show help.

Env:
  ELEVENLABS_API_KEY                Required
  ELEVENLABS_VOICE_ID               Fallback voice id
  ELEVENLABS_VOICE_ID_<LANG>        Optional per-language voice id
  ELEVENLABS_MODEL_ID               Optional model id
  `);
}

function ensureDir(dir) {
  if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });
}

function sanitizePart(value) {
  return String(value || "")
    .toLowerCase()
    .replace(/[^a-z0-9._-]+/g, "_")
    .replace(/_+/g, "_")
    .replace(/^_+|_+$/g, "");
}

function levelToFolder(level) {
  const raw = String(level || "").toUpperCase();
  if (raw.startsWith("A1")) return "A1";
  if (raw.startsWith("A2")) return "A2";
  if (raw.startsWith("B1")) return "B1";
  if (raw.startsWith("B2")) return "B2";
  return "misc";
}

function getVoiceForLang(langCode) {
  const specific = process.env[`ELEVENLABS_VOICE_ID_${langCode.toUpperCase()}`];
  if (specific && specific.trim()) return specific.trim();

  const fallback = process.env.ELEVENLABS_VOICE_ID;
  if (fallback && fallback.trim()) return fallback.trim();

  return "";
}

async function generateAudioBufferElevenLabs({ apiKey, voiceId, modelId, text }) {
  const url =
    `https://api.elevenlabs.io/v1/text-to-speech/${voiceId}` +
    "?optimize_streaming_latency=0";

  const body = {
    text,
    model_id: modelId,
    voice_settings: {
      stability: 0.4,
      similarity_boost: 0.7,
    },
  };

  const response = await fetch(url, {
    method: "POST",
    headers: {
      "xi-api-key": apiKey,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(body),
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(
      `ElevenLabs error (${response.status}): ${errorText.slice(0, 300)}`
    );
  }

  return response.buffer();
}

function normalizeAudiosObject(item) {
  const out = {};
  if (item.audios && typeof item.audios === "object") {
    for (const [k, v] of Object.entries(item.audios)) {
      const code = String(k || "").trim().toLowerCase();
      const url = String(v || "").trim();
      if (code && url) out[code] = url;
    }
  }
  item.audios = out;
  return out;
}

function getWordForLanguage(item, langCode) {
  const words = item.words && typeof item.words === "object" ? item.words : null;
  if (!words) return "";
  return String(words[langCode] || "").trim();
}

function buildPublicUrl(baseUrl, langCode, levelFolder, fileName) {
  const root = String(baseUrl || "").trim().replace(/\/+$/, "");
  if (!root) return "";
  return `${root}/${langCode}/${levelFolder}/${fileName}`;
}

function sleep(ms) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

async function main() {
  const args = parseArgs(process.argv);
  const apiKey = process.env.ELEVENLABS_API_KEY || "";

  if (!args.langs.length) {
    console.error("Missing --langs. Example: --langs fr");
    process.exit(1);
  }
  for (const lang of args.langs) {
    if (!SUPPORTED_LANGS.has(lang)) {
      console.error(`Unsupported language code: ${lang}`);
      process.exit(1);
    }
  }

  if (!args.dryRun && !apiKey) {
    console.error("Missing ELEVENLABS_API_KEY in environment.");
    process.exit(1);
  }

  if (!fs.existsSync(args.dir)) {
    console.error(`Words dir not found: ${args.dir}`);
    process.exit(1);
  }

  ensureDir(args.outDir);
  let files = fs.readdirSync(args.dir).filter((f) => f.endsWith(".json")).sort();
  if (args.file) {
    const wanted = path.basename(args.file);
    files = files.filter((f) => f === wanted);
    if (!files.length) {
      console.error(`Target file not found in dir: ${wanted}`);
      process.exit(1);
    }
  }
  if (!files.length) {
    console.log("No JSON files found.");
    return;
  }

  let generated = 0;
  let skipped = 0;
  let failed = 0;
  let changedFiles = 0;
  const failures = [];

  console.log(`Languages: ${args.langs.join(", ")}`);
  console.log(`Input dir: ${args.dir}`);
  console.log(`Output dir: ${args.outDir}`);
  console.log(`JSON updates: ${args.updateJson ? "on" : "off"}`);
  console.log(`Eleven model: ${args.modelId}`);
  if (args.baseUrl) console.log(`Base URL: ${args.baseUrl}`);
  if (args.dryRun) console.log("Mode: dry-run");

  outer: for (const file of files) {
    const filePath = path.join(args.dir, file);
    let data;
    try {
      data = JSON.parse(fs.readFileSync(filePath, "utf8"));
    } catch (_) {
      console.error(`Invalid JSON: ${file}`);
      failed++;
      continue;
    }
    if (!Array.isArray(data)) continue;

    let fileChanged = false;

    for (const item of data) {
      if (!item || typeof item !== "object") {
        skipped++;
        continue;
      }

      const idRaw = String(item.id || "").trim();
      const itemId = sanitizePart(idRaw || "word");
      const levelFolder = levelToFolder(item.level);
      const audios = normalizeAudiosObject(item);

      for (const langCode of args.langs) {
        const text = getWordForLanguage(item, langCode);
        if (!text) {
          skipped++;
          continue;
        }

        const existing = String(audios[langCode] || "").trim();
        if (existing && !args.regenerate) {
          skipped++;
          continue;
        }

        const voiceId = getVoiceForLang(langCode);
        if (!voiceId) {
          failed++;
          failures.push({
            file,
            id: idRaw,
            lang: langCode,
            reason: `Missing ELEVENLABS_VOICE_ID_${langCode.toUpperCase()} or ELEVENLABS_VOICE_ID`,
          });
          continue;
        }

        const outDirLang = path.join(args.outDir, langCode, levelFolder);
        ensureDir(outDirLang);
        const fileName = `${itemId}_${langCode}.mp3`;
        const outPath = path.join(outDirLang, fileName);

        console.log(`[${file}] ${idRaw} [${langCode}] -> ${outPath} (voice=${voiceId})`);

        try {
          if (!args.dryRun) {
            const buffer = await generateAudioBufferElevenLabs({
              apiKey,
              voiceId,
              modelId: args.modelId,
              text,
            });
            fs.writeFileSync(outPath, buffer);
          }

          if (args.updateJson) {
            const publicUrl = buildPublicUrl(args.baseUrl, langCode, levelFolder, fileName);
            if (publicUrl) {
              item.audios[langCode] = publicUrl;
            } else {
              item.audios[langCode] =
                `generated_audio/words/${langCode}/${levelFolder}/${fileName}`;
            }
            fileChanged = true;
          }

          generated++;
          if (args.limit > 0 && generated >= args.limit) {
            if (args.updateJson && fileChanged && !args.dryRun) {
              fs.writeFileSync(filePath, `${JSON.stringify(data, null, 2)}\n`, "utf8");
              changedFiles++;
            }
            break outer;
          }

          if (args.delayMs > 0) await sleep(args.delayMs);
        } catch (e) {
          failed++;
          failures.push({
            file,
            id: idRaw,
            lang: langCode,
            reason: e.message,
          });
        }
      }
    }

    if (args.updateJson && fileChanged && !args.dryRun) {
      fs.writeFileSync(filePath, `${JSON.stringify(data, null, 2)}\n`, "utf8");
      changedFiles++;
    }
  }

  console.log("\nDone.");
  console.log(`Generated: ${generated}`);
  console.log(`Skipped:   ${skipped}`);
  console.log(`Failed:    ${failed}`);
  console.log(`Files changed: ${changedFiles}`);

  if (failures.length) {
    console.log("\nFailures (first 20):");
    for (const row of failures.slice(0, 20)) {
      console.log(`- [${row.file}] id=${row.id} lang=${row.lang} :: ${row.reason}`);
    }
  }
}

main().catch((e) => {
  console.error("Fatal:", e);
  process.exit(1);
});
