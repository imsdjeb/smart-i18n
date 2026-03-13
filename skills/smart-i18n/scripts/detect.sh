#!/usr/bin/env bash
set -euo pipefail

# smart-i18n framework & i18n library detection script
# Outputs a JSON object with detected configuration

FRAMEWORK="unknown"
I18N_LIBRARY="unknown"
LOCALES_DIR=""
FILE_FORMAT="json"
SOURCE_LOCALE="en"
EXISTING_LOCALES="[]"
CODE_PATTERN=""
HAS_CONFIG="false"

# Check for .smart-i18n.json
if [ -f ".smart-i18n.json" ]; then
  HAS_CONFIG="true"
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

  if [ -f "package.json" ] && grep -q "@ngx-translate/core" package.json 2>/dev/null; then
    I18N_LIBRARY="ngx-translate"
    LOCALES_DIR="src/assets/i18n"
    CODE_PATTERN="{{ 'key' | translate }}"
  elif [ -f "package.json" ] && grep -q "transloco" package.json 2>/dev/null; then
    I18N_LIBRARY="transloco"
    LOCALES_DIR="src/assets/i18n"
    CODE_PATTERN="{{ t('key') }}"
  elif [ -f "package.json" ] && grep -q "@angular/localize" package.json 2>/dev/null; then
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

  if [ -f "package.json" ] && grep -q "next-intl" package.json 2>/dev/null; then
    I18N_LIBRARY="next-intl"
    CODE_PATTERN="t('key')"
    if [ -d "messages" ]; then
      LOCALES_DIR="messages"
    else
      LOCALES_DIR="messages"
    fi
  elif [ -f "package.json" ] && grep -q "next-i18next" package.json 2>/dev/null; then
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

  if [ -f "package.json" ] && grep -q "paraglide" package.json 2>/dev/null; then
    I18N_LIBRARY="paraglide-js"
    LOCALES_DIR="messages"
    CODE_PATTERN="m.key()"
  elif [ -f "package.json" ] && grep -q "svelte-i18n" package.json 2>/dev/null; then
    I18N_LIBRARY="svelte-i18n"
    LOCALES_DIR="src/lib/i18n"
    CODE_PATTERN="\$_('key')"
  else
    I18N_LIBRARY="svelte-i18n"
    LOCALES_DIR="src/lib/i18n"
    CODE_PATTERN="\$_('key')"
  fi

# --- Vue (not Nuxt) ---
elif [ -f "package.json" ] && grep -q "\"vue\"" package.json 2>/dev/null; then
  FRAMEWORK="vue"
  I18N_LIBRARY="vue-i18n"
  LOCALES_DIR="src/locales"
  CODE_PATTERN="\$t('key')"

# --- React (generic, not Next.js) ---
elif [ -f "package.json" ] && (grep -q "\"react\"" package.json 2>/dev/null); then
  FRAMEWORK="react"

  if grep -q "react-i18next" package.json 2>/dev/null; then
    I18N_LIBRARY="react-i18next"
    LOCALES_DIR="public/locales"
    CODE_PATTERN="t('key')"
  elif grep -q "react-intl" package.json 2>/dev/null; then
    I18N_LIBRARY="react-intl"
    LOCALES_DIR="src/lang"
    CODE_PATTERN="intl.formatMessage({ id: 'key' })"
  elif grep -q "@lingui" package.json 2>/dev/null; then
    I18N_LIBRARY="lingui"
    LOCALES_DIR="src/locales"
    CODE_PATTERN="t\`key\`"
    FILE_FORMAT="po"
  else
    I18N_LIBRARY="react-i18next"
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
elif [ -f "Gemfile" ] && grep -q "rails" Gemfile 2>/dev/null; then
  FRAMEWORK="rails"
  I18N_LIBRARY="rails-i18n"
  LOCALES_DIR="config/locales"
  FILE_FORMAT="yaml"
  CODE_PATTERN="t('.key')"
fi

# --- Detect existing locales ---
if [ -n "$LOCALES_DIR" ] && [ -d "$LOCALES_DIR" ]; then
  LOCALE_FILES=""
  case "$FILE_FORMAT" in
    json)
      LOCALE_FILES=$(find "$LOCALES_DIR" -maxdepth 2 -name "*.json" 2>/dev/null | head -20)
      ;;
    arb)
      LOCALE_FILES=$(find "$LOCALES_DIR" -maxdepth 2 -name "*.arb" 2>/dev/null | head -20)
      ;;
    yaml)
      LOCALE_FILES=$(find "$LOCALES_DIR" -maxdepth 2 -name "*.yml" -o -name "*.yaml" 2>/dev/null | head -20)
      ;;
    po)
      LOCALE_FILES=$(find "$LOCALES_DIR" -maxdepth 3 -name "*.po" 2>/dev/null | head -20)
      ;;
    xlf)
      LOCALE_FILES=$(find "$LOCALES_DIR" -maxdepth 2 -name "*.xlf" -o -name "*.xliff" 2>/dev/null | head -20)
      ;;
  esac

  if [ -n "$LOCALE_FILES" ]; then
    LOCALES=()
    while IFS= read -r f; do
      basename_f=$(basename "$f")
      # Extract locale code from filename patterns like en.json, messages.en.json, app_en.arb
      locale=$(echo "$basename_f" | sed -E 's/\.(json|arb|ya?ml|po|xlf|xliff)$//' | grep -oE '[a-z]{2}(-[A-Z]{2})?' | tail -1)
      if [ -n "$locale" ]; then
        LOCALES+=("\"$locale\"")
      fi
    done <<< "$LOCALE_FILES"

    if [ ${#LOCALES[@]} -gt 0 ]; then
      # Deduplicate
      EXISTING_LOCALES=$(printf '%s\n' "${LOCALES[@]}" | sort -u | tr '\n' ',' | sed 's/,$//')
      EXISTING_LOCALES="[$EXISTING_LOCALES]"
    fi
  fi
fi

# --- Try to detect source locale ---
if [ -f ".smart-i18n.json" ]; then
  DETECTED_SOURCE=$(grep -o '"sourceLocale"[[:space:]]*:[[:space:]]*"[^"]*"' .smart-i18n.json 2>/dev/null | grep -o '"[^"]*"$' | tr -d '"')
  if [ -n "$DETECTED_SOURCE" ]; then
    SOURCE_LOCALE="$DETECTED_SOURCE"
  fi
fi

# --- Output JSON ---
cat <<EOF
{
  "framework": "$FRAMEWORK",
  "i18nLibrary": "$I18N_LIBRARY",
  "localesDir": "$LOCALES_DIR",
  "fileFormat": "$FILE_FORMAT",
  "sourceLocale": "$SOURCE_LOCALE",
  "existingLocales": $EXISTING_LOCALES,
  "codePattern": "$CODE_PATTERN",
  "hasConfig": $HAS_CONFIG
}
EOF
