#!/usr/bin/env bash
set -euo pipefail

# smart-i18n framework & i18n library detection script
# Outputs a JSON object with detected configuration

# --- Require jq ---
if ! command -v jq &>/dev/null; then
  echo "Error: jq is required but not installed. Install it with: brew install jq (macOS) or apt-get install jq (Debian/Ubuntu)" >&2
  exit 1
fi

FRAMEWORK="unknown"
I18N_LIBRARY="unknown"
LOCALES_DIR=""
FILE_FORMAT="json"
SOURCE_LOCALE="en"
EXISTING_LOCALES="[]"
CODE_PATTERN=""
HAS_CONFIG="false"
PACKAGE_MANAGER="unknown"

# --- Detect package manager ---
if [ -f "bun.lockb" ] || [ -f "bun.lock" ]; then
  PACKAGE_MANAGER="bun"
elif [ -f "pnpm-lock.yaml" ]; then
  PACKAGE_MANAGER="pnpm"
elif [ -f "yarn.lock" ]; then
  PACKAGE_MANAGER="yarn"
elif [ -f "package-lock.json" ]; then
  PACKAGE_MANAGER="npm"
elif [ -f "Pipfile.lock" ]; then
  PACKAGE_MANAGER="pipenv"
elif [ -f "poetry.lock" ]; then
  PACKAGE_MANAGER="poetry"
elif [ -f "Gemfile.lock" ]; then
  PACKAGE_MANAGER="bundler"
elif [ -f "pubspec.lock" ]; then
  PACKAGE_MANAGER="pub"
fi

# --- Cache parsed package.json ---
PKG_JSON=""
PKG_JSON_VALID="false"
if [ -f "package.json" ]; then
  PKG_JSON=$(cat package.json 2>/dev/null || echo "")
  if echo "$PKG_JSON" | jq empty 2>/dev/null; then
    PKG_JSON_VALID="true"
  fi
fi

