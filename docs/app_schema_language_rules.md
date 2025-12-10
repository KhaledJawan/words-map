=========================
AppSchema Language Rules
=========================

Purpose:
A simplified structural language that defines pages, sections, overlays, and UI
relationships. You MUST follow this structure exactly when generating or modifying code.

---

1. Containers

---

[Title] = container (page/section/tab)

- Top-level = screen/page
- Inside another container = section or part of the parent

DO NOT invent new containers unless I explicitly ask.

---

2. Overlays

---

(Title) = overlay on top of parent

- modal, sheet, dialog, fullscreen popup
  NEVER a new navigation route unless I say so.

---

3. Descriptive text

---

"text" = explanation or goal, not UI and not code

---

4. Static non-clickable content

---

=item = label, text, data, image, description

---

5. Interactive elements

---

-item = clickable element -[Profile] = navigate/activate the existing [Profile] container

---

6. Hierarchy rules

---

Indentation defines parent-child relations.

---

7. Main Page rules

---

"Main Page" is root of the app:

- contains: [Header], [Body], [Bottom]
- bottom navigation ONLY inside [Main Page] -> [Bottom]
- Tabs exist inside [Main Page] -> [Body]

If I say: “create profile page”
→ modify [Profile] under [Main Page] -> [Body]
NOT anything outside or new.

---

8. OPTIONAL / EXTRA section

---

These items are NOT part of main navigation.
Use them ONLY when I explicitly activate them.

---

9. Prohibition rules

---

You MUST NOT:

- create new pages/tabs/routes unless I request
- alter navigation without permission
- duplicate containers
- assume new files not in schema

You MUST:

- follow schema strictly
- map instructions to correct container
- stay inside existing structure
