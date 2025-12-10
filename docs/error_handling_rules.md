# Error Handling Rules – WordMap

These rules define how all errors MUST be handled in the app.
AI MUST follow these rules whenever implementing logic, UI, or services.

---

## 1. Error Handling Philosophy

- Errors must be **simple**, **non-intrusive**, and **user friendly**.
- App must **not crash** under any circumstance.
- Show errors only when needed; do not overload the user.

---

## 2. Error Types

### 2.1. Network Errors

Example: no internet, timeout, failed API (future-proofing).

UI behavior:

- Show a small **Snackbar** with text:
  “Internetverbindung ist nicht verfügbar.”
- Allow retry where possible.
- Do NOT show dialogs for network errors.

### 2.2. Audio Playback Errors

Example: audio file missing or cannot play.

UI behavior:

- Show a small **Snackbar**:
  “Audio konnte nicht abgespielt werden.”
- Do NOT block the UI.

### 2.3. Data Loading Errors

Example: unable to load words, categories, or local storage.

UI behavior:

- Show a simple inline message or fallback state:
  “Fehler beim Laden der Daten.”
- Add a retry button if possible.

### 2.4. Unexpected Errors (fallback)

UI behavior:

- Show a Snackbar:
  “Ein unerwarteter Fehler ist aufgetreten.”
- Do NOT reveal technical details.
- Log the error internally using debug mode only.

---

## 3. UI Rules for Error Messages

### 3.1. Snackbar Rules

All errors shown to the user MUST use a Snackbar:

- short duration (2–3s)
- minimal text
- bottom position
- no action button required (unless Retry)

### 3.2. No Popup Dialogs

Errors MUST NOT use:

- AlertDialog
- Popup windows
- Blocking screens

Simple rule:
**Never stop the user’s flow.**

---

## 4. Developer Logs (Debug Mode Only)

For internal debugging:

- Use `debugPrint("Error: $e")`
- Never show the raw error message to the user.
- Avoid using print() in production code.

---

## 5. Error Handling Pattern (Flutter)

Use this pattern for any async call:

```dart
try {
  final data = await repository.load();
  state = Success(data);
} catch (e) {
  state = Error();
  debugPrint("Error loading data: $e");
  showSnackbar("Fehler beim Laden der Daten.");
}
```