# --- Helper: check if a dependency exists in package.json ---
pkg_has_dep() {
  local pkg="$1"
  [ "$PKG_JSON_VALID" = "true" ] || return 1
  echo "$PKG_JSON" | jq -e --arg p "$pkg" '
    (.dependencies[$p] // .devDependencies[$p] // .peerDependencies[$p]) != null
  ' &>/dev/null
}

# --- Check for .smart-i18n.json ---
SMART_CONFIG=""
SMART_CONFIG_VALID="false"
if [ -f ".smart-i18n.json" ]; then
  HAS_CONFIG="true"
  SMART_CONFIG=$(cat .smart-i18n.json 2>/dev/null || echo "")
  if echo "$SMART_CONFIG" | jq empty 2>/dev/null; then
    SMART_CONFIG_VALID="true"
  fi
fi

# --- Flutter ---
if [ -f "pubspec.yaml" ]; then
  FRAMEWORK="flutter"
  FILE_FORMAT="arb"

  if grep -q "easy_localization" pubspec.yaml 2>/dev/null; then
    I18N_LIBRARY="easy_localization"
    LOCALES_DIR="assets/translations"
    CODE_PATTERN="tr()"
  elif grep -q "slang" pubspec.yaml 2>/dev/null; then
    I18N_LIBRARY="slang"
    LOCALES_DIR="lib/i18n"
    CODE_PATTERN="t.key"
    FILE_FORMAT="json"
  elif grep -q "flutter_localizations" pubspec.yaml 2>/dev/null; then
    I18N_LIBRARY="flutter_localizations"
    LOCALES_DIR="lib/l10n"
    CODE_PATTERN="AppLocalizations.of(context)!.key"
  else
    I18N_LIBRARY="flutter_localizations"
    LOCALES_DIR="lib/l10n"
    CODE_PATTERN="AppLocalizations.of(context)!.key"
  fi

# --- Angular ---
elif [ -f "angular.json" ]; then
  FRAMEWORK="angular"

  if pkg_has_dep "@ngx-translate/core"; then
    I18N_LIBRARY="ngx-translate"
    LOCALES_DIR="src/assets/i18n"
    CODE_PATTERN="{{ 'key' | translate }}"
  elif pkg_has_dep "@ngneat/transloco" || pkg_has_dep "transloco"; then
    I18N_LIBRARY="transloco"
    LOCALES_DIR="src/assets/i18n"
    CODE_PATTERN="{{ t('key') }}"
  elif pkg_has_dep "@angular/localize"; then
    I18N_LIBRARY="angular-localize"
    LOCALES_DIR="src/locale"
    CODE_PATTERN="\$localize"
    FILE_FORMAT="xlf"
  else
    I18N_LIBRARY="ngx-translate"
    LOCALES_DIR="src/assets/i18n"
    CODE_PATTERN="{{ 'key' | translate }}"
  fi

# --- Next.js ---
elif ls next.config.* 1>/dev/null 2>&1; then
  FRAMEWORK="nextjs"

  if pkg_has_dep "next-intl"; then
    I18N_LIBRARY="next-intl"
    CODE_PATTERN="t('key')"
    if [ -d "messages" ]; then
      LOCALES_DIR="messages"
    else
      LOCALES_DIR="messages"
    fi
  elif pkg_has_dep "next-i18next"; then
    I18N_LIBRARY="next-i18next"
    LOCALES_DIR="public/locales"
    CODE_PATTERN="t('key')"
  else
    I18N_LIBRARY="next-intl"
    LOCALES_DIR="messages"
    CODE_PATTERN="t('key')"
  fi

# --- Nuxt ---
elif ls nuxt.config.* 1>/dev/null 2>&1; then
  FRAMEWORK="nuxt"
  I18N_LIBRARY="@nuxtjs/i18n"
  LOCALES_DIR="locales"
  CODE_PATTERN="\$t('key')"

# --- Svelte ---
elif ls svelte.config.* 1>/dev/null 2>&1; then
  FRAMEWORK="svelte"

  if pkg_has_dep "paraglide-js"; then
    I18N_LIBRARY="paraglide-js"
    LOCALES_DIR="messages"
    CODE_PATTERN="m.key()"
  elif pkg_has_dep "svelte-i18n"; then
    I18N_LIBRARY="svelte-i18n"
    LOCALES_DIR="src/lib/i18n"
    CODE_PATTERN="\$_('key')"
  else
    I18N_LIBRARY="svelte-i18n"
    LOCALES_DIR="src/lib/i18n"
    CODE_PATTERN="\$_('key')"
  fi

# --- Vue (not Nuxt) ---
elif pkg_has_dep "vue"; then
  FRAMEWORK="vue"

  if pkg_has_dep "vue-i18n"; then
    I18N_LIBRARY="vue-i18n"
  fi
  LOCALES_DIR="src/locales"
  CODE_PATTERN="\$t('key')"

# --- React (generic, not Next.js) ---
elif pkg_has_dep "react"; then
  FRAMEWORK="react"

  if pkg_has_dep "react-i18next"; then
    I18N_LIBRARY="react-i18next"
    LOCALES_DIR="public/locales"
    CODE_PATTERN="t('key')"
  elif pkg_has_dep "react-intl"; then
    I18N_LIBRARY="react-intl"
    LOCALES_DIR="src/lang"
    CODE_PATTERN="intl.formatMessage({ id: 'key' })"
  elif pkg_has_dep "@lingui/react" || pkg_has_dep "@lingui/core"; then
    I18N_LIBRARY="lingui"
    LOCALES_DIR="src/locales"
    CODE_PATTERN="t\`key\`"
    FILE_FORMAT="po"
  else
    I18N_LIBRARY="unknown"
    LOCALES_DIR="public/locales"
    CODE_PATTERN="t('key')"
  fi

# --- Django ---
elif [ -f "manage.py" ]; then
  FRAMEWORK="django"
  I18N_LIBRARY="gettext"
  LOCALES_DIR="locale"
  FILE_FORMAT="po"
  CODE_PATTERN="_(\"key\")"

# --- Rails ---
elif [ -f "Gemfile" ] && grep -qE "gem ['\"]rails['\"]" Gemfile 2>/dev/null; then
  FRAMEWORK="rails"
  I18N_LIBRARY="rails-i18n"
  LOCALES_DIR="config/locales"
  FILE_FORMAT="yaml"
  CODE_PATTERN="t('.key')"
fi

# --- Detect existing locales ---
# Locale regex: 2-letter ISO 639-1 code + optional region/script suffix
# Only 2-letter codes to avoid false positives on common names (app, nav, src, lib, css, api)
# Matches: en, fr, de, ja, en_US, pt_BR, zh-Hans, zh-Hant
LOCALE_REGEX='[a-z]{2}([_-][A-Za-z]{2,4})?'

if [ -n "$LOCALES_DIR" ] && [ -d "$LOCALES_DIR" ]; then
  LOCALE_FILES=""
  case "$FILE_FORMAT" in
    json)
      LOCALE_FILES=$(find "$LOCALES_DIR" -maxdepth 2 -name "*.json" 2>/dev/null | head -20 || true)
      ;;
    arb)
      LOCALE_FILES=$(find "$LOCALES_DIR" -maxdepth 2 -name "*.arb" 2>/dev/null | head -20 || true)
      ;;
    yaml)
      LOCALE_FILES=$(find "$LOCALES_DIR" -maxdepth 2 \( -name "*.yml" -o -name "*.yaml" \) 2>/dev/null | head -20 || true)
      ;;
    po)
      LOCALE_FILES=$(find "$LOCALES_DIR" -maxdepth 3 -name "*.po" 2>/dev/null | head -20 || true)
      ;;
    xlf)
      LOCALE_FILES=$(find "$LOCALES_DIR" -maxdepth 2 \( -name "*.xlf" -o -name "*.xliff" \) 2>/dev/null | head -20 || true)
      ;;
  esac

  if [ -n "$LOCALE_FILES" ]; then
    LOCALES_JSON="[]"
    while IFS= read -r f; do
      [ -n "$f" ] || continue
      basename_f=$(basename "$f")
      parent_dir=$(basename "$(dirname "$f")")

      # Strip file extension
      stripped=$(echo "$basename_f" | sed -E 's/\.(json|arb|ya?ml|po|xlf|xliff)$//')

      # Strategy 1: Check if parent directory IS a locale code (en/translation.json)
      locale=$(echo "$parent_dir" | grep -oE "^${LOCALE_REGEX}$" || true)

      # Strategy 2: For ARB files, extract locale after last underscore (app_en.arb → en)
      if [ -z "$locale" ] && [ "$FILE_FORMAT" = "arb" ]; then
        locale=$(echo "$stripped" | sed -E 's/^.*_//' | grep -oE "^${LOCALE_REGEX}$" || true)
      fi

      # Strategy 3: Filename IS the locale code (en.json, fr.yml, pt_BR.json)
      if [ -z "$locale" ]; then
        locale=$(echo "$stripped" | grep -oE "^${LOCALE_REGEX}$" || true)
      fi

      if [ -n "$locale" ]; then
        LOCALES_JSON=$(echo "$LOCALES_JSON" | jq --arg loc "$locale" '. + [$loc] | unique')
      fi
    done <<< "$LOCALE_FILES"

    if [ "$(echo "$LOCALES_JSON" | jq 'length')" -gt 0 ]; then
      EXISTING_LOCALES="$LOCALES_JSON"
    fi
  fi
