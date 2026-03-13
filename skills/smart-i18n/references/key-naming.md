# Key Naming Convention

## Structure

```
{feature}.{section}.{element}.{descriptor}
```

**Max depth:** 4 levels (configurable via `maxKeyDepth`).

**Default style:** `snake_case` (configurable via `keyNaming`). Flutter ARB always uses `camelCase` regardless of setting.

---

## Namespace: `common.*`

Shared strings used across multiple features. Always check here before creating a feature-specific key.

### `common.actions.*`

| Key | English |
|-----|---------|
| `common.actions.save` | Save |
| `common.actions.cancel` | Cancel |
| `common.actions.delete` | Delete |
| `common.actions.edit` | Edit |
| `common.actions.create` | Create |
| `common.actions.update` | Update |
| `common.actions.submit` | Submit |
| `common.actions.confirm` | Confirm |
| `common.actions.close` | Close |
| `common.actions.back` | Back |
| `common.actions.next` | Next |
| `common.actions.previous` | Previous |
| `common.actions.search` | Search |
| `common.actions.filter` | Filter |
| `common.actions.sort` | Sort |
| `common.actions.refresh` | Refresh |
| `common.actions.retry` | Retry |
| `common.actions.upload` | Upload |
| `common.actions.download` | Download |
| `common.actions.copy` | Copy |
| `common.actions.share` | Share |
| `common.actions.send` | Send |
| `common.actions.apply` | Apply |
| `common.actions.reset` | Reset |
| `common.actions.sign_in` | Sign in |
| `common.actions.sign_out` | Sign out |
| `common.actions.sign_up` | Sign up |
| `common.actions.continue` | Continue |
| `common.actions.learn_more` | Learn more |
| `common.actions.view_all` | View all |
| `common.actions.show_more` | Show more |
| `common.actions.show_less` | Show less |

### `common.labels.*`

| Key | English |
|-----|---------|
| `common.labels.name` | Name |
| `common.labels.email` | Email |
| `common.labels.password` | Password |
| `common.labels.phone` | Phone |
| `common.labels.address` | Address |
| `common.labels.description` | Description |
| `common.labels.title` | Title |
| `common.labels.date` | Date |
| `common.labels.time` | Time |
| `common.labels.status` | Status |
| `common.labels.type` | Type |
| `common.labels.category` | Category |
| `common.labels.tags` | Tags |
| `common.labels.notes` | Notes |
| `common.labels.total` | Total |
| `common.labels.amount` | Amount |
| `common.labels.quantity` | Quantity |
| `common.labels.price` | Price |
| `common.labels.optional` | Optional |
| `common.labels.required` | Required |

### `common.errors.*`

| Key | English |
|-----|---------|
| `common.errors.generic` | Something went wrong. Please try again. |
| `common.errors.not_found` | Not found |
| `common.errors.unauthorized` | You don't have permission to do this |
| `common.errors.network` | Network error. Check your connection. |
| `common.errors.timeout` | Request timed out. Please try again. |
| `common.errors.required_field` | This field is required |
| `common.errors.invalid_email` | Please enter a valid email address |
| `common.errors.invalid_password` | Password must be at least {min} characters |
| `common.errors.passwords_mismatch` | Passwords don't match |
| `common.errors.file_too_large` | File is too large. Maximum size is {max}. |
| `common.errors.unsupported_format` | This file format is not supported |

### `common.status.*`

| Key | English |
|-----|---------|
| `common.status.loading` | Loading... |
| `common.status.saving` | Saving... |
| `common.status.saved` | Saved |
| `common.status.deleting` | Deleting... |
| `common.status.deleted` | Deleted |
| `common.status.active` | Active |
| `common.status.inactive` | Inactive |
| `common.status.pending` | Pending |
| `common.status.completed` | Completed |
| `common.status.failed` | Failed |
| `common.status.processing` | Processing... |
| `common.status.empty` | No results found |
| `common.status.success` | Success |

### `common.time.*`

