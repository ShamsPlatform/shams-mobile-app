import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/l10n/l10n_mappers.dart';
import 'package:shams_mobile_app/core/l10n/language_provider.dart';
import 'package:shams_mobile_app/core/l10n/language_storage.dart';
import 'package:shams_mobile_app/core/theme/shams_theme.dart';
import 'package:shams_mobile_app/features/profile/presentation/widgets/profile_bottom_sheets.dart';
import 'package:shams_mobile_app/features/profile/presentation/widgets/profile_settings_section.dart';

class MockLanguageStorage extends Mock implements LanguageStorage {}

void main() {
  late MockLanguageStorage storage;
  late LanguageProvider languageProvider;

  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
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

  testWidgets(
      'ProfileSettingsSection and language sheet toggle Arabic/English and RTL/LTR',
      (tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: languageProvider,
        child: Consumer<LanguageProvider>(
          builder: (context, provider, _) {
            return MaterialApp(
              theme: ShamsTheme.light,
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
              home: Scaffold(
                body: SingleChildScrollView(
                  child: Builder(
                    builder: (context) => Column(
                      children: [
                        Text(
                          Directionality.of(context) == TextDirection.rtl
                              ? 'DIR_RTL'
                              : 'DIR_LTR',
                        ),
                        ProfileSettingsSection(
                          notificationsEnabled: true,
                          onNotificationsChanged: (_) {},
                          onPrivacyTap: () {},
                          onLanguageTap: () => showProfileLanguageSheet(
                            context,
                            initialLanguage: provider.isArabic ? 'ar' : 'en',
                            onSave: (lang) {
                              provider.changeLanguage(
                                lang == 'en'
                                    ? const Locale('en', 'US')
                                    : const Locale('ar', 'SA'),
                              );
                            },
                          ),
                          onSupportTap: () {},
                          onAboutTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    // Initial state: Arabic (RTL)
    expect(find.text('DIR_RTL'), findsOneWidget);
    expect(find.text('تغيير اللغة'), findsOneWidget);
    expect(find.text('عربي'), findsOneWidget);

    // Open language picker sheet
    await tester.tap(find.text('تغيير اللغة'));
    await tester.pumpAndSettle();

    expect(find.text('English (EN)'), findsOneWidget);
    expect(find.text('قريباً'), findsNothing);

    // Select English and save
    await tester.tap(find.text('English (EN)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(languageProvider.currentLocale, const Locale('en', 'US'));
    expect(find.text('DIR_LTR'), findsOneWidget);
    expect(find.text('Change Language'), findsOneWidget);
    expect(find.text('English'), findsOneWidget);
    verify(() => storage.saveLocale(const Locale('en', 'US'))).called(1);

    // Switch back to Arabic
    await tester.tap(find.text('Change Language'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('عربي (AR)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save'));
    await tester.pumpAndSettle();

    expect(languageProvider.currentLocale, const Locale('ar', 'SA'));
    expect(find.text('DIR_RTL'), findsOneWidget);
    expect(find.text('تغيير اللغة'), findsOneWidget);
    expect(find.text('عربي'), findsOneWidget);
    verify(() => storage.saveLocale(const Locale('ar', 'SA'))).called(1);
  });

  test('AppLocalizationsMappers translate constants, dates, and error messages',
      () {
    final ar = lookupAppLocalizations(const Locale('ar', 'SA'));
    final en = lookupAppLocalizations(const Locale('en', 'US'));

    expect(ar.localizeCity('صنعاء'), 'صنعاء');
    expect(en.localizeCity('صنعاء'), "Sana'a");
    expect(en.localizeCity('Sana\'a'), "Sana'a");

    expect(en.localizeServiceType('صيانة بطاريات'), 'Battery Maintenance');
    expect(en.localizeInverterBrand('أخرى'), 'Other');
    expect(en.localizeBatteryType('ليثيوم (LiFePO4)'), 'Lithium (LiFePO4)');

    expect(en.localizedMonthName(1), 'January');
    expect(ar.localizedMonthName(1), 'يناير');

    final now = DateTime(2026, 5, 1, 12, 0);
    expect(
      en.formatRelativeTimeLocalized(
        now.subtract(const Duration(minutes: 5)),
        now: now,
      ),
      '5 min ago',
    );
    expect(
      en.localizeErrorMessage('البريد الإلكتروني أو كلمة المرور غير صحيحة'),
      en.errInvalidCredentials,
    );
    expect(
      en.localizeErrorMessage('فشل رفع الصورة: timeout'),
      'Image upload failed: timeout',
    );
    expect(
      en.localizeErrorMessage(null, fallback: en.errUnexpected),
      en.errUnexpected,
    );
  });
}
