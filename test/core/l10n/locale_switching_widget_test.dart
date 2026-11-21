import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/l10n/language_provider.dart';
import 'package:shams_mobile_app/core/l10n/language_storage.dart';

class MockLanguageStorage extends Mock implements LanguageStorage {}

void main() {
  late MockLanguageStorage storage;
  late LanguageProvider languageProvider;

  setUpAll(() {
    registerFallbackValue(const Locale('ar', 'SA'));
  });

  setUp(() {
    storage = MockLanguageStorage();
    when(() => storage.saveLocale(any())).thenAnswer((_) async {});
    when(() => storage.loadLocale()).thenReturn(const Locale('ar', 'SA'));
    languageProvider = LanguageProvider(storage);
  });

  testWidgets('switching language updates directionality and localized text',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: languageProvider,
        child: Consumer<LanguageProvider>(
          builder: (context, provider, _) {
            return MaterialApp(
              locale: provider.currentLocale,
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('ar', 'SA'),
                Locale('en', 'US'),
              ],
              home: Builder(
                builder: (context) {
                  final l10n = AppLocalizations.of(context)!;
                  final direction = Directionality.of(context);
                  return Scaffold(
                    body: Column(
                      children: [
                        Text(l10n.appTitle),
                        Text(direction == TextDirection.rtl ? 'RTL' : 'LTR'),
                        ElevatedButton(
                          onPressed: () => provider
                              .changeLanguage(const Locale('en', 'US')),
                          child: const Text('SwitchToEnglish'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );

    // Initial state: Arabic (RTL)
    expect(find.text('شمس'), findsOneWidget);
    expect(find.text('RTL'), findsOneWidget);

    // Switch to English
    await tester.tap(find.text('SwitchToEnglish'));
    await tester.pumpAndSettle();

    // Verify dynamic update: English (LTR)
    expect(find.text('Shams'), findsOneWidget);
    expect(find.text('LTR'), findsOneWidget);
    verify(() => storage.saveLocale(const Locale('en', 'US'))).called(1);
  });
}