fi

# --- Try to detect source locale from config ---
if [ "$SMART_CONFIG_VALID" = "true" ]; then
  DETECTED_SOURCE=$(echo "$SMART_CONFIG" | jq -r '.sourceLocale // empty' 2>/dev/null || true)
  if [ -n "$DETECTED_SOURCE" ]; then
    SOURCE_LOCALE="$DETECTED_SOURCE"
  fi
fi

# --- Output JSON using jq for safe encoding ---
jq -n \
  --arg framework "$FRAMEWORK" \
  --arg i18nLibrary "$I18N_LIBRARY" \
  --arg localesDir "$LOCALES_DIR" \
  --arg fileFormat "$FILE_FORMAT" \
  --arg sourceLocale "$SOURCE_LOCALE" \
  --argjson existingLocales "$EXISTING_LOCALES" \
  --arg codePattern "$CODE_PATTERN" \
  --argjson hasConfig "$HAS_CONFIG" \
  --arg packageManager "$PACKAGE_MANAGER" \
  '{
    framework: $framework,
    i18nLibrary: $i18nLibrary,
    localesDir: $localesDir,
    fileFormat: $fileFormat,
    sourceLocale: $sourceLocale,
    existingLocales: $existingLocales,
    codePattern: $codePattern,
    hasConfig: $hasConfig,
    packageManager: $packageManager
  }'
