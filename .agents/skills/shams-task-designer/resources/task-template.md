# Shams Task Template & Gold-Standard Reference

## 1. Reusable Task Markdown Skeleton

```markdown
## <Emoji> Task: <Action-Oriented Task Title>
Assignee: [@<github_username>](https://github.com/<github_username>)
Goal: <1-paragraph technical goal describing the feature/fix in the "Shams" platform under Clean Architecture (`app/`, `core/`, `features/`), naming the key classes/providers/layers involved, and highlighting architectural constraints (`tool/check_architecture.dart`, `domain/` purity, DB compatibility, RTL/LTR behavior).>

### 📝 Task Checklist

#### 1. <Phase 1: Setup / Configuration / Domain Layer> (`<target/path/>`)
- **<Sub-area 1> (`<path/to/file>`):**
  - <Concrete instruction with exact class/method/config details.>
  - <Explicit architectural warning if applicable (e.g., `tool/check_architecture.dart` constraint).>
- **<Sub-area 2> (`<path/to/file>`):**
  - <Concrete instruction.>

#### 2. <Phase 2: Data Layer / State Management / Persistence & DI> (<Mirroring `existing/module/` if applicable>)
- **`<ClassName>` (`<lib/path/to/file.dart>`):**
  - <Implementation details, methods, keys, return types.>
- **`<ProviderOrRepositoryName>` (`<lib/path/to/file.dart>`):**
  - <State properties, methods, use cases consumed.>
- **DI & Composition Root:**
  - Register `<Dependency>` inside `_init<Scope>()` in `lib/core/di/injection.dart` (`sl.registerLazySingleton...`).
  - Wire provider in `lib/main.dart` and/or `lib/app/app_providers.dart`.

#### 3. <Phase 3: App Shell / Core Helpers / Layer-Safe Business Logic> (`<target/path/>`)
- **<Target Component> (`<lib/path/to/file.dart>`):**
  - <Exact changes required.>
  - <Layer boundary protection: keep `domain/` Flutter-free, use `package:shams_mobile_app/...` imports, preserve Supabase DB constants.>

#### 4. <Phase 4: UI Wiring & Dynamic RTL/LTR Audit>
- **<Feature Screen/Widget Group>:**
  - `lib/features/<feature>/presentation/screens/<screen>.dart`: <Exact state wiring and UI changes.>
  - `lib/features/<feature>/presentation/widgets/<widget>.dart`: <Exact widget updates, localization, and directional layout rules (`EdgeInsetsDirectional`, `AlignmentDirectional`).>

#### 5. Testing & Verification Gates (Gate G1 + CI)
- Add unit tests under `test/<path>/` (`<test_file_1>.dart`, `<test_file_2>.dart`) and widget tests verifying <key user flows>.
- Run and pass all required CI gates locally before pushing:
  ```powershell
  flutter pub get
  dart run tool/check_architecture.dart
  flutter analyze
  flutter test
  flutter build apk --debug --dart-define-from-file=env/dev.json
  ```

### 📂 Key Directory & File Paths
- **Config & Rules:** `<paths>`
- **<Feature/Module> Core (New):** `<paths>`
- **DI & App Shell:** `<paths>`
- **Core Helpers & UI:** `<paths>`
- **<Feature> UI:** `<paths>`
- **Feature UI & Tests:** `<paths>`

### 🛠️ Execution Steps (Git Flow)
```powershell
# 1. Update local main
git checkout main
git pull origin main

# 2. Create the feature branch
git checkout -b <type>/<task-slug>

# 3. Review status and commit logically (<describe commit split>)
git status
git add <foundation-and-di-paths>
git commit -m "<type>(<scope>): <logical commit 1 message>"

# Commit UI wiring, feature changes, and tests cleanly
git add <feature-and-test-paths>
git commit -m "<type>(<scope>): <logical commit 2 message>"

# 4. Run verification gates before pushing
dart run tool/check_architecture.dart
flutter analyze
flutter test

# 5. Push to remote
git push -u origin <type>/<task-slug>
```
```

---

## 2. Gold-Standard Example

