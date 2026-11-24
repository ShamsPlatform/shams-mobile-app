import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shams_mobile_app/core/domain/entities/app_user.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/theme/shams_theme.dart';
import 'package:shams_mobile_app/core/widgets/city_filter.dart';
import 'package:shams_mobile_app/core/widgets/shams_drawer.dart';
import 'package:shams_mobile_app/core/widgets/shams_modals.dart';

Widget _buildTestApp({
  required Widget home,
  Locale locale = const Locale('en'),
  ThemeData? theme,
  MediaQueryData? mediaQueryOverride,
}) {
  return MaterialApp(
    theme: theme ?? ShamsTheme.light,
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
    builder: (context, child) {
      if (mediaQueryOverride != null) {
        return MediaQuery(data: mediaQueryOverride, child: child!);
      }
      return child!;
    },
    home: home,
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('ShamsModals & Scrollable Dialogs', () {
    testWidgets('showShamsModalBottomSheet opens with fade wrapper and settles',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showShamsModalBottomSheet<void>(
                    context: context,
                    builder: (_) => const SizedBox(
                      height: 160,
                      child: Center(child: Text('Sheet Body')),
                    ),
                  );
                },
                child: const Text('Open Sheet'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Sheet Body'), findsOneWidget);
      expect(find.byType(FadeTransition), findsWidgets);

      // Dismiss by tapping barrier
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('Sheet Body'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'showShamsDialog opens with slide+fade+scale transitions and dismisses on barrier tap',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          locale: const Locale('ar'),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showShamsDialog<void>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Dialog Title'),
                      content: Text(
                        Directionality.of(ctx) == TextDirection.rtl
                            ? 'RTL_OK'
                            : 'LTR',
                      ),
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Dialog Title'), findsOneWidget);
      expect(find.text('RTL_OK'), findsOneWidget);

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();

      expect(find.text('Dialog Title'), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'CityMultiSelectFilter dialog stays scrollable without overflow at 320dp + 1.5x textScale + keyboard',
        (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        _buildTestApp(
          mediaQueryOverride: const MediaQueryData(
            size: Size(320, 480),
            textScaler: TextScaler.linear(1.5),
            viewInsets: EdgeInsets.only(bottom: 180),
          ),
          home: Scaffold(
            body: Center(
              child: CityMultiSelectFilter(onSelectionChanged: (_) {}),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Governorates'));
      await tester.pumpAndSettle();

      expect(find.text('Select Governorates'), findsOneWidget);
      expect(find.text("Sana'a"), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
        'ShamsDrawer logout dialog stays scrollable without overflow at 320dp + 1.5x textScale',
        (tester) async {
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      const user = AppUser(
        id: 'u1',
        name: 'User',
        email: 'user@shams.ye',
        hasWorkshop: false,
      );

      await tester.pumpWidget(
        _buildTestApp(
          mediaQueryOverride: const MediaQueryData(
            size: Size(320, 480),
            textScaler: TextScaler.linear(1.5),
            viewInsets: EdgeInsets.only(bottom: 180),
          ),
          home: Scaffold(
            drawer: ShamsDrawer(
              activeIndex: 0,
              currentUser: user,
              onEditProfileTap: () {},
              onAboutTap: () {},
              onSignOut: () {},
            ),
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => Scaffold.of(context).openDrawer(),
                child: const Text('OpenDrawer'),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('OpenDrawer'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Log Out'));
      await tester.pumpAndSettle();

      expect(find.text('Are you sure you want to log out?'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}
