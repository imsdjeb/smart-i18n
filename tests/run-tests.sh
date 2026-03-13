#!/usr/bin/env bash
set -uo pipefail

# smart-i18n detection test suite
# Validates detect.sh against known fixture projects.

TESTS_DIR="$(cd "$(dirname "$0")" && pwd)"
DETECT_SCRIPT="$TESTS_DIR/../plugin/skills/smart-i18n/scripts/detect.sh"
FIXTURES_DIR="$TESTS_DIR/fixtures"

PASS_COUNT=0
FAIL_COUNT=0
TOTAL=0

# Verify dependencies
if ! command -v jq &>/dev/null; then
  echo "Error: jq is required but not installed."
  exit 1
fi

if [ ! -f "$DETECT_SCRIPT" ]; then
  echo "Error: detect.sh not found at $DETECT_SCRIPT"
  exit 1
fi

# Helper: run a single test case
# Arguments:
#   $1 - fixture directory name
#   $2 - expected framework
#   $3 - expected i18nLibrary
#   $4 - expected fileFormat
#   $5 - label for display
#   $6 - (optional) additional JSON field checks as "key=value key=value ..."
run_test() {
  local fixture_name="$1"
  local expected_framework="$2"
  local expected_i18n_lib="$3"
  local expected_format="$4"
  local label="$5"
  local extra_checks="${6:-}"

  TOTAL=$((TOTAL + 1))

  local fixture_dir="$FIXTURES_DIR/$fixture_name"
  if [ ! -d "$fixture_dir" ]; then
    printf "  FAIL %-30s fixture directory not found\n" "$label:"
    FAIL_COUNT=$((FAIL_COUNT + 1))
    return
  fi

  # Run detection from fixture directory
  local output
  output=$(cd "$fixture_dir" && bash "$DETECT_SCRIPT" 2>/dev/null)
  local exit_code=$?

  if [ $exit_code -ne 0 ]; then
    printf "  FAIL %-30s detect.sh exited with code %d\n" "$label:" "$exit_code"
    FAIL_COUNT=$((FAIL_COUNT + 1))
    return
  fi

  # Validate JSON output
  if ! echo "$output" | jq . &>/dev/null; then
    printf "  FAIL %-30s invalid JSON output\n" "$label:"
    FAIL_COUNT=$((FAIL_COUNT + 1))
    return
  fi

  local actual_framework actual_i18n_lib actual_format
  actual_framework=$(echo "$output" | jq -r '.framework')
  actual_i18n_lib=$(echo "$output" | jq -r '.i18nLibrary')
  actual_format=$(echo "$output" | jq -r '.fileFormat')

  local errors=""

  # Check framework
  if [ "$actual_framework" != "$expected_framework" ]; then
    errors="${errors}framework expected=$expected_framework got=$actual_framework; "
  fi

  # Check i18n library
  if [ "$actual_i18n_lib" != "$expected_i18n_lib" ]; then
    errors="${errors}i18nLibrary expected=$expected_i18n_lib got=$actual_i18n_lib; "
  fi

  # Check file format
  if [ "$actual_format" != "$expected_format" ]; then
    errors="${errors}fileFormat expected=$expected_format got=$actual_format; "
  fi

  # Extra field checks (e.g. "hasConfig=true sourceLocale=fr")
  if [ -n "$extra_checks" ]; then
    for check in $extra_checks; do
      local key="${check%%=*}"
      local expected_val="${check#*=}"
      local actual_val
      actual_val=$(echo "$output" | jq -r "if .$key == null then \"\" else (.$key | tostring) end" 2>/dev/null)
      if [ "$actual_val" != "$expected_val" ]; then
        errors="${errors}${key} expected=$expected_val got=$actual_val; "
      fi
    done
  fi

  # Report result
  if [ -z "$errors" ]; then
    printf "  PASS %-30s framework=%s i18nLib=%s\n" "$label:" "$actual_framework" "$actual_i18n_lib"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    printf "  FAIL %-30s %s\n" "$label:" "$errors"
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
}

