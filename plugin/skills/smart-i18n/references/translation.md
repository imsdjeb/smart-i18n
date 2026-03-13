# Translation Quality Guidelines

## Language-Specific Rules

### French (fr)

- **Formality:** Use "tu" for informal apps (default), "vous" for formal/enterprise contexts
- **Typographic spaces:** Non-breaking space before `:`, `;`, `!`, `?` — e.g., `Bonjour !` not `Bonjour!`
- **Quotation marks:** Use guillemets `« text »` (with inner non-breaking spaces), not "text"
- **Capitalization:** Only capitalize the first word of a title, not every word — `Paramètres du compte` not `Paramètres Du Compte`
- **Number formatting:** Comma for decimals, space for thousands — `1 234,56`
- **Common pitfalls:**
  - "Click" → "Cliquez" (vous) or "Clique" (tu)
  - "Log in" → "Se connecter" not "Login"
  - "Email" → "E-mail" or "Courriel" (Quebec)

### Spanish (es)

- **Formality:** "tú" for informal, "usted" for formal, "vos" for Argentine/Central American Spanish
- **Inverted punctuation:** Always add `¿` before questions and `¡` before exclamations
- **Gender:** Be mindful of gendered nouns — use inclusive alternatives where possible, or provide both forms
- **Regional variants:**
  - es-ES (Spain): "ordenador", "vale", "móvil"
  - es-MX (Mexico): "computadora", "ok", "celular"
  - es-AR (Argentina): "computadora", "dale", "celular" + voseo
- **Number formatting:** Comma for decimals, period for thousands — `1.234,56`

### German (de)

- **Formality:** "du" for informal, "Sie" (always capitalized) for formal
- **Compound nouns:** Keep them as one word — `Datenschutzeinstellungen` not `Datenschutz Einstellungen`
- **Noun capitalization:** ALL nouns are capitalized, not just proper nouns — `Klicken Sie auf die Schaltfläche`
- **Length:** German translations are typically 20–35% longer than English — plan for UI expansion
- **Common pitfalls:**
  - "Save" → "Speichern" (verb) / "Sichern" (backup context)
  - "Settings" → "Einstellungen"
  - "Delete" → "Löschen"

### Arabic (ar)

- **Direction:** RTL (right-to-left). Add `dir="rtl"` to the container
- **Directional markers:** Wrap embedded LTR content (numbers, brand names, URLs) in `\u200F` (RLM) or `\u202B`/`\u202C` marks
- **Dual form:** Arabic has a dedicated dual plural form (for exactly 2 items)
- **Plural categories (ALL required):** `zero`, `one`, `two`, `few` (3–10), `many` (11–99), `other` (100+)
- **Example ICU plural:**
  ```
  {count, plural, zero {لا عناصر} one {عنصر واحد} two {عنصران} few {{count} عناصر} many {{count} عنصرًا} other {{count} عنصر}}
  ```
- **Formality:** Modern Standard Arabic (MSA) for formal apps, consider dialect for casual apps
- **Digits:** Arabic-Indic numerals (٠١٢) are optional — Western Arabic numerals (012) are widely accepted

### Japanese (ja)

- **Script selection:**
  - Kanji for common words: 設定, 保存, 削除
  - Hiragana for particles and native words: の, を, する
  - Katakana for loanwords and tech terms: ログイン, ダッシュボード, ファイル
- **Formality levels:**
  - Casual: ～だ / ～する (for consumer apps)
  - Polite: ～です / ～します (default, safe choice)
  - Honorific: ～でございます (for enterprise/banking)
- **Length:** Japanese is typically shorter than English (30–50% fewer characters)
- **No spaces:** Japanese does not use spaces between words
- **Plurals:** Japanese has no grammatical plural — use `other` category only

### Chinese (zh)

- **Simplified vs Traditional:**
  - `zh-CN` / `zh-Hans`: Simplified (mainland China, Singapore)
  - `zh-TW` / `zh-Hant`: Traditional (Taiwan, Hong Kong, Macau)
  - These are NOT interchangeable — always provide both if targeting both regions
- **No spaces between CJK characters:** `欢迎回来` not `欢迎 回来`
- **BUT spaces between CJK and Latin/numbers:** `共 3 个文件` or `打开 Settings`
- **Plurals:** Chinese has no grammatical plural — use `other` category only
- **Length:** Chinese translations are typically 30–50% shorter than English

### Korean (ko)

- **Politeness levels:**
  - Casual: ～해 / ～야 (friends, very informal apps)
  - Polite: ～해요 / ～세요 (default for most apps)
  - Formal: ～합니다 / ～십시오 (enterprise, official)
