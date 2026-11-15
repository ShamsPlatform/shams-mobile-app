# ☀️ Shams Platform | منصة شمس
> **The first specialized solar energy community platform in Yemen.**
> 
> **المنصة المجتمعية الأولى المتخصصة في الطاقة الشمسية في اليمن.**

---

## 📖 Overview | نبذة عن المشروع
**Shams Platform** is a Flutter-based mobile application designed to bridge the gap between solar energy technicians, workshops, and customers in Yemen. It focuses on building a trusted ecosystem through high-quality service documentation and seamless communication.

**منصة شمس** هي تطبيق للهواتف المحمولة مبني باستخدام Flutter، يهدف إلى ردم الفجوة بين فنيي وورش الطاقة الشمسية والعملاء في اليمن. يركز التطبيق على بناء بيئة موثوقة من خلال توثيق جودة الخدمات وتسهيل التواصل المباشر.

---

## 🚀 Key Features | المميزات الرئيسية
- **🛠️ Workshop Hub & Dashboard | دليل ولوحة تحكم الورش:** A dedicated space for technicians to showcase their expertise, specialized services, and contact info, with a dashboard to manage their posts and profile.
  *(مساحة مخصصة للورش لعرض خبراتهم، خدماتهم المتخصصة، ومعلومات التواصل، مع لوحة تحكم لإدارة منشورات الورشة).*
- **📱 Technical Feed | التغذية الفنية:** A social timeline for sharing solar project documentation ("Before & After"), tips, and solar insights with like and comment support.
  *(خط زمني اجتماعي لمشاركة توثيق مشاريع الطاقة الشمسية "قبل وبعد"، النصائح، والرؤى الفنية مع دعم الإعجابات والتعليقات).*
- **💬 Realtime Chats | المحادثات اللحظية:** Seamless, instant messaging between customers and technical workshops powered by Supabase Realtime.
  *(تواصل فوري سلس بين العملاء والورش الفنية مدعوم بنظام Supabase اللحظي).*
- **📝 Maintenance Requests | طلبات الصيانة:** Direct service requests from customers detailing inverter brands, battery types, and service requirements.
  *(طلبات صيانة مباشرة من العملاء تتضمن تفاصيل عن الأجهزة مثل العواكس، أنواع البطاريات، ونوع الخدمة المطلوبة).*
- **⭐ Workshop Reviews & Live Ratings | تقييمات ومراجعات الورش:** Verified workshop reviews and ratings with automatic live rating aggregation and instant UI updates.
  *(تقييمات ومراجعات للورش مع تحديث مباشر لمتوسط التقييم وعدد المراجعات).*
- **🔔 Realtime Notifications | الإشعارات اللحظية:** Live in-app notification inbox for likes, chat messages, and maintenance status updates with unread counters and deep-link navigation.
  *(صندوق إشعارات لحظي للتفاعل والرسائل وتحديثات الصيانة مع شارة غير المقروء والانتقال المباشر).*
- **📍 Location, Service Filtering & Pagination | التصفية الجغرافية والتحميل التدريجي:** Easily filter workshops and technicians by Yemeni governorates and solar service categories, with pull-to-refresh and infinite scroll across the feed and workshop directory.
  *(تصفية الورش والفنيين بسهولة حسب المحافظات اليمنية ونوع الخدمة المطلوبة، مع التحديث بالسحب والتحميل التدريجي للصفحات).*

---

