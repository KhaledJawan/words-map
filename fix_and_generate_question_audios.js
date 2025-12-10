// fix_question_audio_links.js
// Node.js script to scan assets/words/*.json,
// find entries with question marks in word or audio,
// and replace audio URLs with sanitized filenames (no '?').

const fs = require("fs");
const path = require("path");

// مسیر پوشه‌ی JSON ها
const WORDS_DIR = path.join(__dirname, "assets", "words");

// آدرس پایه‌ی S3 خودت را اینجا بگذار
const AUDIO_BASE_URL = "https://wordmap-audio.s3.eu-north-1.amazonaws.com";

// پوشه بر اساس level (اختیاری، می‌تونی تغییر بدی)
function levelToFolder(level) {
  if (!level) return "";
  const upper = String(level).toUpperCase();
  if (upper.startsWith("A1")) return "A1";
  if (upper.startsWith("A2")) return "A2";
  if (upper.startsWith("B1")) return "B1";
  if (upper.startsWith("B2")) return "B2";
  return "";
}

// ساخت filename امن بر اساس word (و اگر لازم شد id)
function buildSafeFileName(word, id) {
  let base = String(word || "").toLowerCase();

  const removeChars = [
    "?",
    "!",
    ".",
    ",",
    ";",
    ":",
    '"',
    "'",
    "„",
    "“",
    "‚",
    "’",
  ];

  for (const ch of removeChars) {
    base = base.replaceAll(ch, "");
  }

  // فاصله و چند کاراکتر دیگر → underscore
  base = base
    .replace(/\s+/g, "_")
    .replace(/[\/\\|#%]/g, "_")
    .replace(/[()]/g, "");

  // اگر همه‌چیز پاک شد، از id استفاده کن
  if (!base.trim()) {
    base = String(id || "")
      .toLowerCase()
      .replace(/[^a-z0-9_]+/g, "_");
  }

  return `${base}.mp3`;
}

// ساخت URL جدید
function buildNewAudioUrl(wordObj) {
  const word = wordObj.word || "";
  const id = wordObj.id || "";
  const level = wordObj.level || "";
  const oldAudio = wordObj.audio || "";

  const fileName = buildSafeFileName(word, id);

  // اگر در لینک قبلی فولدر A1/A2/... وجود دارد، همان را نگه دار
  let folder = "";
  if (oldAudio.includes("/A1/")) folder = "A1";
  else if (oldAudio.includes("/A2/")) folder = "A2";
  else if (oldAudio.includes("/B1/")) folder = "B1";
  else if (oldAudio.includes("/B2/")) folder = "B2";
  else folder = levelToFolder(level); // fallback

  if (folder) {
    return `${AUDIO_BASE_URL}/${folder}/${fileName}`;
  }
  return `${AUDIO_BASE_URL}/${fileName}`;
}

function shouldFix(wordObj) {
  const word = String(wordObj.word || "");
  const audio = String(wordObj.audio || "");
  return (
    word.includes("?") ||
    audio.includes("?") ||
    audio.toLowerCase().includes("%3f")
  );
}

function main() {
  if (!fs.existsSync(WORDS_DIR)) {
    console.error(`Folder not found: ${WORDS_DIR}`);
    process.exit(1);
  }

  const files = fs
    .readdirSync(WORDS_DIR)
    .filter((f) => f.toLowerCase().endsWith(".json"));

  if (!files.length) {
    console.log("No JSON files found in assets/words/");
    return;
  }

  console.log("Scanning JSON files in assets/words/ ...\n");

  let totalChanges = 0;

  for (const fileName of files) {
    const fullPath = path.join(WORDS_DIR, fileName);
    const raw = fs.readFileSync(fullPath, "utf8");

    let data;
    try {
      data = JSON.parse(raw);
    } catch (e) {
      console.error(`⚠️  Could not parse JSON in ${fileName}:`, e.message);
      continue;
    }

    if (!Array.isArray(data)) {
      console.error(`⚠️  ${fileName} is not a JSON array. Skipping.`);
      continue;
    }

    let fileChanges = 0;

    for (const item of data) {
      if (!item || typeof item !== "object") continue;

      if (!shouldFix(item)) continue;

      const oldAudio = item.audio || "";
      const newAudio = buildNewAudioUrl(item);

      if (oldAudio === newAudio) continue;

      console.log(`File: ${fileName}`);
      console.log(`  id:    ${item.id}`);
      console.log(`  level: ${item.level}`);
      console.log(`  word:  "${item.word}"`);
      console.log(`  old:   ${oldAudio}`);
      console.log(`  new:   ${newAudio}`);
      console.log("");

      item.audio = newAudio;
      fileChanges++;
      totalChanges++;
    }

    if (fileChanges > 0) {
      // ذخیره با فرمت مرتب
      fs.writeFileSync(fullPath, JSON.stringify(data, null, 2), "utf8");
      console.log(
        `==> Updated ${fileChanges} item(s) in ${fileName}\n-----------------------------\n`
      );
    }
  }

  console.log(`Total updated items: ${totalChanges}`);
  console.log("Done.");
}

main();
