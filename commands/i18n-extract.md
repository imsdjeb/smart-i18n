---
description: "Extract hardcoded strings and replace them with i18n function calls. Framework-aware with diff preview."
argument-hint: "[path] e.g. src/components/Header.tsx"
---

Run the **EXTRACT** workflow from the smart-i18n skill. Scan for hardcoded strings, generate semantic keys, replace strings with the correct i18n pattern for the detected framework, and add keys to the source locale file.

Always show a diff preview before applying changes. If the user provided a path argument, extract from that directory/file only.
