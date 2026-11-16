import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shams_mobile_app/core/l10n/language_storage.dart';

void main() {
  group('LanguageStorage', () {
    late SharedPreferences prefs;
    late LanguageStorage storage;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
      storage = LanguageStorage(prefs);
    });

    test('loadLocale returns null when no value saved', () {
      expect(storage.loadLocale(), isNull);
    });

    test('saveLocale and loadLocale round-trip with country code', () async {
      const locale = Locale('en', 'US');
      await storage.saveLocale(locale);
      final loaded = storage.loadLocale();
      expect(loaded, isNotNull);
      expect(loaded?.languageCode, 'en');
      expect(loaded?.countryCode, 'US');
    });

    test('saveLocale and loadLocale round-trip for Arabic', () async {
      const locale = Locale('ar', 'SA');
      await storage.saveLocale(locale);
      final loaded = storage.loadLocale();
      expect(loaded, isNotNull);
      expect(loaded?.languageCode, 'ar');
      expect(loaded?.countryCode, 'SA');
    });

    test('loadLocale handles languageCode without country code', () async {
      const locale = Locale('ar');
      await storage.saveLocale(locale);
      final loaded = storage.loadLocale();
      expect(loaded, isNotNull);
      expect(loaded?.languageCode, 'ar');
    });
  });
}
