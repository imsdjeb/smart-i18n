---
name: smart-i18n
description: "Zero-config framework-agnostic internationalization. Use this skill whenever the user mentions: extracting translatable strings, hardcoded strings, i18n, internationalization, localization, l10n, translations, translation files, locale files, multi-language support, adding a new language, translation coverage, missing translations, syncing translations, or wants to make their app available in multiple languages. Also triggers on /smart-i18n:* commands. Supports Angular, React, Vue, Next.js, Svelte, Flutter, Django, Rails, and more."
---

# smart-i18n

Zero-config, framework-agnostic internationalization plugin.

Before doing anything, run `skills/smart-i18n/scripts/detect.sh` from the plugin root to detect the project's framework, i18n library, and existing locale setup. Use the output JSON to drive all subsequent decisions. Load reference docs from `skills/smart-i18n/references/` as needed.

## Config: .smart-i18n.json

If `.smart-i18n.json` exists in the project root, load it and use its values. Otherwise, use auto-detected defaults. Schema:

```json
{
  "sourceLocale": "en",
  "targetLocales": ["fr", "es", "ar", "ja"],
  "framework": "auto",
  "i18nLibrary": "auto",
  "localesDir": "auto",
  "keyStyle": "nested",
  "keyNaming": "snake_case",
  "exclude": ["**/*.test.*", "**/*.spec.*"],
  "scanThreshold": 70,
  "translationTone": "informal",
  "glossary": {},
  "maxKeyDepth": 4,
  "warnOnLongTranslations": true,
  "longTranslationThreshold": 1.5
}
```

---

## Workflow 1: INIT

**Trigger:** `/smart-i18n:init` or user asks to set up i18n / add multi-language support.

Steps:

1. Run `detect.sh` to detect the current stack.
2. If a framework is detected, recommend the best i18n library for it (see `references/adapters.md`). If no framework is detected, ask the user.
3. Install the recommended library using the project's package manager (npm/yarn/pnpm/pub/pip/bundle).
4. Create the locale directory at the conventional path for the framework.
5. Generate the base locale file (source locale) with an empty structure in the correct format (JSON/ARB/YAML/PO).
6. Wire up the i18n config in the project's entry point or config file as documented in `references/adapters.md`.
7. Generate `.smart-i18n.json` with detected + user-provided values.
8. Print a summary of what was set up and next steps.

If the user provides target locales as arguments, include them in the config. Otherwise, ask.

---

## Workflow 2: SCAN

**Trigger:** `/smart-i18n:scan [path]` or user asks to find hardcoded strings / translatable strings.

### Heuristic Scoring System (0–100)

Each candidate string gets a score. Only strings above the threshold (default 70, configurable via `scanThreshold`) are reported.

**Score boosters (+points):**
- Contains spaces AND starts with uppercase: +30
- Found inside template/JSX/HTML context (between `>` and `<`, in JSX expressions, template literals with UI context): +25
- Assigned to a UI variable (label, title, placeholder, message, error, tooltip, hint, description, text, header, subtitle, caption, button, alt): +20
- Contains natural punctuation (period, comma, question mark, exclamation): +15
- 3+ words: +10

