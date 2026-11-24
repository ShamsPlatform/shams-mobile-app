import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shams_mobile_app/core/domain/entities/app_user.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/theme/shams_theme.dart';
import 'package:shams_mobile_app/core/widgets/shams_drawer.dart';

Widget _buildTestDrawerApp({
  required AppUser user,
  required int activeIndex,
  Locale locale = const Locale('ar'),
  ValueChanged<int>? onTabSelected,
  VoidCallback? onEditProfileTap,
  VoidCallback? onAboutTap,
  VoidCallback? onSignOut,
  VoidCallback? onWorkshopDashboardTap,
}) {
  return MaterialApp(
    theme: ShamsTheme.light,
    locale: locale,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('ar'),
      Locale('en'),
    ],
    home: Scaffold(
      drawer: ShamsDrawer(
        activeIndex: activeIndex,
        currentUser: user,
        onTabSelected: onTabSelected,
        onEditProfileTap: onEditProfileTap ?? () {},
        onAboutTap: onAboutTap ?? () {},
        onSignOut: onSignOut ?? () {},
        onWorkshopDashboardTap: onWorkshopDashboardTap,
      ),
      body: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          child: const Text('OpenDrawer'),
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  const testUser = AppUser(
    id: 'user-123',
    name: 'أحمد علي',
    email: 'ahmed@shams.ye',
    hasWorkshop: false,
  );

  const workshopUser = AppUser(
    id: 'workshop-123',
    name: 'ورشة السلام',
    email: 'alsalam@shams.ye',
    hasWorkshop: true,
  );

  group('ShamsDrawer Tests', () {
    testWidgets('renders drawer header with user info, badge, and deep blue gradient',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestDrawerApp(user: testUser, activeIndex: 0),
      );
      await tester.pumpAndSettle();

      // Open drawer
      await tester.tap(find.text('OpenDrawer'));
      await tester.pumpAndSettle();

      // Header user name & email
      expect(find.text('أحمد علي'), findsOneWidget);
      expect(find.text('ahmed@shams.ye'), findsOneWidget);
      expect(find.text('عميل شمس ☀️'), findsOneWidget);

      // Verify header Container has deep blue gradient
      final containerFinder = find.byWidgetPredicate((widget) {
        if (widget is Container && widget.decoration is BoxDecoration) {
          final box = widget.decoration as BoxDecoration;
          if (box.gradient is LinearGradient) {
            final gradient = box.gradient as LinearGradient;
            return gradient.colors.contains(const Color(0xFF003D99)) &&
                gradient.colors.contains(const Color(0xFF0052CC));
          }
        }
        return false;
      });
      expect(containerFinder, findsOneWidget);
    });

    testWidgets('renders logical groupings and dividers between items',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestDrawerApp(user: testUser, activeIndex: 0),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('OpenDrawer'));
      await tester.pumpAndSettle();

      // Group 1: Navigation
      expect(find.text('الصفحة الرئيسية'), findsOneWidget);
      expect(find.text('قائمة الورش'), findsOneWidget);
      expect(find.text('محادثاتي'), findsOneWidget);

      // Group 2: Account utilities
      expect(find.text('تعديل الملف الشخصي'), findsOneWidget);
      expect(find.text('طلبات الصيانة الخاصة بي'), findsOneWidget);

      // Group 3: Support & Platform
      expect(find.text('عن منصة شمس'), findsOneWidget);
      expect(find.text('الدعم الفني والاتصال'), findsOneWidget);

      // Footer: Logout
      expect(find.text('تسجيل الخروج'), findsOneWidget);

      // Check dividers exist separating the sections
      expect(find.byType(Divider), findsWidgets);
    });

    testWidgets('shows workshop dashboard option when user has workshop',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      bool dashboardTapped = false;

      await tester.pumpWidget(
        _buildTestDrawerApp(
          user: workshopUser,
          activeIndex: 1,
          onWorkshopDashboardTap: () => dashboardTapped = true,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('OpenDrawer'));
      await tester.pumpAndSettle();

      expect(find.text('صاحب ورشة 🛠️'), findsOneWidget);
      expect(find.text('لوحة تحكم الورشة'), findsOneWidget);

      await tester.tap(find.text('لوحة تحكم الورشة'));
      await tester.pumpAndSettle();

      expect(dashboardTapped, isTrue);
    });

    testWidgets('onTabSelected callback is invoked when navigation item tapped',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      int selectedTab = -1;

      await tester.pumpWidget(
        _buildTestDrawerApp(
          user: testUser,
          activeIndex: 0,
          onTabSelected: (index) => selectedTab = index,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('OpenDrawer'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('قائمة الورش'));
      await tester.pumpAndSettle();

      expect(selectedTab, 1);
    });

    testWidgets('renders in English locale without layout overflow (client)',
        (tester) async {
      tester.view.physicalSize = const Size(375 * 2.0, 812 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestDrawerApp(
          user: testUser,
          activeIndex: 0,
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('OpenDrawer'));
      await tester.pumpAndSettle();

      expect(find.text('Shams Client ☀️'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in English locale without layout overflow (workshop owner)',
        (tester) async {
      tester.view.physicalSize = const Size(375 * 2.0, 812 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestDrawerApp(
          user: workshopUser,
          activeIndex: 0,
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('OpenDrawer'));
      await tester.pumpAndSettle();

      expect(find.text('Workshop Owner 🛠️'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('tapping technical support menu opens bottom sheet with 0 assertions',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestDrawerApp(user: testUser, activeIndex: 0),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('OpenDrawer'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.support_agent_rounded));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsOneWidget);
      expect(find.byIcon(Icons.phone_in_talk_outlined), findsOneWidget);
      expect(find.byIcon(Icons.email_outlined), findsOneWidget);

      expect(tester.takeException(), isNull);
    });
  });
}
