## 🎨 Task: Execute Complete UI/UX Overhaul & Design System Standardization

Assignee: [@omararef775](https://github.com/omararef775)
Goal: Elevate the visual identity, accessibility, and interaction design of the "Shams" mobile application (`shams_mobile_app`) under Clean Architecture (`app/`, `core/`, `features/`). This overhaul eliminates severe WCAG AA contrast failures across buttons/links (`1.6:1` → `7.4:1`), standardizes heterogeneous and illegible `AppBar` treatments across root tabs and sub-screens (resolving dark-on-dark titles and uncoordinated yellow headers), fixes system status bar visibility across themes, aligns bottom navigation icons and labels with actual destinations (`Following` → `Chats`), harmonizes modal bottom sheet structures and form layouts, and ensures strict adherence to architectural layer boundaries (`tool/check_architecture.dart`), dynamic RTL/LTR ergonomics (`EdgeInsetsDirectional`, `AlignmentDirectional`), and Supabase database constant compatibility.

### 📝 Task Checklist

#### 1. Design System & Theme Foundations (`lib/core/theme/` & `lib/core/widgets/`)
- **Theme Configuration (`lib/core/theme/shams_theme.dart` & `lib/core/theme/shams_colors.dart`):**
  - Configure `systemOverlayStyle` in `ShamsTheme.light.appBarTheme` with `SystemUiOverlayStyle.dark` (dark status bar icons) and in `ShamsTheme.dark.appBarTheme` with `SystemUiOverlayStyle.light` (light status bar icons) to prevent status bar metrics from disappearing on light scaffold backgrounds.
  - Audit `ShamsExtendedColors`: ensure `cardSurface` in dark mode (`0xFF1A1A28`) retains sufficient visual separation from scaffold background (`0xFF0E0E18`) by defining a standard elevation outline `borderLight` (`0xFF2C2C3E`).
  - Architectural rule: all colors must be sourced from `ShamsColors` / `ShamsExtendedColors` or `Theme.of(context).colorScheme`. Do not hardcode raw hex codes or direct `Colors.*` in presentation widgets.
- **Button Standards (`lib/core/widgets/outlined_button.dart` & `lib/core/widgets/primary_button.dart`):**
  - Update `CustomOutlinedButton` (`lib/core/widgets/outlined_button.dart`) default styling from `colorScheme.secondary` (`#FFC53D`) to `colorScheme.primary` (`#0052CC` in light, `#6BA3FF` in dark) with a matching `1.5dp` border. This resolves the severe `1.6:1` contrast defect on white/light backgrounds, achieving WCAG AAA compliance (`7.4:1`).
  - Preserve `CustomSolidButton` with filled `colorScheme.secondary` and dark text `colorScheme.onSecondary` (`0xFF3D2C00`), ensuring minimum touch target height of `50dp` (Fitts's Law).
- **Core Platform App Bar (`lib/core/widgets/appbar.dart`):**
  - Refactor `ShamsPlatformAppBar` layout: balance the horizontal actions width on both ends (`SizedBox(width: 76)`) or utilize a centered `Positioned` logo to ensure the `Shams` brandmark is mathematically centered on all device aspect ratios.
  - Add a subtle bottom divider `Border(bottom: BorderSide(color: ext.dividerLight, width: 1.0))` to cleanly separate the bar from scrolling sliver headers.

#### 2. Shell Navigation & Root Infrastructure (`lib/app/` & `lib/core/widgets/`)
- **Bottom Navigation Bar (`lib/core/widgets/shams_bottom_nav_bar.dart`):**
  - Update `ShamsBottomNavBar.defaultItems[2]`: replace `Icons.people_alt_rounded` / `Icons.people_alt_outlined` and key `'followNav'` with `Icons.chat_bubble_rounded` / `Icons.chat_bubble_outline_rounded` and label key `'chatsTitle'` / `'myChats'`.
  - Connect the localized label resolution in `_resolveLabel` to `l10n.chatsTitle` (`'المحادثات'` / `'Chats'`) so the third tab accurately reflects its destination screen (`ChatListScreen`).
- **Main Screen & Drawer Integration (`lib/app/main_screen.dart` & `lib/core/widgets/shams_drawer.dart`):**
  - Re-structure `ShamsDrawer` header gradient: replace the low-contrast bottom endpoint (`colorScheme.primaryContainer`) with a coherent deep blue gradient (`Color(0xFF003D99)` to `Color(0xFF0052CC)`), ensuring user name and email text achieve high contrast (`> 7:1`).
  - Add logical grouping in drawer items: insert subtle dividers/headers separating main navigation tabs (`Home`, `Workshops`, `My Chats`) from account & support utilities (`Edit My Profile`, `About Shams Platform`, `Technical Support`).
  - Ensure opening the drawer properly overlays the viewport without visual clipping against `ShamsBottomNavBar`.

#### 3. Authentication & Onboarding Visual Polish (`lib/features/auth/presentation/screens/`)
- **Welcome Screen (`lib/features/auth/presentation/screens/welcome.dart`):**
  - Change `l10n.appTitle` (`'شمس'`) color from `colorScheme.secondary` (`#FFC53D`) to `colorScheme.primary` (`#0052CC`) to establish brand hierarchy against light background `#F5F7FF`.
  - Update the terms notice text from static `Color(0xFFBFC3CE)` to `Theme.of(context).extension<ShamsExtendedColors>()!.textHint` / `colorScheme.onSurfaceVariant` for dynamic theme adaptability and WCAG AA contrast.
  - Outlined button for `'تسجيل الدخول'` automatically inherits the enhanced `CustomOutlinedButton` primary blue outline.
- **Sign In & Sign Up Screens (`lib/features/auth/presentation/screens/signin.dart` & `signup.dart`):**
  - Align card architecture between both screens: place the `'Or'` divider and Google authentication button inside the elevated white card container in both screens.
  - Update the Google button styling to use a clean neutral border `ext.borderLight` with standard dark text `colorScheme.onSurface` and Google icon instead of washed-out yellow borders.
  - Switch footer navigation links (`'تسجيل الدخول'` / `'إنشاء حساب'`) to `colorScheme.primary` with `FontWeight.w700`.

#### 4. Feed & Community Experience (`lib/features/posts/` & `lib/features/chat/`)
- **Post Card & Feed Screen (`lib/features/posts/presentation/widgets/post_card.dart` & `home_screen.dart`):**
  - Update `_buildImageCarousel` in `PostCard`: add horizontal padding (`padding: const EdgeInsets.symmetric(horizontal: 14)`) so media matches the text/header margins, with `borderRadius: BorderRadius.circular(14)`.
  - Add an optional relative time display (`timeAgoText`) in `_buildHeader` next to the user handle (`@handle • 2h`).
  - Enrich the bottom action row: add a share action icon (`Icons.share_outlined`) with touch feedback on the trailing side, balancing the like/comment chips.
  - Add subtle border in dark mode (`border: Border.all(color: ext.borderLight, width: 0.8)`) to define card boundaries against dark surface.
- **Post Detail Screen & Comments (`lib/features/posts/presentation/screens/post_detail_screen.dart` & `widgets/comments_component.dart`):**
  - Replace the custom yellow app bar (`color: colorScheme.secondary`) in `PostDetailScreen` with standard `AppBar` (`color: colorScheme.surface`, elevation `0.5`, `colorScheme.onSurface` title and back icon) matching platform consistency.
  - Modernize `CommentsComponent` input bar: harmonize input field and send button height to `48dp`, using circular radii and smooth focus states.
- **Chat List Screen (`lib/features/chat/presentation/screens/chat_list_screen.dart`):**
  - Replace the custom blue app bar (`backgroundColor: colorScheme.primary` with dark unreadable text) with `ShamsPlatformAppBar` or standard surface `AppBar` (`backgroundColor: colorScheme.surface`, `foregroundColor: colorScheme.onSurface`).
  - Upgrade the empty chats state: wrap `Icons.chat_bubble_outline_rounded` in a styled circular container (`width: 84, height: 84, color: colorScheme.primaryContainer.withValues(alpha: 0.3)`) and add a primary button (`l10n.exploreWorkshops`) navigating to the workshops tab.

#### 5. Workshops Directory, Profile & Maintenance Flow (`lib/features/workshops/presentation/`)
- **Workshops Directory (`lib/features/workshops/presentation/screens/workshops_list_screen.dart` & `widgets/workshop_card.dart`):**
  - Enhance service filter chips (`lib/features/workshops/presentation/screens/workshops_list_screen.dart`): give unselected chips a clear container background (`ext.chipBackground`), subtle border (`ext.borderLight`), and rounded radius (`20dp`) so they read as interactive filters rather than plain text.
  - Refactor `WorkshopCard` action buttons: designate `'عرض الورشة'` (`View Workshop`) as the sole filled primary CTA (`colorScheme.secondary`), and refactor `'متابعة'` (`Follow`) into an outlined secondary CTA (`colorScheme.primary` border/text when unfollowed, and a subdued chip with `Icons.check_rounded` when following).
  - Ensure `userHandle` is prefixed with `'@'` consistently.
- **Workshop Profile Screen (`lib/features/workshops/presentation/screens/workshop_profile_screen.dart`):**
  - Reposition `'طلب صيانة الآن'` (`Request Maintenance Now`) from a floating action button that occludes `'سجل الأعمال'` (`Work Log`) to a pinned `bottomNavigationBar` inside a shaded `Container` with `SafeArea` (matching `WorkshopDashboardScreen`).
- **Maintenance & Review Sheets (`lib/features/workshops/presentation/widgets/profile/`):**
  - `maintenance_request_sheet.dart`: Add leading descriptive icons (`Icons.build_circle_outlined`, `Icons.electrical_services_rounded`, `Icons.battery_charging_full_rounded`, `Icons.bolt_rounded`, `Icons.description_outlined`) to input fields and dropdowns so labels remain clear after value selection.
  - `review_editor_sheet.dart`: Harmonize bottom action buttons into two equal-width actions (`CustomSolidButton` for publish, `CustomOutlinedButton` for cancel).
- **Add Workshop Screen (`lib/features/workshops/presentation/screens/add_workshop_screen.dart`):**
  - Standardize height across row fields (`Years of Experience` text field and `Governorate` dropdown) by matching content padding (`52dp` target).
  - Change camera icon & text label on avatar upload circle from washed-out yellow to high-contrast `colorScheme.primary`.

#### 6. User Profile, Settings & Modal Dialogs (`lib/features/profile/presentation/`)
- **Profile Header Card (`lib/features/profile/presentation/widgets/profile_header_card.dart`):**
  - Hide the location pin icon when `currentUser.location` is null or empty to prevent lone orphan icons.
  - Update `'تعديل الملف'` (`Edit Profile`) button colors from yellow-on-light (`#FFC53D`) to `colorScheme.primary` text/border for crisp readability.
- **Edit Profile Screen (`lib/features/profile/presentation/screens/edit_profile_screen.dart`):**
  - Expose the city selector dropdown in the UI bound to `_selectedLocation` and `ShamsConstants.yemeniCities` so users can view and update their city.
  - Change the camera badge icon color on avatar from `Colors.white` to `colorScheme.onSecondary`.
- **Profile Bottom Sheets & Utilities (`lib/features/profile/presentation/widgets/profile_bottom_sheets.dart` & `screens/`):**
  - `showProfileLanguageSheet`: Replace multi-select `Checkbox` with single-selection radio circles (`Icons.check_circle_rounded` / `Icons.radio_button_unchecked_rounded`) with highlighted card border for active selection.
  - `showProfileSupportSheet`: Restructure WhatsApp, phone call, and email options as styled interactive tiles with subtitle values and directional chevrons (`Icons.arrow_forward_ios_rounded`).
  - `privacy_security_screen.dart`: Convert `'Full Privacy Policy'` link to an `OutlinedButton.icon` with `Icons.open_in_new_rounded`.
  - `about_shams_screen.dart`: Allow feature card titles (`Easy Access`, `Sustainability`, `Direct Workshop`) to wrap cleanly in 2 lines with centered alignment without horizontal text truncation.

#### 7. Testing & Verification Gates (Gate G1 + CI)
- Add widget tests under `test/core/widgets/` verifying:
  - `CustomOutlinedButton` renders with primary theme color and accessible contrast.
  - `ShamsBottomNavBar` renders third item with chat icon and label.
- Add widget tests under `test/features/posts/presentation/widgets/post_card_test.dart` and `test/features/workshops/presentation/widgets/workshop_card_test.dart` verifying button hierarchies and layouts.
- Run and pass all required CI gates locally before pushing:
  ```powershell
  flutter pub get
  dart run tool/check_architecture.dart
  flutter analyze
  flutter test
  flutter build apk --debug --dart-define-from-file=env/dev.json
  ```

### 📂 Key Directory & File Paths
- **Design Tokens & Theme:** `lib/core/theme/shams_colors.dart`, `lib/core/theme/shams_theme.dart`
- **Core Widgets & Shell:** `lib/core/widgets/outlined_button.dart`, `lib/core/widgets/primary_button.dart`, `lib/core/widgets/appbar.dart`, `lib/core/widgets/shams_bottom_nav_bar.dart`, `lib/core/widgets/shams_drawer.dart`, `lib/app/main_screen.dart`
- **Auth UI:** `lib/features/auth/presentation/screens/welcome.dart`, `lib/features/auth/presentation/screens/signin.dart`, `lib/features/auth/presentation/screens/signup.dart`
- **Feed & Posts UI:** `lib/features/posts/presentation/screens/home_screen.dart`, `lib/features/posts/presentation/widgets/post_card.dart`, `lib/features/posts/presentation/screens/post_detail_screen.dart`, `lib/features/posts/presentation/widgets/comments_component.dart`
- **Workshops UI:** `lib/features/workshops/presentation/screens/workshops_list_screen.dart`, `lib/features/workshops/presentation/widgets/workshop_card.dart`, `lib/features/workshops/presentation/screens/workshop_profile_screen.dart`, `lib/features/workshops/presentation/widgets/profile/maintenance_request_sheet.dart`, `lib/features/workshops/presentation/widgets/profile/review_editor_sheet.dart`, `lib/features/workshops/presentation/screens/add_workshop_screen.dart`
- **Chat & Notifications UI:** `lib/features/chat/presentation/screens/chat_list_screen.dart`, `lib/features/notifications/presentation/screens/notifications_screen.dart`
- **Profile & Settings UI:** `lib/features/profile/presentation/screens/user_profile_screen.dart`, `lib/features/profile/presentation/widgets/profile_header_card.dart`, `lib/features/profile/presentation/screens/edit_profile_screen.dart`, `lib/features/profile/presentation/widgets/profile_bottom_sheets.dart`, `lib/features/profile/presentation/screens/privacy_security_screen.dart`, `lib/features/profile/presentation/screens/about_shams_screen.dart`
- **Verification Tests:** `test/core/theme/*`, `test/core/widgets/*`, `test/features/posts/presentation/widgets/*`, `test/features/workshops/presentation/widgets/*`

### 🛠️ Execution Steps (Git Flow)
```powershell
# 1. Update local main
git checkout main
git pull origin main

# 2. Create the feature branch
git checkout -b refactor/ui-ux-design-system-overhaul

# 3. Review status and commit logically (foundation & core widgets first, then feature UI screens, then tests)
git status
git add lib/core/theme/ lib/core/widgets/ lib/app/
git commit -m "refactor(ui): elevate core theme tokens, status bar style, outlined buttons, and shell navigation"

# Commit feature-specific screen polishes
git add lib/features/
git commit -m "refactor(presentation): standardize app bars, cards, bottom sheets, and form contrast across features"

# Commit test coverage
git add test/
git commit -m "test(ui): add widget tests for core button contrast, navigation items, and card actions"

# 4. Run verification gates before pushing
dart run tool/check_architecture.dart
flutter analyze
flutter test

# 5. Push to remote
git push -u origin refactor/ui-ux-design-system-overhaul
```

