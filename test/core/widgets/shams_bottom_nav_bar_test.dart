import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/theme/shams_theme.dart';
import 'package:shams_mobile_app/core/widgets/shams_bottom_nav_bar.dart';

Widget _buildTestApp({
  required int currentIndex,
  required ValueChanged<int> onTap,
  Locale locale = const Locale('ar'),
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
      bottomNavigationBar: ShamsBottomNavBar(
        currentIndex: currentIndex,
        onTap: onTap,
      ),
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('ShamsBottomNavBar Tests', () {
    testWidgets('renders all 4 tabs with chat bubble icon on tab 2 (Arabic)',
        (tester) async {
      int tappedIndex = -1;

      await tester.pumpWidget(
        _buildTestApp(
          currentIndex: 0,
          onTap: (index) => tappedIndex = index,
          locale: const Locale('ar'),
        ),
      );
      await tester.pumpAndSettle();

      // Tab 0 is active (Home)
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);

      // Tab 1 is inactive (Workshops)
      expect(find.byIcon(Icons.build_outlined), findsOneWidget);

      // Tab 2 is inactive and must use chat bubble outline icon
      expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsOneWidget);
      expect(find.text('المحادثات'), findsOneWidget);

      // Tab 3 is inactive (Profile)
      expect(find.byIcon(Icons.person_outline_rounded), findsOneWidget);

      // Tap on Tab 2
      await tester.tap(find.byIcon(Icons.chat_bubble_outline_rounded));
      await tester.pumpAndSettle();

      expect(tappedIndex, 2);
    });

    testWidgets('renders chats tab label in English when locale is en',
        (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          currentIndex: 2,
          onTap: (_) {},
          locale: const Locale('en'),
        ),
      );
      await tester.pumpAndSettle();

      // Tab 2 active should display filled chat bubble icon and 'Chats'
      expect(find.byIcon(Icons.chat_bubble_rounded), findsOneWidget);
      expect(find.text('Chats'), findsOneWidget);
    });

    testWidgets('animates active indicator and scaling when active tab changes',
        (tester) async {
      int selectedTab = 0;

      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            return _buildTestApp(
              currentIndex: selectedTab,
              onTap: (index) {
                setState(() {
                  selectedTab = index;
                });
              },
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      // Initially tab 0 is active
      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      expect(find.byIcon(Icons.chat_bubble_outline_rounded), findsOneWidget);

      // Tap on tab 2
      await tester.tap(find.text('المحادثات'));
      await tester.pump(); // Start animation
      expect(selectedTab, 2);

      await tester.pumpAndSettle(); // Complete animation

      // Tab 2 now has active icon
      expect(find.byIcon(Icons.chat_bubble_rounded), findsOneWidget);
      // Tab 0 now has inactive icon
      expect(find.byIcon(Icons.home_outlined), findsOneWidget);
    });
  });
}
