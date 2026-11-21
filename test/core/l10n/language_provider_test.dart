import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/l10n/language_provider.dart';
import 'package:shams_mobile_app/core/l10n/language_storage.dart';

class MockLanguageStorage extends Mock implements LanguageStorage {}

void main() {
  late MockLanguageStorage storage;
  late LanguageProvider provider;

  setUpAll(() {
    registerFallbackValue(const Locale('ar', 'SA'));
  });

  setUp(() {
    storage = MockLanguageStorage();
    when(() => storage.saveLocale(any())).thenAnswer((_) async {});
    provider = LanguageProvider(storage);
  });

  group('LanguageProvider', () {
    test('defaults to Arabic locale', () {
      expect(provider.currentLocale, const Locale('ar', 'SA'));
      expect(provider.isArabic, isTrue);
    });

    test('loadSavedLocale updates currentLocale and notifies listeners when saved', () async {
      when(() => storage.loadLocale()).thenReturn(const Locale('en', 'US'));
      var notified = false;
      provider.addListener(() => notified = true);

      await provider.loadSavedLocale();

      expect(provider.currentLocale, const Locale('en', 'US'));
      expect(provider.isArabic, isFalse);
      expect(notified, isTrue);
    });

    test('loadSavedLocale preserves default when nothing is saved', () async {
      when(() => storage.loadLocale()).thenReturn(null);
      var notified = false;
      provider.addListener(() => notified = true);

      await provider.loadSavedLocale();

      expect(provider.currentLocale, const Locale('ar', 'SA'));
      expect(provider.isArabic, isTrue);
      expect(notified, isFalse);
    });

    test('changeLanguage updates locale and persists to storage', () async {
      var notified = false;
      provider.addListener(() => notified = true);

      await provider.changeLanguage(const Locale('en', 'US'));

      expect(provider.currentLocale, const Locale('en', 'US'));
      expect(provider.isArabic, isFalse);
      expect(notified, isTrue);
      verify(() => storage.saveLocale(const Locale('en', 'US'))).called(1);
    });

    test('changeLanguage to current locale is a no-op', () async {
      var notified = false;
      provider.addListener(() => notified = true);

      await provider.changeLanguage(const Locale('ar', 'SA'));

      expect(notified, isFalse);
      verifyNever(() => storage.saveLocale(any()));
    });
  });
}
