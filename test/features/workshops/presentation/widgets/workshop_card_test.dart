import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/theme/shams_theme.dart';
import 'package:shams_mobile_app/features/workshops/presentation/widgets/workshop_card.dart';

Widget _buildTestApp({
  required Widget child,
  Locale locale = const Locale('en'),
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
      body: SingleChildScrollView(child: child),
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('WorkshopCard', () {
    testWidgets('prefixes userHandle with @ and exposes Hero avatar wrapper',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: const WorkshopCard(
            username: 'Al-Noor Solar',
            userHandle: 'alnoor_solar',
            imagePath: '',
            coverImagePath: '',
            cityName: 'Sana\'a',
            rating: 4.8,
            reviewCount: 12,
            isFollowing: false,
            heroTag: 'workshop-avatar-ws1',
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Al-Noor Solar'), findsOneWidget);
      expect(find.text('@alnoor_solar'), findsOneWidget);

      final hero = tester.widget<Hero>(find.byType(Hero));
      expect(hero.tag, 'workshop-avatar-ws1');
    });

    testWidgets(
        'renders filled primary CTA for View Workshop and outlined CTA for Follow',
        (tester) async {
      bool? toggledValue;
      var enterTapped = false;

      await tester.pumpWidget(
        _buildTestApp(
          locale: const Locale('en'),
          child: WorkshopCard(
            username: 'Yemen Sun Co',
            userHandle: '@yemen_sun',
            imagePath: '',
            coverImagePath: '',
            cityName: 'Aden',
            rating: 4.5,
            reviewCount: 5,
            isFollowing: false,
            onFollowToggle: (val) => toggledValue = val,
            onEnterTap: () => enterTapped = true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      final colorScheme = ShamsTheme.light.colorScheme;
      final followText = find.text('Follow');
      final enterText = find.text('View Workshop');

      expect(followText, findsOneWidget);
      expect(enterText, findsOneWidget);

      // Verify Follow button uses primary color when unfollowed
      final followWidget = tester.widget<Text>(followText);
      expect(followWidget.style?.color, colorScheme.primary);

      // Verify View Workshop button uses onSecondary text on secondary fill
      final enterWidget = tester.widget<Text>(enterText);
      expect(enterWidget.style?.color, colorScheme.onSecondary);

      // Tap View Workshop
      await tester.tap(enterText);
      await tester.pumpAndSettle();
      expect(enterTapped, isTrue);

      // Tap Follow -> animates and toggles to Following with check icon
      await tester.tap(followText);
      await tester.pumpAndSettle();

      expect(toggledValue, isTrue);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
      expect(find.text('Following'), findsOneWidget);
    });
  });
}

