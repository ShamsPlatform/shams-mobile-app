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
- **📍 Location & Service Filtering | التصفية الجغرافية والخدمية:** Easily filter workshops and technicians by Yemeni governorates and solar service categories.
  *(تصفية الورش والفنيين بسهولة حسب المحافظات اليمنية ونوع الخدمة المطلوبة).*

---

## 🛠️ Tech Stack | التقنيات المستخدمة
- **Frontend | الواجهة الأمامية:** [Flutter](https://flutter.dev/) (Material 3, Multi-platform support)
- **Backend | الواجهة الخارجية:** [Supabase](https://supabase.com/) (PostgreSQL database, Authentication, Storage, and Realtime listeners)
- **Architecture | الهندسة المعمارية:** Feature-first Clean Architecture (`domain/`, `data/`, `presentation/`) with manual dependency injection (`lib/core/di/injection.dart`) and automated boundary checks (`tool/check_architecture.dart`)
- **State Management | إدارة الحالة:** [Provider](https://pub.dev/packages/provider) (`ChangeNotifier`)
- **Local Storage | التخزين المحلي:** `SharedPreferences` (`ThemeStorage` for theme mode persistence and `AuthLocalDataSource` for session preferences)
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
├── main.dart               # Composition root: Supabase initialization & AppDependencies wiring
├── app/                    # App shell, provider tree, auth gate, navigation, session listener
├── core/                   # Shared config, constants, Result/Failure/error mapper, DI, theme, shared widgets & storage datasource
└── features/               # Vertical feature modules (domain/ -> data/ <- presentation/)
    ├── auth/               # Sign-in, sign-up, Google OAuth, profile onboarding, auth state
    ├── chat/               # Conversation list, realtime 1:1 messaging, maintenance links
    ├── maintenance/        # Maintenance request submission & validation
    ├── notifications/      # Realtime inbox, read/unread state, deletion
    ├── posts/              # Technical feed, post creation/editing, comments & likes
    ├── profile/            # User profile, editing, settings, privacy & security, about
    └── workshops/          # Public workshop directory, filtering, profiles, reviews, owner dashboard

test/
├── core/                   # Core model, ErrorMapper, Result, formatter & theme tests
└── features/               # Unit tests for models, repositories, use cases & ChangeNotifier providers
```

### Layer Responsibilities
- **`domain/`**: Pure Dart entities, repository interfaces, and single-responsibility use cases returning `Result<T>` (`Ok` / `Err` with typed `Failure`). Zero Flutter or SDK imports.
- **`data/`**: Remote/local data sources (all `Supabase` and `SharedPreferences` usage is confined here plus `main.dart`, `core/di/`, `core/data/datasources/`, and `core/theme/theme_storage.dart`), DTO models (`*Model`), and `RepositoryImpl` classes mapping exceptions via `guard()`/`ErrorMapper`.
- **`presentation/`**: `ChangeNotifier` providers, screens, and modular UI widgets depending strictly on domain use cases/entities and `core/`.

---

## ⚙️ Running & Verifying the App | تشغيل التطبيق والتحقق
1. Copy `env/example.json` to `env/dev.json` and fill in your Supabase credentials (`SUPABASE_URL`, `SUPABASE_ANON_KEY`, optional `GOOGLE_WEB_CLIENT_ID`).
2. Run or build using `--dart-define-from-file`:
   ```powershell
   flutter run --dart-define-from-file=env/dev.json
   ```
   ```powershell
   flutter build apk --debug --dart-define-from-file=env/dev.json
   ```
3. Run the verification gates locally (also enforced on CI via `.github/workflows/ci.yml`):
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