| Key | English |
|-----|---------|
| `common.time.today` | Today |
| `common.time.yesterday` | Yesterday |
| `common.time.tomorrow` | Tomorrow |
| `common.time.now` | Now |
| `common.time.ago` | {time} ago |
| `common.time.minutes` | {count, plural, one {# minute} other {# minutes}} |
| `common.time.hours` | {count, plural, one {# hour} other {# hours}} |
| `common.time.days` | {count, plural, one {# day} other {# days}} |

---

## Feature Namespace Examples

### `auth.*`

```
auth.login.heading              → "Sign in to your account"
auth.login.email_placeholder    → "Enter your email"
auth.login.password_placeholder → "Enter your password"
auth.login.forgot_password      → "Forgot password?"
auth.login.remember_me          → "Remember me"
auth.login.no_account           → "Don't have an account?"

auth.register.heading           → "Create your account"
auth.register.terms_agreement   → "I agree to the {terms} and {privacy}"

auth.forgot_password.heading    → "Reset your password"
auth.forgot_password.instruction → "Enter your email and we'll send you a reset link"
auth.forgot_password.sent       → "Check your email for a reset link"

auth.errors.invalid_credentials → "Invalid email or password"
auth.errors.account_locked      → "Account locked. Try again in {minutes} minutes."
```

### `dashboard.*`

```
dashboard.header.title          → "Dashboard"
dashboard.header.welcome        → "Welcome back, {name}"

dashboard.stats.total_users     → "Total users"
dashboard.stats.revenue         → "Revenue"
dashboard.stats.growth          → "{percent}% growth"

dashboard.recent_activity.title → "Recent activity"
dashboard.recent_activity.empty → "No recent activity"
```

### `settings.*`

```
settings.header.title           → "Settings"

settings.profile.title          → "Profile"
settings.profile.avatar_upload  → "Upload avatar"
settings.profile.save_success   → "Profile updated successfully"

settings.notifications.title    → "Notifications"
settings.notifications.email    → "Email notifications"
settings.notifications.push     → "Push notifications"

settings.security.title         → "Security"
settings.security.change_password → "Change password"
settings.security.two_factor    → "Two-factor authentication"

settings.danger_zone.title      → "Danger zone"
settings.danger_zone.delete_account → "Delete account"
settings.danger_zone.delete_warning → "This action cannot be undone"
```

---

## Naming Rules

1. **Use `snake_case`** by default. Only use `camelCase` for Flutter ARB keys.

2. **Max 4 levels of nesting.** If you need more, flatten the middle:
   - ❌ `settings.notifications.email.frequency.daily.label`
   - ✅ `settings.email_notifications.daily_label`

3. **No generic keys.** Every key must be semantically meaningful:
   - ❌ `text1`, `label2`, `message`, `string_42`
   - ✅ `auth.login.heading`, `common.actions.save`

4. **No positional keys:**
   - ❌ `home.section1.title`, `home.section2.title`
   - ✅ `home.hero.title`, `home.features.title`

5. **Use descriptive element names:**
   - `heading` — main heading (h1/h2)
   - `title` — section or card title
   - `subtitle` — secondary text below title
   - `description` — longer explanatory text
   - `label` — form label or UI label
   - `placeholder` — input placeholder
   - `hint` — helper text
   - `tooltip` — tooltip content
   - `button` — button text (when not a common action)
   - `message` — notification or feedback message
   - `error` — error-specific message
   - `success` — success-specific message
   - `empty` — empty state message
   - `confirm` — confirmation dialog text

6. **Deduplication:** Before creating a new key, check if the exact same string already exists:
   - If it's in `common.*`, reuse that key
   - If it's in another feature and truly the same meaning, consider moving it to `common.*`
   - If the wording is the same but the context/meaning differs, create a separate key (translations may differ)

7. **Plurals:** Use a single key with ICU MessageFormat, not separate `_one`/`_other` keys:
   - ❌ `items_one`, `items_other`
   - ✅ `items` → `{count, plural, one {# item} other {# items}}`
   - Exception: if the framework requires separate keys (e.g., Rails YAML), follow its convention

8. **Interpolation:** Name placeholders after the variable they represent:
   - ❌ `"Hello, {0}"` or `"Hello, {arg1}"`
   - ✅ `"Hello, {name}"` or `"Hello, {userName}"`
