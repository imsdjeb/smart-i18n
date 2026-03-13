# 🌍 smart-i18n

**Zero-config, framework-agnostic i18n for Claude Code.**

Extract hardcoded strings → Generate semantic keys → Translate with context → Sync locales → Guard commits. All from your terminal.

---

## Why smart-i18n?

Every i18n tool I've used has the same problem: it's locked to one framework, requires a separate CLI, or needs 30 minutes of config before you can extract a single string.

smart-i18n is different. It auto-detects your stack, picks the right i18n library, and handles everything — from finding hardcoded strings in your codebase to translating them with proper context and language-specific rules. No config files to write. No CLI to install. Just ask.

It works the same whether you're on a React app, a Flutter project, a Django backend, or anything in between.

---

## Install

```bash
# Add the marketplace (one-time)
claude plugin marketplace add imsdjeb/smart-i18n

# Install the plugin
claude plugin install smart-i18n@imsdjeb
```

That's it. No config needed — the plugin auto-detects everything.

---

## Commands

| Command | What it does |
|---------|-------------|
| `/smart-i18n:init` | Set up i18n from scratch — detects framework, installs lib, creates locale files |
| `/smart-i18n:scan` | Find hardcoded strings with priority scoring (0–100) and key suggestions |
| `/smart-i18n:extract` | Replace hardcoded strings with i18n calls + add to locale files (with diff preview) |
| `/smart-i18n:translate` | Translate missing keys with context, glossary, and language-specific rules |
| `/smart-i18n:sync` | Sync all locales — add missing keys, warn about extras, reorder for clean diffs |
| `/smart-i18n:coverage` | Coverage report with percentages, suspect detection, and priority list |

---

## Quick Start

**1. Initialize** — Run `/smart-i18n:init fr,es,ja` and the plugin detects your framework, installs the right i18n library, creates your locale structure, and generates a `.smart-i18n.json` config.

**2. Scan & Extract** — Run `/smart-i18n:scan` to find all hardcoded strings with priority scores. Then `/smart-i18n:extract` to replace them with proper i18n calls. You'll get a diff preview before any changes are applied.

**3. Translate** — Run `/smart-i18n:translate` and all your missing keys get translated with full context: app domain, existing translations, glossary terms, and language-specific rules (RTL for Arabic, plural forms, typography conventions).

**4. Keep it clean** — The built-in hook warns you whenever you write a hardcoded string in a frontend file. Run `/smart-i18n:sync` to keep locales aligned and `/smart-i18n:coverage` to track progress.

---

## Natural Language

You don't need slash commands. The skill auto-triggers on natural requests:

- *"Find all hardcoded strings in src/components"*
- *"Extract the translatable strings from this file"*
- *"Add French and Spanish translations"*
- *"What's our translation coverage?"*
- *"Set up i18n for this project"*
- *"Sync the locale files"*
- *"Make this app available in Arabic"*

---

## Configuration

After running `init`, you'll have a `.smart-i18n.json` at your project root:

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

All fields are optional — the plugin auto-detects sensible defaults. The config is there for when you need to override.

**`glossary`** is particularly useful — map terms to forced translations to ensure consistency:

```json
{
  "glossary": {
    "workspace": { "fr": "espace de travail", "es": "espacio de trabajo" },
    "deploy": { "fr": "déployer", "es": "desplegar" }
  }
}
```

---

## Supported Frameworks

### Tier 1 — Full support

| Framework | i18n Libraries | File Format |
|-----------|---------------|-------------|
| Angular | ngx-translate, @angular/localize, transloco | JSON, XLF |
| React | react-i18next, react-intl, lingui | JSON, PO |
| Vue | vue-i18n | JSON |
| Next.js | next-intl, next-i18next | JSON |
| Flutter | flutter_localizations, easy_localization, slang | ARB, JSON |

### Tier 2 — Detection + basic support

| Framework | i18n Libraries | File Format |
|-----------|---------------|-------------|
| Svelte | svelte-i18n, paraglide-js | JSON |
| Nuxt | @nuxtjs/i18n | JSON |
| Django | gettext (built-in) | PO |
| Rails | rails-i18n | YAML |

---

## How It Works

1. **Detect** — A shell script analyzes your project files (package.json, pubspec.yaml, angular.json, etc.) to identify your framework, i18n library, locale directory, and file format.

2. **Scan** — A heuristic scoring system (0–100) evaluates every string literal in your code. It looks at context (template vs logic), content (natural language vs code), and variable names (label, title, message) to find strings that need translating.

3. **Extract** — Strings are replaced with the correct i18n pattern for your framework (`t('key')`, `{{ $t('key') }}`, `AppLocalizations.of(context)!.key`, etc.). Keys are generated following a semantic naming convention.

4. **Translate** — Missing keys are translated with full context: app domain, surrounding translations, glossary overrides, and language-specific rules (French typography, Arabic RTL + plural forms, Japanese script selection, etc.).

5. **Sync** — Locale files are kept in sync. Missing keys get `[NEEDS_TRANSLATION]` markers. Extra keys trigger warnings. Key ordering matches the source for clean diffs.

6. **Guard** — A post-write hook watches for hardcoded strings in frontend files and nudges you to extract them.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines on adding framework adapters, improving detection, and sharing translation glossaries.

---

## License

[MIT](LICENSE)
