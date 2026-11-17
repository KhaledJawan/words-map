# Writing grammar lessons

Every grammar lesson in `shared/src/commonMain/composeResources/files/gramatik/<level>/` has a `.json` file (number,
title, topic) and, next to it, its text as a Markdown file, one per language:

```
gramatik/a1/01-ich-du-er-sie-es-wir.json      number, title, topic
gramatik/a1/01-ich-du-er-sie-es-wir.fa.md     the lesson in Farsi
gramatik/a1/01-ich-du-er-sie-es-wir.en.md     the lesson in English (optional)
```

To add lesson texts, have another AI write them with the prompt below (one lesson or several
at once), save its whole answer as a file, then:

```
python3 tools/add_lesson.py answer.md --book a1-b1              # Farsi, a lesson of the A1–B1 book
python3 tools/add_lesson.py answer.md --book b2-c1 --lang en    # English, a lesson of the B2–C1 book
python3 tools/add_lesson.py 27 lesson.md --book a1-b1           # one lesson without a "=== LESSON ===" line
```

Each lesson in the answer starts with a line `=== LESSON 27 ===`. The script splits the
answer there, finds every lesson by its number, checks it (answers with no right one, the same
answer twice, unknown cards) and saves it in the right place. The lessons come from two books
that both count from 1: Grammatik aktiv A1–B1 (folders a1, a2, b1) and Grammatik aktiv B2–C1
(folders b2, c1), so `--book` says which one the numbers belong to.

## The format

| Write | Shown as |
|---|---|
| `# ضمایر شخصی` (first line) | the topic in the reader's language, under the German topic |
| a normal paragraph | text |
| `## ۱. ضمایر شخصی` | a section heading |
| `\| a \| b \|` lines | a table; the first row is the header |
| `- item` or `1. item` | a list |
| `**word**` | bold |
| `` `Sie` `` | a German word inside Farsi text, highlighted |
| `> [!NOTE]` | blue card: something to notice |
| `> [!TIP]` | green card: a trick that helps |
| `> [!IMPORTANT]` | orange card: something the learner must not miss |
| `> [!WARNING]` | red card: a common mistake |
| `> [!RULE]` | purple card: a grammar rule |
| `> [!EXAMPLE]` | teal card: German sentences bold, translations below |
| `> [!SUMMARY]` | grey card: the summary at the end |
| `## Quiz` | the questions at the end; passing them marks the lesson learned |

Every line of a card starts with `> `. In the quiz each question starts with `? `, wrong
answers with `- `, the right answer with `* `, and a `! ` line explains why it is right; the
explanation is shown after the learner answers. The app shuffles the answers. (The older form,
`1. question` with `- [ ]` answers and `- [x]` for the right one, works too.)

## Prompt

````text
You write German grammar lessons for a language-learning app, for Farsi speakers.
Write each lesson listed at the end in Farsi. All German words, sentences and examples stay
in German. Return ONLY the lessons, nothing before, between or after them. Start every lesson
with its marker line, exactly like this:

=== LESSON <number> ===

and after it the lesson in this Markdown format:

# <name of the topic in Farsi>

<one or two sentences: what this topic is and why it matters>

## ۱. <section title in Farsi>

<short explanation; put German words inside Farsi sentences in backticks, like `Sie`>

| <column> | <column> | <column> |
| --- | --- | --- |
| ... | ... | ... |

- <list item>

> [!RULE]
> <a grammar rule, short; can be a list with "> - ">

> [!EXAMPLE]
> <German sentence>
> <second German sentence, if needed>
> <Farsi translation>

> [!NOTE]
> <something to notice>

> [!WARNING]
> <a common mistake and the right form>

> [!TIP]
> <a trick that helps to remember>

> [!SUMMARY]
> <the most important points in one or two sentences>

## Quiz

? <question, usually a German sentence with ___ for the gap>
- <wrong answer>
* <right answer>
- <wrong answer>
- <wrong answer>
! <one sentence in Farsi: why the right answer is right>

