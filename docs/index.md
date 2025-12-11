This is the master control file.  
Any AI MUST follow this file before executing any task.

---

# 1. Required Document Loading Order

AI MUST load these documents in the exact order:

1. `/docs/ai_behavioral_rules.md`
2. `/docs/app_schema_language_rules.md`
3. `/docs/app_schema.md`
4. `/docs/prd.md`
5. `/docs/error_handling_rules.md`
6. `/docs/context.md`
7. `/docs/task.md`

AI may NOT skip or partially load any file.

---

# 2. Session Optimization Rule

If this is the **first task in the session**, the AI MUST load all documents fully.

If the AI has **already loaded these documents earlier in the same session**,  
it may use its internal memory and MUST NOT reload the files unless the user says:

---

## 2. Core AI Execution Rules

Before doing any task, the AI MUST:

1. Load all files (1 → 5)
2. Build an internal model of:
   - The AppSchema language
   - The WordMap AppSchema
   - The PRD requirements
   - The AI behavioral constraints
3. THEN read and execute the task.

AI must always follow:

- The AppSchema structure
- The PRD logic
- The Behavioral Rules
- The Task Template format

---

## 3. Structural + Navigation Rules (MANDATORY)

AI must follow:

- Icon system: Only Lucide Icons are allowed. No Material Icons.
- Only use containers defined in `/docs/app_schema.md`
- Overlays like `(Word page)` are not new screens
- Bottom navigation exists **only** in `[Main Page] -> [Bottom]`
- Tasks must always refer to existing containers

---

## 4. Creation Rule (IMPORTANT)

If the developer asks for something that **does NOT exist** in the AppSchema:

### The AI MUST:

1. STOP
2. ASK for confirmation
3. WAIT for explicit approval
4. ONLY then create or modify the schema

### The AI MUST NOT:

- create new pages
- create new tabs
- create new overlays
- modify navigation  
  WITHOUT explicit “YES, create it.”

If no approval is given → DO NOTHING.

---

## 5. Conflict Resolution Priority

When documents disagree, follow this order:

1. **PRD.md**
2. **app_schema.md**
3. **ai_behavioral_rules.md**
4. **task.md**

---

## 6. Developer Usage

The developer only needs to write:
