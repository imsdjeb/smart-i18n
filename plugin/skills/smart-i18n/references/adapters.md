# Framework Adapters Reference

## Detection Signals & Configuration

### Flutter

| Property | Value |
|----------|-------|
| Detection | `pubspec.yaml` exists |
| Libraries | `flutter_localizations` (built-in), `easy_localization`, `slang` |
| Locales dir | `lib/l10n` (built-in), `assets/translations` (easy_localization) |
| File format | ARB (Application Resource Bundle) |
| Key style | camelCase (required by ARB codegen) |

**Code patterns:**
```dart
// flutter_localizations (built-in)
AppLocalizations.of(context)!.welcomeMessage

// easy_localization
'welcome_message'.tr()
context.tr('welcome_message')

// slang
t.welcomeMessage
```

**Init steps:**
1. Add `flutter_localizations` and `intl` to `pubspec.yaml` dependencies
2. Add `generate: true` to `pubspec.yaml` flutter section
3. Create `l10n.yaml` with `arb-dir: lib/l10n` and `template-arb-file: app_en.arb`
4. Create `lib/l10n/app_en.arb` with base translations
5. Add `localizationsDelegates` and `supportedLocales` to `MaterialApp`

**ARB format example:**
```json
{
  "@@locale": "en",
  "welcomeMessage": "Welcome, {name}!",
  "@welcomeMessage": {
    "description": "Greeting on the home screen",
    "placeholders": {
      "name": {
        "type": "String",
        "example": "John"
      }
    }
  },
  "itemCount": "{count, plural, =0{No items} =1{1 item} other{{count} items}}",
  "@itemCount": {
    "description": "Item count label",
    "placeholders": {
      "count": {
        "type": "int"
      }
    }
  }
}
```

---

### Angular

| Property | Value |
|----------|-------|
| Detection | `angular.json` exists |
| Libraries | `@ngx-translate/core`, `@angular/localize`, `@ngneat/transloco` |
| Locales dir | `src/assets/i18n` (ngx-translate), `src/locale` (angular-localize) |
| File format | JSON (ngx-translate, transloco), XLF (angular-localize) |

**Code patterns:**
```html
<!-- ngx-translate -->
<h1>{{ 'home.title' | translate }}</h1>
<p [translate]="'home.description'"></p>
<!-- with params -->
<p>{{ 'home.greeting' | translate:{ name: userName } }}</p>

<!-- @angular/localize -->
<h1 i18n="@@homeTitle">Welcome</h1>
<!-- in TypeScript -->
$localize`:@@homeTitle:Welcome`

<!-- transloco -->
<h1>{{ t('home.title') }}</h1>
<ng-container *transloco="let t">{{ t('home.title') }}</ng-container>
```

**Init steps (ngx-translate):**
1. `npm install @ngx-translate/core @ngx-translate/http-loader`
2. Import `TranslateModule` in app module with `HttpLoaderFactory`
3. Create `src/assets/i18n/en.json`
4. Set default language in app component

---

### React

| Property | Value |
|----------|-------|
| Detection | `react` in `package.json` dependencies |
| Libraries | `react-i18next`, `react-intl` (FormatJS), `@lingui/react` |
| Locales dir | `public/locales` (i18next), `src/lang` (react-intl), `src/locales` (lingui) |
| File format | JSON (i18next, react-intl), PO (lingui) |

**Code patterns:**
```tsx
// react-i18next
import { useTranslation } from 'react-i18next';
const { t } = useTranslation();
<h1>{t('home.title')}</h1>
<p>{t('home.greeting', { name: userName })}</p>
// namespace
const { t } = useTranslation('dashboard');
<h1>{t('stats.title')}</h1>

// react-intl
import { FormattedMessage, useIntl } from 'react-intl';
<FormattedMessage id="home.title" defaultMessage="Welcome" />
const intl = useIntl();
intl.formatMessage({ id: 'home.title' })

// lingui
import { Trans, t } from '@lingui/macro';
<Trans id="home.title">Welcome</Trans>
const msg = t`Welcome`;
```

**Init steps (react-i18next):**
1. `npm install react-i18next i18next i18next-http-backend i18next-browser-languagedetector`
2. Create `src/i18n.ts` config file
3. Create `public/locales/en/translation.json`
4. Import i18n config in entry point

---

### Next.js

| Property | Value |
|----------|-------|
| Detection | `next.config.*` exists |
| Libraries | `next-intl`, `next-i18next` |
| Locales dir | `messages` (next-intl), `public/locales` (next-i18next) |
| File format | JSON |

**Code patterns:**
```tsx
// next-intl (App Router)
import { useTranslations } from 'next-intl';
const t = useTranslations('HomePage');
<h1>{t('title')}</h1>
<p>{t('greeting', { name: userName })}</p>

// next-intl (Server Component)
import { getTranslations } from 'next-intl/server';
const t = await getTranslations('HomePage');

// next-i18next (Pages Router)
import { useTranslation } from 'next-i18next';
const { t } = useTranslation('common');
<h1>{t('home.title')}</h1>
```

**Init steps (next-intl, App Router):**
1. `npm install next-intl`
2. Create `messages/en.json`
3. Create `i18n/request.ts` config
4. Add `createMiddleware` for locale routing in `middleware.ts`
5. Update `next.config.ts` with `createNextIntlPlugin`
6. Wrap layout with `NextIntlClientProvider`

---

### Vue

| Property | Value |
|----------|-------|
| Detection | `vue` in `package.json` dependencies |
| Libraries | `vue-i18n` |
| Locales dir | `src/locales` |
| File format | JSON |

**Code patterns:**
```vue
<!-- template -->
<h1>{{ $t('home.title') }}</h1>
<p>{{ $t('home.greeting', { name: userName }) }}</p>

<!-- Composition API -->
<script setup>
import { useI18n } from 'vue-i18n';
const { t } = useI18n();
</script>
<template>
  <h1>{{ t('home.title') }}</h1>
</template>
```

**Init steps:**
1. `npm install vue-i18n`
2. Create `src/locales/en.json`
3. Create `src/i18n.ts` with `createI18n()`
4. Register in `main.ts` with `app.use(i18n)`

---

### Nuxt

| Property | Value |
|----------|-------|
| Detection | `nuxt.config.*` exists |
| Libraries | `@nuxtjs/i18n` |
| Locales dir | `locales` |
| File format | JSON |

**Code patterns:**
```vue
<!-- template (same as Vue) -->
<h1>{{ $t('home.title') }}</h1>

<!-- Composition API -->
<script setup>
const { t } = useI18n();
</script>
```

**Init steps:**
1. `npx nuxi module add @nuxtjs/i18n`
2. Configure in `nuxt.config.ts` i18n module options
3. Create `locales/en.json`

---

### Svelte

| Property | Value |
|----------|-------|
| Detection | `svelte.config.*` exists |
| Libraries | `svelte-i18n`, `paraglide-js` |
| Locales dir | `src/lib/i18n` (svelte-i18n), `messages` (paraglide) |
| File format | JSON |

**Code patterns:**
```svelte
<!-- svelte-i18n -->
<script>
  import { _ } from 'svelte-i18n';
</script>
<h1>{$_('home.title')}</h1>
<p>{$_('home.greeting', { values: { name: userName } })}</p>

<!-- paraglide-js -->
<script>
  import * as m from '$lib/paraglide/messages';
</script>
<h1>{m.homeTitle()}</h1>
```

---

### Django

| Property | Value |
|----------|-------|
| Detection | `manage.py` exists |
| Libraries | `gettext` (built-in) |
| Locales dir | `locale` |
| File format | PO (Portable Object) |

**Code patterns:**
```python
# views.py
from django.utils.translation import gettext as _
message = _("Welcome to the dashboard")

# templates
{% load i18n %}
{% trans "Welcome" %}
{% blocktrans with name=user.name %}Hello, {{ name }}!{% endblocktrans %}
```

**Init steps:**
1. Add `'django.middleware.locale.LocaleMiddleware'` to MIDDLEWARE
2. Set `LANGUAGE_CODE`, `LANGUAGES`, `LOCALE_PATHS` in settings.py
3. Run `django-admin makemessages -l fr`

---

### Rails

| Property | Value |
|----------|-------|
| Detection | `Gemfile` with `rails` |
| Libraries | `rails-i18n` (built-in i18n gem) |
| Locales dir | `config/locales` |
| File format | YAML |

**Code patterns:**
```ruby
# views (ERB)
<h1><%= t('.title') %></h1>
<p><%= t('home.greeting', name: @user.name) %></p>

# controllers/models
I18n.t('flash.created')

# lazy lookup (in views, scoped to controller/action)
t('.success')  # resolves to controller.action.success
```

**Init steps:**
1. `bundle add rails-i18n`
2. Set `config.i18n.default_locale` and `config.i18n.available_locales` in `application.rb`
3. Create `config/locales/en.yml`

---

## Interpolation Format Comparison

| Framework | Simple | Plural | Select |
|-----------|--------|--------|--------|
| react-i18next | `{name}` | `{{count}} item` + key_plural | ICU via i18next-icu |
| react-intl | `{name}` | `{count, plural, one {# item} other {# items}}` | `{gender, select, male {He} female {She} other {They}}` |
| vue-i18n | `{name}` | `{count} item \| {count} items` | linked messages |
| next-intl | `{name}` | ICU MessageFormat | ICU MessageFormat |
| Angular (ngx-translate) | `{{name}}` | custom pipe | — |
| Angular (localize) | `{$name}` | ICU in XLF | ICU in XLF |
| Flutter (ARB) | `{name}` | `{count, plural, =0{None} =1{One} other{{count}}}` | `{gender, select, male{His} female{Her} other{Their}}` |
| svelte-i18n | `{name}` | ICU MessageFormat | ICU MessageFormat |
| Django (gettext) | `%(name)s` | `ngettext` | — |
| Rails (YAML) | `%{name}` | `count` key with `one:/other:` | — |