# Helper: check that existingLocales array contains specific locales
run_locale_test() {
  local fixture_name="$1"
  local expected_framework="$2"
  local expected_i18n_lib="$3"
  local label="$4"
  shift 4
  local expected_locales=("$@")

  TOTAL=$((TOTAL + 1))

  local fixture_dir="$FIXTURES_DIR/$fixture_name"
  if [ ! -d "$fixture_dir" ]; then
    printf "  FAIL %-30s fixture directory not found\n" "$label:"
    FAIL_COUNT=$((FAIL_COUNT + 1))
    return
  fi

  local output
  output=$(cd "$fixture_dir" && bash "$DETECT_SCRIPT" 2>/dev/null)
  local exit_code=$?

  if [ $exit_code -ne 0 ]; then
    printf "  FAIL %-30s detect.sh exited with code %d\n" "$label:" "$exit_code"
    FAIL_COUNT=$((FAIL_COUNT + 1))
    return
  fi

  if ! echo "$output" | jq . &>/dev/null; then
    printf "  FAIL %-30s invalid JSON output\n" "$label:"
    FAIL_COUNT=$((FAIL_COUNT + 1))
    return
  fi

  local actual_framework actual_i18n_lib
  actual_framework=$(echo "$output" | jq -r '.framework')
  actual_i18n_lib=$(echo "$output" | jq -r '.i18nLibrary')

  local errors=""

  if [ "$actual_framework" != "$expected_framework" ]; then
    errors="${errors}framework expected=$expected_framework got=$actual_framework; "
  fi

  if [ "$actual_i18n_lib" != "$expected_i18n_lib" ]; then
    errors="${errors}i18nLibrary expected=$expected_i18n_lib got=$actual_i18n_lib; "
  fi

  # Check each expected locale is present in existingLocales
  for loc in "${expected_locales[@]}"; do
    local found
    found=$(echo "$output" | jq -r --arg l "$loc" '.existingLocales | map(select(. == $l)) | length')
    if [ "$found" -eq 0 ]; then
      errors="${errors}locale $loc missing from existingLocales; "
    fi
  done

  if [ -z "$errors" ]; then
    local locales_display
    locales_display=$(echo "$output" | jq -c '.existingLocales')
    printf "  PASS %-30s locales=%s\n" "$label:" "$locales_display"
    PASS_COUNT=$((PASS_COUNT + 1))
  else
    local locales_display
    locales_display=$(echo "$output" | jq -c '.existingLocales')
    printf "  FAIL %-30s %s(got %s)\n" "$label:" "$errors" "$locales_display"
    FAIL_COUNT=$((FAIL_COUNT + 1))
  fi
}

echo ""
echo "  smart-i18n Test Suite"
echo "  =========================="
echo ""
echo "  -- Core Detection ----------------------------"

#                fixture dir            framework    i18nLib                fileFormat   label
run_test         "react-i18next"        "react"      "react-i18next"        "json"       "react-i18next"
run_test         "next-intl"            "nextjs"     "next-intl"            "json"       "next-intl"
run_test         "vue-i18n"             "vue"        "vue-i18n"             "json"       "vue-i18n"
run_test         "angular-transloco"    "angular"    "transloco"            "json"       "angular-transloco"
run_test         "flutter-arb"          "flutter"    "flutter_localizations" "arb"       "flutter-arb"
run_test         "svelte-i18n"          "svelte"     "svelte-i18n"          "json"       "svelte-i18n"

echo ""
echo "  -- Edge Cases --------------------------------"

run_test         "no-i18n-lib"          "react"      "unknown"              "json"       "no-i18n-lib"
run_test         "react-intl"           "react"      "react-intl"           "json"       "react-intl"
run_test         "yaml-locales"         "rails"      "rails-i18n"           "yaml"       "yaml-locales"        "packageManager=unknown"
run_test         "empty-locales-dir"    "react"      "react-i18next"        "json"       "empty-locales-dir"
run_test         "no-locales-dir"       "react"      "react-i18next"        "json"       "no-locales-dir"