Rules:
- Use 3 to 6 sections (## ۱., ## ۲., ...), each short and clear, for a learner at the
  level in brackets after the lesson (A1 to C1).
- Use tables for forms and endings, cards for rules, notes, mistakes and examples.
- Every line of a card starts with "> ". Card types: NOTE, TIP, IMPORTANT, WARNING, RULE, EXAMPLE, SUMMARY.
- Put the SUMMARY card at the end, after the quiz or before it.
- The quiz has 6 to 10 questions, each with 3 or 4 different answers: exactly one right answer
  starting with "* ", the wrong ones with "- ", and one "! " line explaining the answer.
  Never write the same answer twice in one question.
- In Farsi lines, write arrows as ← (they read right to left).
- No images, links, HTML, emojis, or lines like "result" or "try again".

- Each lesson is complete on its own; the "=== LESSON <number> ===" line is the only thing
  between two lessons.

Lessons:
<paste the lines of the lessons you want from the list below, for example>
2 – Konjugation im Präsens (Ich komme, du kommst)   [A1]
3 – Konjugation: sein, haben und möchten (Ich bin, du hast, er möchte)   [A1]
````

## Example

`gramatik/a1/01-ich-du-er-sie-es-wir.fa.md` is a complete lesson in this format.

## All lessons

Copy the lines you want into the "Lessons:" part of the prompt, with the level in brackets:
it tells the writer how simple to keep the lesson. Send lessons of one book per answer.

### Grammatik aktiv A1–B1 (`--book a1-b1`)

```
1 – Personalpronomen (Ich, du, er, sie, es, wir, ihr, sie und Sie)   [A1]
2 – Konjugation im Präsens (Ich komme, du kommst)   [A1]
3 – Konjugation: sein, haben und möchten (Ich bin, du hast, er möchte)   [A1]
4 – Verben mit Vokalwechsel (Ich esse wenig, aber du isst viel!)   [A1]
5 – Modalverben im Satz (Ich muss, ich kann, ich will)   [A1]
6 – Modalverben: können, wollen, möchten (Ich kann, ich will, ich möchte)   [A1]
7 – Modalverben: müssen, sollen, dürfen (Ich muss, ich soll, ich darf)   [A1]
8 – Trennbare Verben (Ich kaufe im Supermarkt ein)   [A1]
9 – Imperativ (Helfen Sie mir!)   [A1]
10 – W-Fragen (Wer? Wie? Wo? Was?)   [A1]
11 – Ja-/Nein-Fragen (Lernen Sie Deutsch?)   [A1]
12 – Satzbau: die Position des Verbs (Am Abend essen wir Pizza)   [A1]
13 – Zwei Verben im Satz (Ich gehe … schwimmen)   [A2]
14 – Nomen im Plural (Die Männer, die Frauen, die Babys)   [A1]
15 – Artikel: bestimmt und unbestimmt (Der, das, die – ein, ein, eine)   [A1]
16 – Negation mit nicht und kein (Ich koche nicht. Ich habe keine Zeit.)   [A1]
17 – Akkusativ (Der Mann isst den Fisch)   [A1]
18 – Dativ (Ich fahre mit dem Auto)   [A1]
19 – Possessivartikel (Mein, dein, unser)   [A1]
20 – Artikelwörter: welcher und dieser (Welcher? – Dieser!)   [A1]
21 – Personalpronomen im Akkusativ und Dativ (Nur mit dir – nie ohne dich)   [A1]
22 – Verben mit Dativ und Akkusativ (Ich kaufe meinem Sohn einen Ball)   [A2]
23 – Verben mit Dativ (Ich helfe dir, du dankst mir)   [A2]
24 – Fragewörter: wer, wen, wem, was (Wem schenkst du was?)   [A2]
25 – Präteritum von sein und haben (Ich war, ich hatte)   [A1]
26 – Perfekt mit haben (Was hast du gestern gemacht?)   [A1]
27 – Perfekt mit sein und haben (Ich bin gekommen, ich habe gelacht)   [A2]
28 – Partizip II (Gesehen – eingekauft – bezahlt)   [A2]
29 – Präteritum der Modalverben (Ich konnte, ich musste, ich wollte)   [A2]
30 – Zeitformen der Vergangenheit (Gestern hatte er Zeit und hat Sport gemacht)   [A2]
31 – Reflexive Verben (Sie wäscht sich)   [A2]
32 – Temporale Präpositionen 1 (Im, am, um, von … bis, nach, vor)   [A1]
33 – Präpositionen mit Dativ (Aus, bei, mit, nach, seit, von, zu)   [A1]
34 – Präpositionen mit Akkusativ (Für, um, durch, ohne, gegen)   [A1]
35 – Wechselpräpositionen mit Dativ (Wo? Im Kino)   [A1]
36 – Wechselpräpositionen mit Dativ und Akkusativ (Im Kino oder ins Kino?)   [A2]
37 – Lokale Präpositionen: Wohin? (Ich gehe zum Arzt und auf den Markt)   [A2]
38 – Lokale Präpositionen: Wo? (Ich war beim Arzt und bin jetzt auf dem Markt)   [A2]
39 – Lokale Präpositionen: Woher? (Ich komme aus den Bergen vom Skifahren)   [A2]
40 – Adjektive: Nominativ und Akkusativ (Ein netter Mann! Ich liebe den netten Mann)   [A2]
41 – Adjektive: Nominativ, Akkusativ und Dativ (Am ersten Mai)   [A2]
42 – Komparativ und Vergleichssätze (Schneller als …)   [A2]
43 – Superlativ (Der kleinste Mann läuft am schnellsten)   [B1]
44 – Hauptsätze verbinden (Position 0) (Und, aber, oder, denn)   [A1]
45 – Hauptsätze verbinden (Position 1) (Deshalb, sonst, dann, danach)   [A2]
46 – Nebensätze mit weil, wenn und dass (…, weil ich Deutsch lernen möchte.)   [A2]
47 – Komposita (Kinderarzt oder Arztkinder?)   [A1]
48 – Zusammengesetzte Verben (Ich bin dann mal weg)   [A1]
49 – Genusregeln (Der, die oder das?)   [A1]
50 – Partikeln (Was heißt das denn?)   [A2]
51 – Aus Wörtern neue Wörter machen (-chen, -lein, -er, -in, -ung)   [A2]
52 – Negationswörter (Nicht und nichts, noch nicht und nicht mehr)   [B1]
53 – Lokale Adverbien: Position und Direktion (Ich bin oben. Komm auch nach oben.)   [B1]
54 – Präteritum (Er kam, sah und sagte)   [B1]
55 – Plusquamperfekt (Ich hatte zu lange geschlafen)   [B1]
56 – Reflexivpronomen im Akkusativ und Dativ (Ich wasche mir die Hände)   [B1]
57 – Trennbare und untrennbare Verben (Kaufe ich ein oder bestelle ich Pizza?)   [B1]
58 – Verben mit Präpositionen (Sie freut sich über die Blumen)   [B1]
59 – Präpositionaladverbien und -pronomen (Daneben, danach, dafür …)   [B1]
60 – Konjunktiv 2: Formen (War, hätte, würde …)   [B1]
61 – Konjunktiv 2: Gebrauch (Wenn ich viel Geld hätte, …)   [B1]
62 – Passiv (Der Baum wird gepflanzt)   [B1]
63 – Passiv in der Vergangenheit (Wann wurde der Kölner Dom gebaut?)   [B1]
64 – Vermutung und Zukunft mit Futur 1 (Der Präsident wird Japan besuchen)   [B1]
65 – Funktionen von werden (Werden, werden, werden …)   [B1]
66 – Das Verb lassen (Leben und leben lassen)   [B1]
67 – Positions- und Direktionsverben (Stehen/stellen, sitzen/setzen, liegen/legen und hängen)   [B1]
68 – Genitiv (Das Auto seines Vaters)   [B1]
69 – n-Deklination (Kennen Sie den Herrn?)   [B1]
70 – Adjektive für Personen als Nomen (Der Jugendliche – ein Jugendlicher)   [B1]
71 – Adjektive als neutrale Nomen (Alles Gute!)   [B1]
72 – Indirekte Fragen (Wissen Sie, ob …?)   [B1]
73 – Infinitiv mit zu (Es ist schön, ein Fest zu feiern.)   [B1]
74 – Infinitiv ohne zu (Ich will singen, lass mich singen!)   [B1]
75 – Relativsätze 1 (Das ist der Mann, der immer meine Nachbarin besucht)   [B1]
76 – Relativsätze 2 (Wie heißt das Ding, mit dem man …?)   [B1]
77 – Temporale Nebensätze mit wenn und als (Ich gehe, wenn … / Ich ging, als …)   [B1]
78 – Temporale Nebensätze (Während, bevor, nachdem, seit)   [B1]
79 – Finalsätze (Um … zu und damit)   [B1]
80 – Doppelkonnektoren (Entweder … oder, weder … noch, sowohl … als auch, nicht nur … sondern auch)   [B1]
81 – Vergleichssätze (Je größer, desto besser!)   [B1]
82 – Präpositionen mit Genitiv (Während, wegen, trotz, innerhalb, außerhalb)   [B1]
83 – Temporale Präpositionen 2 (Innerhalb, außerhalb, in, nach, vor, seit, bei, während)   [B1]
84 – Adjektivdeklination mit und ohne Artikel (Deutsches Bier)   [B1]
85 – Partizip 1 als Adjektiv (Schwimmende Vögel und fliegende Fische)   [B1]
```

### Grammatik aktiv B2–C1 (`--book b2-c1`)

```
1 – Verbposition in einfachen Sätzen (Heute möchte ich ins Schwimmbad gehen.)   [B2]
2 – Verbposition in Satzverbindungen (Ich gehe ins Schwimmbad, obwohl ich arbeiten müsste.)   [B2]
3 – Position von Dativ- und Akkusativobjekt (Der Kellner holt der Dame den Kaffee und bringt ihn ihr.)   [B2]
4 – Position der Angaben im Satz (wann – warum – wie – wo)   [B2]
5 – Informationen direkt zum Verb (Er hat gestern drei Stunden lang Tennis gespielt.)   [B2]
6 – Position von nicht (Das habe ich nicht gesagt.)   [B2]
7 – Position von auch und Fokuspartikeln (Gehst du morgen auch ins Kino?)   [B2]
8 – Informationsverteilung im Satz (Den Ring zeigt sie einem Freund.)   [C1]
9 – Konjunktiv 2 der Gegenwart: Formen (Wenn ich einen Zauberstab hätte, würde ich …)   [B2]
10 – Konjunktiv 2 der Vergangenheit: Formen (Wäre ich doch zu Hause geblieben!)   [B2]
11 – Höflichkeit, Vorschläge, Ratschläge und Vorwürfe (Würden Sie bitte das Fenster schließen?)   [B2]
12 – Wünsche, irreale Wünsche, irreale Bedingungen (Wenn ich doch Millionär wäre!)   [B2]
13 – Irreale Vergleiche und irreale Folgen (Du siehst aus, als ob du müde wärst.)   [B2]
14 – Passiv in allen Zeiten (Die Reisegruppe wird informiert.)   [B2]
15 – Passiv mit Modalverben in allen Zeiten (Das muss heute noch erledigt werden.)   [B2]
16 – Alternativen zum Passiv (Das Problem lässt sich lösen.)   [B2]
17 – Formen mit Passivbedeutung (Die zu verkaufenden Bücher gehören ins Fenster gestellt.)   [C1]
18 – Passivsätze ohne Subjekt (Hier wird gelacht!)   [B2]
19 – Wann ist Passiv möglich, wann nicht? (Warum ist „Es wird geregnet“ falsch?)   [C1]
20 – Wechselpräpositionen (Joggen Sie in den Park oder joggen Sie im Park?)   [B2]
21 – Oft gebrauchte lokale Präpositionen (wo – wohin – woher)   [B2]
22 – Weitere lokale Präpositionen (Innerhalb und außerhalb des Dorfes)   [B2]
23 – Die wichtigsten temporalen Präpositionen (Am Montag um 18 Uhr auf dem Heimweg)   [B2]
24 – Weitere temporale Präpositionen (Ab Montag und über die Feiertage)   [B2]
25 – Kausale Präpositionen (Vor Wut oder aufgrund eines Fehlers)   [B2]
26 – Präpositionen der Redewiedergabe und Referenz (laut, zufolge, hinsichtlich, entsprechend)   [C1]
27 – Präpositionen mit verschiedenen Positionen (Davon, dahinter und um das Nomen herum)   [C1]
28 – „Sprechende“ Präpositionen (zuliebe, mittels, anhand …)   [C1]
29 – Bedeutungen von in, an, auf, über, unter, vor (am Sonntag, am Strand, an die 100 Leute)   [C1]
30 – Bedeutungen von um, bei, von, nach, aus, mit, zu (um das Haus, um 8 Uhr, um die Wette)   [C1]
31 – Verben mit Nominativ, Akkusativ und Dativ (Ich frage dich und antworte dir.)   [B2]
32 – Verben mit Genitiv (Man verdächtigte ihn des Mordes.)   [C1]
33 – Verben, Nomen und Adjektive mit Präpositionen (Es kommt darauf an, wann ihr kommt.)   [B2]
34 – Verben, Adjektive und Nomen mit festen Präpositionen mit Akkusativ (Danke für das Kompliment.)   [B2]
35 – Verben, Adjektive und Nomen mit festen Präpositionen mit Dativ (Ich träume von dir.)   [B2]
36 – Bildung der Vergangenheitszeiten (Das Glas ist zerbrochen, aber wer hat es zerbrochen?)   [B2]
37 – Besondere Perfektformen: Modalverben und sehen, hören, lassen (Ich habe gehen müssen.)   [B2]
38 – Gebrauch von Zeiten der Vergangenheit (Oh, das wusste ich nicht!)   [B2]
39 – Vermutung und Zukunft mit dem Futur (Er wird den Zug verpasst haben.)   [B2]
40 – Überblick über die Zeiten im Deutschen (Plusquamperfekt bis Futur 2.)   [B2]
41 – Modalverben in der Grundbedeutung (Ich will, ich kann, ich muss.)   [B2]
42 – Andere Bedeutung von Modalverben: Vermutungen über die Gegenwart (Er muss gleich da sein.)   [C1]
43 – Andere Bedeutung von Modalverben: Vermutungen über die Vergangenheit (Sie muss wohl zu Fuß gegangen sein.)   [C1]
44 – Das Verb lassen (Leben und leben lassen.)   [B2]
45 – Trennbare und untrennbare Verben 1 (mitkommen, ankommen, bekommen, entkommen)   [B2]
46 – Trennbare und untrennbare Verben 2 (Er umfährt den Baum, aber er fährt die Mülltonne um.)   [C1]
47 – Genusregeln (Der, die oder das?)   [B2]
48 – Artikelgebrauch (Handwerker, der Handwerker oder ein Handwerker?)   [B2]
49 – Genitiv (Deutschlands Süden)   [B2]
50 – n-Deklination (An Herrn und Frau Schneider)   [B2]
51 – Drei Deklinationen (des Mannes, des Herrn, des Alten)   [C1]
52 – Deklination der Indefinit- und Possessivpronomen (Bringst du mir welche mit?)   [B2]
53 – Indefinitpronomen für Menschen (man, alle, jeder, jemand, niemand)   [B2]
54 – Indefinitpronomen für Menschen und Dinge (Beide trinken beides.)   [B2]
55 – Adjektivdeklination (Mit dem schnellen Auto steht man oft in einem langen Stau.)   [B2]
56 – Artikelwörter und Adjektivdeklination (Alle kleinen Kinder und viele große Kinder mögen Schokolade.)   [B2]
57 – Komparation (Der ältere Mann genießt einen der schönsten Tage des Jahres.)   [B2]
58 – Partizip I und II als Adjektiv (Das malende und das gemalte Mädchen.)   [B2]
59 – Indirekte Rede und Konjunktiv 1 (Er sagte, er sei fertig und komme gleich.)   [B2]
60 – Indirekte Rede – Vergangenheit (Sie sagte, sie habe Glück gehabt und sei pünktlich gewesen.)   [B2]
61 – Wiedergabe von Aufforderungen, Gerüchten und Selbstaussagen (Er will das nie gesagt haben.)   [C1]
62 – Temporale Nebensätze (Seitdem die Katze kommt, wenn ich koche …)   [B2]
63 – Kausale und konzessive Nebensätze (weil, da, obwohl, wobei …)   [B2]
64 – Konsekutive Nebensätze (sodass, weshalb, dermaßen …, dass)   [B2]
65 – Konditionale und adversative Nebensätze (wenn, falls, während, wohingegen …)   [B2]
66 – Modale Nebensätze (Methode) (indem, dadurch dass, wodurch …)   [B2]
67 – Infinitiv mit und ohne zu (Wir wollen pünktlich kommen, aber fürchten, zu spät losgefahren zu sein.)   [B2]
68 – Nebensatz mit dass und Infinitiv mit zu (Ich hoffe, abzunehmen und dass auch mein Mann abnimmt.)   [B2]
69 – Finale und modale Infinitiv- und Nebensätze (um … zu, damit, anstatt …, ohne …)   [B2]
70 – Relativpronomen im Nominativ, Akkusativ und Dativ (…, denen wir die Idee für dieses Fest verdanken.)   [B2]
71 – Relativpronomen im Genitiv (Die Frau, deren Hund …)   [B2]
72 – Relativpronomen mit w- und als (etwas, was …, nichts, worüber …)   [B2]
73 – Doppelkonnektoren (entweder A oder B)   [B2]
74 – Negationswörter (nie, nirgends, nicht mehr)   [B2]
75 – Irgend… (Hat irgendjemand irgendetwas gesehen?)   [B2]
76 – Position und Direktion (rauf, runter, stehen, stellen, legen)   [B2]
77 – Es (Wann brauche ich es?)   [C1]
78 – Funktionsverbgefüge 1 (Wir müssen jetzt eine Entscheidung treffen.)   [B2]
79 – Funktionsverbgefüge 2 (In Aufregung versetzen oder in Aufregung geraten?)   [C1]
80 – Wörter mit da- (Da ist Assenheim. Da habe ich lange gewohnt. Dabei wollte ich eigentlich nie in einem Dorf leben.)   [C1]
81 – Modalpartikeln (Im Kino waren wir doch gestern.)   [C1]
82 – Nominalisierung (Durch Verwendung von Nomen entsteht Verdichtung.)   [C1]
83 – Links- und Rechtsattribute (Komplexe Sätze verstehen und umformen.)   [C1]
84 – Präposition – Adverb – Konnektor 1 (temporal: vor, vorher, bevor, nach …)   [C1]
85 – Präposition – Adverb – Konnektor 2 (kausal, konsekutiv, konzessiv, adversativ)   [C1]
86 – Präposition – Adverb – Konnektor 3 (modal, konditional, final)   [C1]
87 – Kommaregeln (Er isst seine Katze auch???)   [C1]
88 – Besondere Formen der mündlichen Sprache (Da kommste nich drauf.)   [C1]
```
