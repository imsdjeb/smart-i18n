# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] - 2026-03-13

### Added

- **INIT workflow** — Auto-detect framework and i18n library, install dependencies, create locale structure, generate config
- **SCAN workflow** — Heuristic scoring system (0–100) to find hardcoded strings with priority grouping and semantic key suggestions
- **EXTRACT workflow** — Replace hardcoded strings with framework-appropriate i18n calls, with diff preview before applying
- **TRANSLATE workflow** — Context-aware translation with glossary support, language-specific rules, and quality checks
- **SYNC workflow** — Synchronize locale files: add missing keys, warn about extras, reorder for clean diffs
- **COVERAGE workflow** — Translation coverage report with suspect pattern detection and priority actions
- **Auto-detection script** for Flutter, Angular, React, Vue, Next.js, Nuxt, Svelte, Django, and Rails
- **Post-write hook** that warns about hardcoded strings in frontend files
- **Framework adapters** with full code pattern documentation for 10+ frameworks
- **Translation quality guidelines** for 8 languages with CLDR plural rules and interpolation safety rules
- **Semantic key naming convention** with comprehensive `common.*` namespace
- **Configuration** via `.smart-i18n.json` with glossary and tone support

### Supported Frameworks

- **Tier 1:** Angular, React, Vue, Next.js, Flutter
- **Tier 2:** Svelte, Nuxt, Django, Rails
