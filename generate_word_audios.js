// generate_word_audios.js
require("dotenv").config();
const fs = require("fs");
const path = require("path");
const fetch = require("node-fetch");

const ELEVEN_API_KEY = process.env.ELEVENLABS_API_KEY;
const VOICE_ID = process.env.ELEVENLABS_VOICE_ID;
const MODEL_ID = process.env.ELEVENLABS_MODEL_ID || "eleven_multilingual_v2";

// پوشه JSONها (همان که الان داری)
const WORDS_DIR = path.join(__dirname, "assets", "words");
// جایی که MP3 ها ذخیره می‌شوند
const AUDIO_BASE_DIR = path.join(__dirname, "assets", "audio");

// اگر بعداً خواستی فقط برای کلمات جدید صدا بسازی:
// REGENERATE_ALL = false بگذار
const REGENERATE_ALL = true;

if (!ELEVEN_API_KEY || !VOICE_ID) {
  console.error(
    "Please set ELEVENLABS_API_KEY and ELEVENLABS_VOICE_ID in .env"
  );
  process.exit(1);
}

function ensureDir(dir) {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
}

async function generateAudioFromElevenLabs(text) {
  const url = `https://api.elevenlabs.io/v1/text-to-speech/${VOICE_ID}?optimize_streaming_latency=0`;

  const body = {
    text,
    model_id: MODEL_ID,
    voice_settings: {
      stability: 0.4,
      similarity_boost: 0.7,
    },
  };

  const response = await fetch(url, {
    method: "POST",
    headers: {
      "xi-api-key": ELEVEN_API_KEY,
      "Content-Type": "application/json",
    },
    body: JSON.stringify(body),
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(
      `ElevenLabs error (${response.status}): ${errorText.substring(0, 200)}`
    );
  }

  const buffer = await response.buffer();
  return buffer;
}

async function processWordItem(item) {
  const word = item.word;

  if (!word || typeof word !== "string") return false;

  // اگر بعداً خواستی فقط کلمات جدید را بسازی:
  // REGENERATE_ALL = false و این بخش فعال می‌شود
  if (!REGENERATE_ALL) {
    if (item.audio && String(item.audio).trim() !== "") {
      return false;
    }
  }

  const category = item.category || "misc"; // مثل A1, A2...
  const id = item.id || "word";

  console.log(`Generating audio for [${id}] "${word}"`);

  try {
    const audioBuffer = await generateAudioFromElevenLabs(word);

    const categoryDir = path.join(AUDIO_BASE_DIR, category);
    ensureDir(categoryDir);

    const fileName = `${id}.mp3`;
    const filePath = path.join(categoryDir, fileName);

    fs.writeFileSync(filePath, audioBuffer);
    console.log("Saved:", filePath);

    // در JSON: مسیر نسبی نسبت به assets
    // مثال: audio/A1/wA1-1-0036.mp3
    item.audio = `audio/${category}/${fileName}`;

    return true;
  } catch (err) {
    console.error("Error generating audio:", err.message);
    return false;
  }
}

async function processJsonFile(filePath) {
  const raw = fs.readFileSync(filePath, "utf8");
  let data;

  try {
    data = JSON.parse(raw);
  } catch (e) {
    console.error("Invalid JSON:", filePath);
    return 0;
  }

  if (!Array.isArray(data)) {
    console.error("JSON must be an array:", filePath);
    return 0;
  }

  let updatedCount = 0;

  for (const item of data) {
    const ok = await processWordItem(item);
    if (ok) updatedCount++;
  }

  if (updatedCount > 0) {
    fs.writeFileSync(filePath, JSON.stringify(data, null, 2), "utf8");
    console.log(`Updated ${updatedCount} items in ${path.basename(filePath)}`);
  } else {
    console.log(`No items updated in ${path.basename(filePath)}`);
  }

  return updatedCount;
}

async function main() {
  ensureDir(AUDIO_BASE_DIR);

  const files = fs.readdirSync(WORDS_DIR).filter((f) => f.endsWith(".json"));

  console.log("Found JSON files:", files);

  let totalUpdated = 0;

  for (const file of files) {
    const fullPath = path.join(WORDS_DIR, file);
    const updated = await processJsonFile(fullPath);
    totalUpdated += updated;
  }

  console.log("Total new audios generated:", totalUpdated);
}

main().catch((err) => {
  console.error("Fatal error:", err);
});