```markdown
## 🌍 Task: Implement Full English Localization & Dynamic RTL/LTR Switching
Assignee: [@omararef775](https://github.com/omararef775)
Goal: Introduce full bilingual support (Arabic & English) to the "Shams" platform under the Clean Architecture structure (`app/`, `core/`, `features/`). This includes configuring Flutter localization under `lib/core/l10n/` (to satisfy `tool/check_architecture.dart`), extracting hardcoded Arabic strings into `.arb` files, persisting the active `Locale` via `LanguageStorage` + `LanguageProvider`, translating domain/validation/formatter outputs without breaking `domain/` purity or DB filter values, and auditing all hardcoded `TextDirection.rtl` wrappers and directional paddings/alignments.

### 📝 Task Checklist

#### 1. Localization Setup (`core/l10n/`)
- **Dependencies & Generation (`pubspec.yaml` & `l10n.yaml`):**
  - `flutter_localizations` is already declared in `pubspec.yaml`; add `intl: any` under `dependencies` and enable `generate: true` under the `flutter:` section.
  - Create `l10n.yaml` in the project root configured so files stay inside `lib/core/l10n/` (**do not** create a top-level `lib/l10n/` folder because `tool/check_architecture.dart` only allows `app/`, `core/`, `features/`, and `main.dart` directly under `lib/`):
    ```yaml
    arb-dir: lib/core/l10n
    template-arb-file: app_ar.arb
    output-dir: lib/core/l10n/generated
    output-localization-file: app_localizations.dart
    output-class: AppLocalizations
    ```
- **ARB Files:** Create `lib/core/l10n/app_ar.arb` (template Arabic strings) and `lib/core/l10n/app_en.arb` (English translations).

#### 2. State Management, Persistence & DI (Mirroring `core/theme/`)
- **`LanguageStorage` (`lib/core/l10n/language_storage.dart`):**
  - Follow `lib/core/theme/theme_storage.dart` using `SharedPreferences` (e.g., key `'shams_locale'`) with `loadLocale()` and `saveLocale(Locale locale)`.
  - Update `_sharedPrefsAllowedPaths` in `tool/check_architecture.dart` to allow `^lib/core/l10n/language_storage\.dart$` (alongside `theme_storage.dart`).
- **`LanguageProvider` (`lib/core/l10n/language_provider.dart`):**
  - Extend `ChangeNotifier` (mirroring `ThemeProvider`) with default `Locale('ar', 'SA')`, `currentLocale`, `isArabic`, `loadSavedLocale()`, and `changeLanguage(Locale locale)`.
- **DI & Composition Root:**
  - Register `LanguageStorage` inside `_initCore()` in `lib/core/di/injection.dart` (`sl.registerLazySingleton<LanguageStorage>(() => LanguageStorage(sl()));`).
  - Instantiate `LanguageProvider(sl())` and `await languageProvider.loadSavedLocale()` in `lib/main.dart`, then pass `languageProvider` into `AppProviders`.
  - Add `ChangeNotifierProvider.value(value: languageProvider)` in `lib/app/app_providers.dart`.

#### 3. App Shell Configuration (`lib/app/app.dart`)
- `supportedLocales` (`Locale('ar', 'SA')`, `Locale('en', 'US')`) and `localizationsDelegates` are already set up in `ShamsApp` (`lib/app/app.dart`).
- Update `ShamsApp.build` to watch `LanguageProvider`:
  - Replace hardcoded `locale: const Locale('ar', 'SA')` with `locale: context.watch<LanguageProvider>().currentLocale`.
  - Add `AppLocalizations.delegate` to `localizationsDelegates`.
  - Replace hardcoded `title: 'شمس'` with `onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle`.

#### 4. String Extraction & Layer-Safe Translation
- **Presentation Layer (`lib/core/widgets/` & `lib/features/*/presentation/`):**
  - Sweep all screens and modular widgets under `auth`, `chat`, `maintenance`, `notifications`, `posts`, `profile`, `workshops`, and `core/widgets` to replace hardcoded Arabic strings with `AppLocalizations.of(context)!`.
  - Remember `always_use_package_imports`: import localization using `package:shams_mobile_app/core/l10n/...`.
- **Formatters (`lib/core/utils/formatters.dart`):**
  - Localize `formatRelativeTime` outputs (`'الآن'`, `'منذ ... دقيقة/ساعة/يوم'`) by passing locale or localized labels from presentation rather than hardcoding Arabic inside the formatter.
- **Domain Constants (`lib/core/constants/app_constants.dart`):**
  - Keep stored database values (`yemeniCities`, `solarServiceTypes`, `inverterBrands`, `batteryTypes`) unchanged when querying/writing to Supabase, and map them to localized display labels in the UI so filtering and maintenance requests still match existing Supabase records.
- **Domain Failures & Error Messages (`lib/core/error/` & `features/*/domain/`):**
  - `tool/check_architecture.dart` **forbids importing `package:flutter/` inside `features/*/domain/`**. Do not use `AppLocalizations` or `BuildContext` in domain use cases, repositories, or `Failure` classes.
  - Keep `domain/` Flutter-free (use typed `Failure` subclasses / error codes or map known failure keys to localized messages in `presentation/`, and avoid breaking existing domain/provider unit tests in `test/`).

#### 5. UI Wiring & Dynamic RTL/LTR Audit
- **Enable Language Picker in Profile Feature:**
  - `lib/features/profile/presentation/screens/user_profile_screen.dart`: Remove local `_selectedLanguage` state; read the active language from `LanguageProvider` and wire `showProfileLanguageSheet(..., onSave: ...)` to `context.read<LanguageProvider>().changeLanguage(...)`.
  - `lib/features/profile/presentation/widgets/profile_settings_section.dart`: Update `_LanguagePill` (currently hardcoded `'عربي'`) to show the active language dynamically, and make `_ProfileSettingTile` (`textAlign: TextAlign.right` / directional chevron) direction-aware.
  - `lib/features/profile/presentation/widgets/profile_bottom_sheets.dart`: In `showProfileLanguageSheet`, remove `badgeText: 'قريباً'` and the empty `onTap: () {}` on `English (EN)`, enable `tempLang = 'en'`, localize sheet labels (`'تغيير اللغة'`, `'حفظ'`), and remove the hardcoded `Directionality(textDirection: TextDirection.rtl, ...)`.
- **RTL/LTR Layout Audit:**
  - Remove hardcoded `Directionality(textDirection: TextDirection.rtl, ...)` wrappers across `lib/core/widgets/` (`appbar.dart`, `image_source_sheet.dart`, `inline_search_bar.dart`, `shams_bottom_nav_bar.dart`, `shams_drawer.dart`) and feature screens/widgets (`auth`, `chat`, `notifications`, `posts`, `profile`, `workshops`), letting `MaterialApp.locale` drive directionality automatically. *(Keep explicit `TextDirection.ltr` on inherently LTR inputs such as `username_field.dart` where needed.)*
  - Replace physical directional spacing/alignment (`EdgeInsets.only(left/right: ...)`, `Alignment.centerLeft`/`centerRight`, etc.) with `EdgeInsetsDirectional` and `AlignmentDirectional` across widgets such as `city_filter.dart`, `text_field.dart`, `notification_tile.dart`, `message_bubble.dart`, `post_card.dart`, `about_shams_screen.dart`, `privacy_security_screen.dart`, `edit_profile_screen.dart`, `profile_header_card.dart`, `dashboard_header.dart`, `workshop_work_log_section.dart`, and `workshops_list_screen.dart`.

#### 6. Testing & Verification Gates (Gate G1 + CI)
- Add unit tests under `test/core/l10n/` (`language_storage_test.dart`, `language_provider_test.dart`) and widget tests verifying locale switching & persistence across restarts.
- Run and pass all required CI gates locally before pushing:
  ```powershell
  flutter pub get
  dart run tool/check_architecture.dart
  flutter analyze
  flutter test
  flutter build apk --debug --dart-define-from-file=env/dev.json
  ```

### 📂 Key Directory & File Paths
- **Config & Rules:** `pubspec.yaml`, `l10n.yaml`, `tool/check_architecture.dart`
- **Localization Core (New):** `lib/core/l10n/app_ar.arb`, `lib/core/l10n/app_en.arb`, `lib/core/l10n/language_storage.dart`, `lib/core/l10n/language_provider.dart`
- **DI & App Shell:** `lib/core/di/injection.dart`, `lib/main.dart`, `lib/app/app_providers.dart`, `lib/app/app.dart`
- **Core Helpers & UI:** `lib/core/utils/formatters.dart`, `lib/core/constants/app_constants.dart`, `lib/core/error/failures.dart`, `lib/core/widgets/*`
- **Language Picker UI:** `lib/features/profile/presentation/screens/user_profile_screen.dart`, `lib/features/profile/presentation/widgets/profile_settings_section.dart`, `lib/features/profile/presentation/widgets/profile_bottom_sheets.dart`
- **Feature UI & Tests:** `lib/features/*/presentation/**`, `test/core/l10n/*`

### 🛠️ Execution Steps (Git Flow)
```powershell
# 1. Update local main
git checkout main
git pull origin main

# 2. Create the feature branch
git checkout -b feature/english-localization

# 3. Review status and commit logically (setup first, then extraction & RTL/LTR audit, then tests)
git status
git add pubspec.yaml pubspec.lock l10n.yaml lib/core/l10n/ lib/core/di/injection.dart lib/main.dart lib/app/ tool/check_architecture.dart
git commit -m "feat(l10n): add localization setup, LanguageProvider, and Locale persistence"

# Commit extracted ARB strings, UI wiring, RTL/LTR fixes, and tests cleanly
git add lib/ test/
git commit -m "feat(l10n): extract UI strings and enable dynamic RTL/LTR switching"

# 4. Run verification gates before pushing
dart run tool/check_architecture.dart
flutter analyze
flutter test

# 5. Push to remote
git push -u origin feature/english-localization
```
```