echo ""
echo "  -- Locale Detection --------------------------"

run_locale_test  "react-i18next"        "react"      "react-i18next"        "react-i18next locales"        "en"
run_locale_test  "next-intl"            "nextjs"     "next-intl"            "next-intl locales"            "en"
run_locale_test  "underscore-locales"   "react"      "react-i18next"        "underscore locales"           "en_US" "zh_CN" "pt_BR"
run_locale_test  "nested-locales"       "vue"        "vue-i18n"             "nested dir locales"           "en" "fr"
run_locale_test  "yaml-locales"         "rails"      "rails-i18n"           "yaml locales"                 "en" "fr"
run_locale_test  "flutter-arb"          "flutter"    "flutter_localizations" "arb locales"                 "en"

echo ""
echo "  -- Framework Overlap -------------------------"

# Next.js has react in deps — must detect as nextjs, not react
run_test         "nextjs-react-overlap"   "nextjs"     "next-intl"            "json"       "nextjs > react"
run_locale_test  "nextjs-react-overlap"   "nextjs"     "next-intl"            "nextjs overlap locales"       "en"

# Nuxt has vue in deps — must detect as nuxt, not vue
run_test         "nuxt-vue-overlap"       "nuxt"       "@nuxtjs/i18n"         "json"       "nuxt > vue"
run_locale_test  "nuxt-vue-overlap"       "nuxt"       "@nuxtjs/i18n"         "nuxt overlap locales"         "en"

echo ""
echo "  -- Config Detection --------------------------"

run_test         "smart-i18n-config"    "react"      "react-i18next"        "json"       "has .smart-i18n.json" "hasConfig=true sourceLocale=fr"
run_test         "react-i18next"        "react"      "react-i18next"        "json"       "no config"            "hasConfig=false"

echo ""
echo "  -- Package Manager Detection -----------------"

run_test         "yaml-locales"         "rails"      "rails-i18n"           "yaml"       "rails (no lockfile)"  "packageManager=unknown"
run_test         "flutter-arb"          "flutter"    "flutter_localizations" "arb"       "flutter (no lock)"    "packageManager=unknown"

echo ""
echo "  -- Regression Tests --------------------------"

# Regression: files like app.json, nav.json in locales dir must NOT be detected as locales
run_locale_test  "non-locale-filenames"  "react"      "react-i18next"        "no false-positive locales"    "en"

# Also verify the locale count is exactly 1 (only "en", not "app" or "nav")
TOTAL=$((TOTAL + 1))
_nlf_output=$(cd "$FIXTURES_DIR/non-locale-filenames" && bash "$DETECT_SCRIPT" 2>/dev/null)
_nlf_count=$(echo "$_nlf_output" | jq '.existingLocales | length')
if [ "$_nlf_count" -eq 1 ]; then
  printf "  PASS %-30s localeCount=%s\n" "locale count == 1:" "$_nlf_count"
  PASS_COUNT=$((PASS_COUNT + 1))
else
  printf "  FAIL %-30s expected 1 locale, got %s (%s)\n" "locale count == 1:" "$_nlf_count" "$(echo "$_nlf_output" | jq -c '.existingLocales')"
  FAIL_COUNT=$((FAIL_COUNT + 1))
fi

# Regression: gem "guardrails" must NOT trigger Rails detection
run_test         "guardrails-gem"       "react"      "unknown"              "json"       "guardrails != rails"

echo ""
echo "  =============================================="
echo "  Results: $PASS_COUNT/$TOTAL passed"

if [ $FAIL_COUNT -gt 0 ]; then
  echo "  $FAIL_COUNT test(s) failed."
  exit 1
else
  echo "  All tests passed."
  exit 0
fi