- **Particles:** Subject/object particles change based on the preceding character (은/는, 이/가, 을/를) — be careful with interpolated values
- **Plurals:** Korean has no grammatical plural — use `other` category only

### Portuguese (pt)

- **Brazilian vs European:**
  - `pt-BR`: "você", gerund (-ando/-endo), more informal
  - `pt-PT`: "tu" (informal) / "você" (semi-formal), infinitive constructions, more formal
- **Common differences:**
  - "File" → "Arquivo" (BR) / "Ficheiro" (PT)
  - "Mouse" → "Mouse" (BR) / "Rato" (PT)
  - "Screen" → "Tela" (BR) / "Ecrã" (PT)
- **Tip:** If you can only support one, `pt-BR` has ~10x the speakers

---

## CLDR Plural Rules by Language

| Language | zero | one | two | few | many | other |
|----------|------|-----|-----|-----|------|-------|
| English  | —    | ✅   | —   | —   | —    | ✅     |
| French   | —    | ✅   | —   | —   | ✅    | ✅     |
| Spanish  | —    | ✅   | —   | —   | ✅    | ✅     |
| German   | —    | ✅   | —   | —   | —    | ✅     |
| Arabic   | ✅    | ✅   | ✅   | ✅   | ✅    | ✅     |
| Japanese | —    | —   | —   | —   | —    | ✅     |
| Chinese  | —    | —   | —   | —   | —    | ✅     |
| Korean   | —    | —   | —   | —   | —    | ✅     |
| Portuguese| —   | ✅   | —   | —   | ✅    | ✅     |
| Russian  | —    | ✅   | —   | ✅   | ✅    | ✅     |
| Polish   | —    | ✅   | —   | ✅   | ✅    | ✅     |
| Turkish  | —    | ✅   | —   | —   | —    | ✅     |
| Hindi    | —    | ✅   | —   | —   | —    | ✅     |
| Italian  | —    | ✅   | —   | —   | ✅    | ✅     |
| Dutch    | —    | ✅   | —   | —   | —    | ✅     |

---

## Interpolation Safety Rules

1. **Every placeholder in the source MUST appear in the translation.** No exceptions.
   - Source: `"Welcome, {name}!"` → French: `"Bienvenue, {name} !"` ✅
   - Source: `"Welcome, {name}!"` → French: `"Bienvenue !"` ❌ (missing `{name}`)

2. **Never translate placeholder names.** They are code references.
   - `{userName}` stays `{userName}`, not `{nomUtilisateur}`

3. **Preserve placeholder syntax exactly.** Different frameworks use different formats:
   - `{name}` — ICU / react-intl / vue-i18n
   - `{{name}}` — Angular ngx-translate / Handlebars
   - `%(name)s` — Django / Python
   - `%{name}` — Rails / Ruby
   - `{$name}` — Angular $localize

4. **ICU plural/select blocks:** Keep the full structure, translate only the text parts:
   ```
   Source:  {count, plural, one {# item} other {# items}}
   French:  {count, plural, one {# élément} other {# éléments}}
   ```

5. **HTML tags in translations:** Preserve tag structure. Some frameworks support rich text:
   ```
   Source:  "Read our <link>terms</link>"
   French:  "Lisez nos <link>conditions</link>"
   ```

---

## Length Warnings

Translations significantly longer than the source can break UI layouts.

| Target language | Typical expansion vs English |
|----------------|------------------------------|
| German          | +20% to +35%                |
| French          | +15% to +25%                |
| Spanish         | +15% to +25%                |
| Italian         | +15% to +25%                |
| Portuguese      | +15% to +30%                |
| Russian         | +15% to +25%                |
| Arabic          | +0% to +25%                 |
| Japanese        | −30% to −50%                |
| Chinese         | −30% to −50%                |
| Korean          | −10% to −20%                |

**Rule:** Flag any translation that exceeds 150% of the source string length (configurable). Short strings (buttons, labels) are more sensitive — a 2-word English button becoming a 5-word German button will almost certainly overflow.

---

## Translation Quality Checklist

Before finalizing translations, verify:

- [ ] All placeholders preserved and untranslated
- [ ] Correct plural forms for the target language (check CLDR table)
- [ ] Formality level consistent across all strings
- [ ] No English words left untranslated (unless they're brand names or universally used tech terms)
- [ ] Punctuation follows target language conventions
- [ ] Numbers and dates follow target locale formatting
- [ ] RTL languages have proper directional markers where needed
- [ ] No machine-translation artifacts (unnatural phrasing, literal translations of idioms)
- [ ] Glossary terms used consistently
- [ ] UI strings are concise enough to fit their containers
