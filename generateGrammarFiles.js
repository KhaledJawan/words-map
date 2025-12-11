const fs = require('fs');
const path = require('path');

const grammarStructure = {
  "Verben 1": [
    "Personalpronomen",
    "Konjugation Präsens",
    "Sein, haben und besondere Verben",
    "Verben mit Vokalwechsel",
    "Modalverben: Konjugation und Position im Satz",
    "Modalverben: Gebrauch 1",
    "Modalverben: Gebrauch 2",
    "Trennbare Verben"
  ],
  "Sätze und Fragen": [
    "Fragen mit Fragewort",
    "Ja-/Nein-Fragen und Antworten",
    "W-Fragen",
    "Zwei feste Positionen im Satz"
  ],
  "Pronomen, Nomen und Artikel": [
    "Nomen: Plural",
    "Der, die, das: bestimmt, unbestimmt, kein Artikel",
    "Nominativ",
    "Akkusativ",
    "Dativ",
    "Präpositionen mit Nomen: Wechselpräpositionen und Kasus",
    "Nomen im Satz: Subjekt und Objekt",
    "Personalpronomen im Akkusativ",
    "Personalpronomen im Dativ",
    "Präpositionen mit Dativ",
    "Präpositionen mit Akkusativ",
    "Possessivartikel",
    "Reflexive Verben"
  ],
  "Verben 2": [
    "Perfekt",
    "Perfekt mit sein",
    "Partizip II (Regelmäßige / Unregelmäßige Verben)",
    "Reflexive Verben im Perfekt"
  ],
  "Präpositionen": [
    "Temporale Präpositionen",
    "Präpositionen mit Dativ",
    "Präpositionen mit Akkusativ"
  ],
  "Wechselpräpositionen": [
    "Wechselpräpositionen mit Dativ",
    "Wechselpräpositionen mit Dativ und Akkusativ",
    "Lokale Präpositionen: Wo?",
    "Lokale Präpositionen: Wohin?",
    "Lokale Präpositionen: Woher?"
  ],
  "Adjektive": [
    "Nominativ und Akkusativ",
    "Nominativ und Dativ",
    "Komparativ und Superlativ",
    "Adjektivdeklination 1",
    "Adjektivdeklination 2"
  ],
  "Sätze und Satzverbindungen": [
    "Hauptsätze – Position 0",
    "Nebensätze mit weil, wenn und dass",
    "Nebensätze mit weil, wenn und dass (Übungsteil)"
  ],
  "Nebensätze": [
    "Relativsätze (mit Artikel)",
    "Relativsätze (Familienliste)"
  ],
  "Präpositionen 2": [
    "Präpositionen mit Genitiv",
    "Temporale Präpositionen 2"
  ],
  "Nomen 2": [
    "Genitiv",
    "N-Deklination",
    "Adjektive für Personen als Nomen",
    "Adjektive als neutrale Nomen"
  ],
  "Sätze und Satzverbindungen 2": [
    "Indirekte Fragen",
    "Infinitiv mit zu",
    "Relativsätze 2",
    "Temporale Nebensätze: als, wenn, während",
    "Doppelkonnektoren",
    "Vergleichssätze"
  ],
  "Wörter und Wortbildung": [
    "Zusammengefügte Verben",
    "Trennbare Verben neu",
    "Nomen mit Präpositionen",
    "Präfixverben",
    "Adjektive mit Präfixen",
    "Verb + Präposition",
    "Position und Direktionsverben",
    "Adverbien"
  ],
  "Partizip / Adjektiv": [
    "Adjektivdeklination mit dem Partizip I und ohne Artikel",
    "Partizip I als Adjektiv"
  ]
};

function slugify(value) {
  const replacements = {
    ä: 'ae',
    ö: 'oe',
    ü: 'ue',
    Ä: 'ae',
    Ö: 'oe',
    Ü: 'ue',
    ß: 'ss'
  };
  return value
    .split('')
    .map(char => replacements[char] ?? char)
    .join('')
    .replace(/\s+/g, '-')
    .replace(/[^a-zA-Z0-9\-]/g, '')
    .replace(/-+/g, '-')
    .toLowerCase();
}

const baseDir = path.join(__dirname, 'assets', 'lessons', 'grammar');

if (!fs.existsSync(baseDir)) {
  fs.mkdirSync(baseDir, { recursive: true });
  console.log(`Created folder: ${baseDir}`);
}

let foldersCreated = 0;
let filesCreated = 0;
const catalog = [];

Object.entries(grammarStructure).forEach(([category, topics], index) => {
  const categoryIndex = String(index + 1).padStart(2, '0');
  const categorySlug = slugify(category);
  const categoryPath = path.join(baseDir, `${categoryIndex}-${categorySlug}`);
  if (!fs.existsSync(categoryPath)) {
    fs.mkdirSync(categoryPath, { recursive: true });
    foldersCreated += 1;
    console.log(`Created folder: ${categoryPath}`);
  }
  const topicFiles = [];
  topics.forEach((topic, topicIndex) => {
    const topicFilename = `${String(topicIndex + 1).padStart(2, '0')}-${slugify(topic)}.json`;
    topicFiles.push(topicFilename);
    const filePath = path.join(categoryPath, topicFilename);
    if (!fs.existsSync(filePath)) {
      fs.writeFileSync(filePath, '{}\n', { encoding: 'utf8' });
      filesCreated += 1;
      console.log(`Created file: ${filePath}`);
    }
  });
  catalog.push({
    id: `${categoryIndex}-${categorySlug}`,
    title: category,
    topics: topicFiles,
  });
});

const catalogPath = path.join(baseDir, 'catalog.json');
fs.writeFileSync(catalogPath, `${JSON.stringify(catalog, null, 2)}\n`, { encoding: 'utf8' });
console.log(`Catalog written to ${catalogPath}`);

console.log(`Folders created: ${foldersCreated}`);
console.log(`Files created: ${filesCreated}`);