## 🛠️ Tech Stack | التقنيات المستخدمة
- **Frontend | الواجهة الأمامية:** [Flutter](https://flutter.dev/) (Material 3, Multi-platform support)
- **Backend | الواجهة الخارجية:** [Supabase](https://supabase.com/) (PostgreSQL database, Authentication, Storage, RPC, and Realtime listeners)
- **Architecture | الهندسة المعمارية:** Feature-first Clean Architecture (`domain/`, `data/`, `presentation/`) with `get_it` dependency injection (`lib/core/di/injection.dart`), sealed `Result<T>` (`Ok` / `Err`) + typed `Failure` error mapping, and automated boundary checks (`tool/check_architecture.dart` & `.github/workflows/ci.yml`)
- **State Management | إدارة الحالة:** [Provider](https://pub.dev/packages/provider) (`ChangeNotifier` with explicit `ViewStatus` and `Resettable` sign-out lifecycle)
- **Local Storage | التخزين المحلي:** `SharedPreferences` (`ThemeStorage` for persisted theme preference and `AuthLocalDataSource` for clearing legacy session keys on startup while Supabase manages auth sessions)
- **Testing | الاختبارات:** `flutter_test` & `mocktail` unit tests covering models, repositories, use cases, and providers
- **Typography & Theme | الخط والثيم:** Tajawal (via Google Fonts) with Material 3 Light and Dark themes (`ShamsTheme` & `ShamsExtendedColors`)

---

## 🎨 Design System & Colors | نظام التصميم والألوان
The application follows a defined branding palette configured in [shams_colors.dart](lib/core/theme/shams_colors.dart), themed for both light and dark modes in [shams_theme.dart](lib/core/theme/shams_theme.dart), with shared domain lists (cities, solar services, inverter brands, battery types) in [app_constants.dart](lib/core/constants/app_constants.dart):
- **Primary Brand Blue | الأزرق الأساسي:** `#0052CC` (Used for primary buttons, headers, and main actions)
- **Solar Yellow | الأصفر الشمسي:** `#FFC53D` (Used for highlights, ratings, and active indicators)
- **Verified Green | الأخضر الموثق:** `#27AE60` (Used for success states and validation indicators)
- **Danger Red | الأحمر:** `#E53935` / `#BA1A1A` (Used for likes, deletes, and errors)

---

## 📂 Project Structure | هيكلية المشروع
The codebase follows Clean Architecture with an app shell, shared core layer, and isolated vertical feature slices:
```text
lib/
├── main.dart               # Composition root: Env validation, Supabase initialization, DI (`initDependencies`) & `AppProviders` wiring
├── app/                    # App shell, provider tree, auth gate, navigation, session listener
├── core/                   # Shared Env config, constants, Result/Failure/error mapper, DI, theme, shared widgets & storage datasource
└── features/               # Vertical feature modules (domain/ -> data/ <- presentation/)
    ├── auth/               # Sign-in, sign-up, Google OAuth, profile onboarding, auth state
    ├── chat/               # Conversation list, realtime 1:1 messaging, maintenance links
    ├── maintenance/        # Maintenance request submission & validation
    ├── notifications/      # Realtime inbox, read/unread state, deletion
    ├── posts/              # Technical feed, pagination, post creation/editing, comments & likes
    ├── profile/            # User profile, editing, settings, privacy & security, about
    └── workshops/          # Public workshop directory, pagination, profiles, live reviews, owner dashboard

test/
├── core/                   # Core model, ErrorMapper, Result, formatter & theme tests
├── features/               # Unit tests for models, repositories, use cases & ChangeNotifier providers
└── helpers/                # Shared test mocks and helpers

tool/
└── check_architecture.dart # Automated boundary & package-import verifier enforced by CI

docs/
├── clean-architecture-migration-plan.md   # Target architecture, conventions, and Definition of Done
├── clean-architecture-execution-plan.md   # Phased execution log (Phases 0–9), smoke checks & progress tracker
└── baseline/                              # Phase 0 analyzer baseline & read-only screenshot baselines
```

### Layer Responsibilities
- **`domain/`**: Pure Dart entities, repository interfaces, and single-responsibility use cases returning `Result<T>` (`Ok` / `Err` with typed `Failure`). Zero Flutter, `supabase_flutter`, or `shared_preferences` imports.
- **`data/`**: Remote/local data sources (all `Supabase` usage is confined to `data/datasources/`, `core/data/datasources/`, `core/di/`, and `main.dart`; `SharedPreferences` is confined to `data/datasources/`, `core/di/`, and `core/theme/theme_storage.dart`), DTO models (`*Model`), and `RepositoryImpl` classes mapping exceptions via `guard()`/`ErrorMapper`.
- **`presentation/`**: `ChangeNotifier` providers (with `ViewStatus` and `Resettable` session cleanup), screens, and modular UI widgets depending strictly on domain use cases/entities and `core/`.

---

## ⚙️ Running & Verifying the App | تشغيل التطبيق والتحقق
1. Copy [`env/example.json`](env/example.json) to `env/dev.json` and fill in your Supabase credentials:
   - Required: `SUPABASE_URL`, `SUPABASE_ANON_KEY`
   - Optional: `OAUTH_REDIRECT_URL` (defaults to `shams://login-callback/`), `USE_DB_NOTIFICATION_TRIGGERS` (compile-time `bool`, defaults to `true`; pass `--dart-define=USE_DB_NOTIFICATION_TRIGGERS=false` only if running against a database without Option 2 notification triggers).
   - *(Note: `env/*.json` except `env/example.json`, `.env*`, and `*.sql` are excluded by `.gitignore` so secrets and database scripts stay local.)*
2. Run or build using `--dart-define-from-file` (also preconfigured in [`.vscode/launch.json`](.vscode/launch.json)):
   ```powershell
   flutter run --dart-define-from-file=env/dev.json
   ```
   ```powershell
   flutter build apk --debug --dart-define-from-file=env/dev.json
   ```
3. Run the verification gates locally (also enforced on CI via [`.github/workflows/ci.yml`](.github/workflows/ci.yml)):
   ```powershell
   flutter pub get
   dart run tool/check_architecture.dart
   flutter analyze
   flutter test
   ```

---

## 🧩 Adding a New Feature | إضافة ميزة جديدة
When adding a new feature under `lib/features/<feature_name>/`, follow the checklist in [Per-Feature Definition of Done](docs/clean-architecture-migration-plan.md#14-per-feature-definition-of-done):
1. Define immutable entities, abstract repository contract, and use cases under `domain/` with zero `flutter`, `supabase_flutter`, or `shared_preferences` imports.
2. Implement data sources, `*Model` DTOs, and `<Feature>RepositoryImpl` under `data/` using `guard()` / `ErrorMapper` so exceptions never leak across the repository boundary.
3. Implement `ChangeNotifier` providers (using `ViewStatus` + `Resettable` where session-scoped), screens, and focused widgets under `presentation/`.
4. Wire data sources, repositories, use cases, and providers in `lib/core/di/injection.dart` and `lib/app/app_providers.dart`.
5. Add unit tests for models, repository error mapping, use cases, and providers under `test/features/<feature_name>/`.
6. Confirm `dart run tool/check_architecture.dart`, `flutter analyze`, and `flutter test` all pass.

