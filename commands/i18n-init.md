---
description: "Set up i18n in your project from scratch. Auto-detects framework, installs the right library, creates locale files, and generates config."
argument-hint: "[target-locales] e.g. fr,es,ar,ja"
---

Run the **INIT** workflow from the smart-i18n skill. Detect the project's framework, recommend and install the best i18n library, create locale directories and base files, wire up the config, and generate `.smart-i18n.json`.

If the user provided target locales as arguments, use those. Otherwise, ask which languages they want to support.