**Score reducers (−points):**
- ALL_CAPS or SCREAMING_SNAKE_CASE: −40
- Looks like a URL (http/https/ftp/mailto): −50
- Inside `console.*`, `logger.*`, `debug()`, `print()` (unless Flutter): −40
- Inside `import`/`require`/`from` statement: −50
- MIME type pattern (`type/subtype`): −40
- HTTP method (GET, POST, PUT, DELETE, PATCH, OPTIONS): −50
- Color code (#hex, rgb, hsl): −40
- CSS class name pattern (kebab-case with no spaces): −30
- Less than 2 characters: −50
- In a test/spec/stories file: −50
- In an enum value or const declaration that looks like a config key: −20

### Output Format

Group results by file. For each string:

```
📁 src/components/Header.tsx
  🔴 92  line 14: "Welcome back, {{name}}!"     → common.welcome_back
  🟠 78  line 22: "Dashboard"                    → nav.dashboard.title
  🟡 71  line 35: "Last updated"                 → common.labels.last_updated

📁 src/pages/Login.tsx
  🔴 95  line 8:  "Sign in to your account"      → auth.login.heading
  🔴 88  line 19: "Forgot password?"              → auth.login.forgot_password
```

Priority emojis: 🔴 (90+), 🟠 (80–89), 🟡 (70–79)

Generate key suggestions following `references/key-naming.md` conventions.

If a `[path]` argument is provided, scan only that path. Otherwise, scan the entire project (respecting `exclude` patterns).

---

## Workflow 3: EXTRACT

**Trigger:** `/smart-i18n:extract [path]` or user asks to extract strings / replace hardcoded strings.

Steps:

1. Run SCAN internally to find all extractable strings.
2. Load `references/adapters.md` to determine the correct replacement pattern for the detected framework:
   - **Angular:** `{{ 'key' | translate }}` or `$localize\`:key:\`` depending on the i18n library
   - **React (react-i18next):** `{t('key')}` with `useTranslation()` hook import
   - **React (react-intl):** `<FormattedMessage id="key" />` or `intl.formatMessage({ id: 'key' })`
   - **Vue:** `{{ $t('key') }}` in templates, `this.$t('key')` in scripts
   - **Next.js (next-intl):** `t('key')` with `useTranslations()` or `getTranslations()`
   - **Svelte:** `$_('key')` or `$t('key')`
   - **Flutter:** `AppLocalizations.of(context)!.keyName`
   - **Django:** `{% trans "key" %}` in templates, `_("key")` in Python
   - **Rails:** `t('.key')` in views, `I18n.t('key')` in Ruby
3. For strings with dynamic values, convert to ICU MessageFormat:
   - `"Hello, " + name` → `"hello": "Hello, {name}"` → `t('hello', { name })`
   - Plurals: detect count-dependent strings and generate `{count, plural, one {# item} other {# items}}`
4. **ALWAYS show a diff preview before applying changes.** Present each file's changes and ask for confirmation.
5. After confirmation, apply changes:
   - Replace strings in source code with the i18n function call
   - Add the key + original string to the source locale file
   - Add necessary imports if not already present
6. Print a summary: X strings extracted, Y files modified, Z keys added.

---

## Workflow 4: TRANSLATE

**Trigger:** `/smart-i18n:translate [locale-codes]` or user asks to translate / add a language.

Steps:

1. Load context for high-quality translations:
   - App domain from `package.json` description, README, or `.smart-i18n.json`
   - Existing translations in the target locale (to maintain consistency)
   - Glossary from `.smart-i18n.json` (term → forced translation)
   - Tone setting: formal or informal (from config, default informal)
2. Load `references/translation.md` for language-specific rules.
3. Translate all missing keys for the target locale(s). For each string:
   - Consider the key name for context (e.g., `auth.login.heading` tells you it's a login page heading)
   - Consider surrounding keys for tone consistency
   - Apply glossary overrides
   - Apply language-specific rules (formality, punctuation, script, plural forms)
4. Post-translation checks:
   - **Placeholders preserved:** every `{variable}` in the source must appear in the translation
   - **Length warning:** if translation > 150% of source length (configurable via `longTranslationThreshold`), flag it
   - **Plural forms:** ensure all required CLDR categories are present for the target language
   - **RTL markers:** for Arabic and Hebrew, add directional markers around embedded LTR content (numbers, brand names)
5. Write translations to the target locale file(s).
6. Print summary: X keys translated for Y locale(s), Z warnings.

If locale codes are provided as arguments, translate only those. Otherwise, translate all `targetLocales` from config.

---

## Workflow 5: SYNC

**Trigger:** `/smart-i18n:sync` or user asks to sync / synchronize translations / locales.

Steps:

1. Load the source locale file as the reference.
2. For each target locale file:
   - **Missing keys:** Add them with the value `[NEEDS_TRANSLATION] original_value`. This makes missing translations searchable and visible.
   - **Extra keys** (in target but not in source): Print a warning listing them. Do NOT auto-delete — the user may have locale-specific keys intentionally.
   - **Key ordering:** Reorder target locale keys to match the source locale order. This produces clean diffs in version control.
3. Write updated locale files.
4. Print summary per locale: X keys added, Y extra keys found, Z keys reordered.

---

## Workflow 6: COVERAGE

**Trigger:** `/smart-i18n:coverage` or user asks about translation coverage / missing translations.

Steps:

1. Load all locale files.
2. Calculate coverage per locale:
   - Total keys in source locale
   - Translated keys (not empty, not `[NEEDS_TRANSLATION]`)
   - Missing keys
   - Percentage
3. Output a coverage table:

```
┌──────────┬───────────┬─────────┬──────────┬──────────┐
│ Locale   │ Total     │ Done    │ Missing  │ Coverage │
├──────────┼───────────┼─────────┼──────────┼──────────┤
│ en (src) │ 142       │ 142     │ 0        │ 100%     │
│ fr       │ 142       │ 138     │ 4        │ 97.2%    │
│ es       │ 142       │ 120     │ 22       │ 84.5%    │
│ ar       │ 142       │ 95      │ 47       │ 66.9%    │
│ ja       │ 142       │ 80      │ 62       │ 56.3%    │
└──────────┴───────────┴─────────┴──────────┴──────────┘
```

4. Detect suspect patterns:
   - **Identical translations:** same value across 3+ locales (likely untranslated copy-paste)
   - **Source copies:** target value identical to source (may be intentional for brand names, flag for review)
   - **Empty values:** keys with empty string values
5. List priority actions:
   - Locales below 80% coverage
   - High-priority untranslated keys (from common namespace or auth/onboarding flows)

---

## Key Naming Convention

Follow `references/key-naming.md` for all key generation. Quick reference:

```
{feature}.{section}.{element}.{descriptor}
```

- Use `common.*` namespace for shared strings (actions, labels, errors, status, time)
- Default to `snake_case` (configurable via `keyNaming`)
- Max depth: 4 levels (configurable via `maxKeyDepth`)
- Never use generic keys like `text1`, `label2`, `message`
- Deduplicate: if the same string exists, reuse the existing key

For Flutter (ARB format), use `camelCase` keys regardless of the `keyNaming` setting.

---

## Important Rules

1. **Never modify locale files without showing changes first** (except SYNC adding `[NEEDS_TRANSLATION]` markers).
2. **Never delete keys** from any locale file automatically. Always warn and let the user decide.
3. **Preserve file formatting** — if the project uses 2-space JSON indent, keep it. If YAML uses a specific style, match it.
4. **Respect `.smart-i18n.json` exclude patterns** when scanning.
5. **Always run detection first** if no `.smart-i18n.json` exists yet.
6. When working with Flutter ARB files, preserve the `@key` metadata entries.
7. For ICU MessageFormat, always validate that placeholders match between source and translations.
