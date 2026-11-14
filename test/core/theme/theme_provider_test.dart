import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shams_mobile_app/core/theme/theme_provider.dart';
import 'package:shams_mobile_app/core/theme/theme_storage.dart';

class MockThemeStorage extends Mock implements ThemeStorage {}

void main() {
  late MockThemeStorage storage;
  late ThemeProvider provider;

  setUpAll(() {
    registerFallbackValue(ThemeMode.light);
  });

  setUp(() {
    storage = MockThemeStorage();
    when(() => storage.saveThemeMode(any())).thenAnswer((_) async {});
    provider = ThemeProvider(storage);
  });

  group('ThemeProvider', () {
    test('defaults to light mode', () {
      expect(provider.themeMode, ThemeMode.light);
      expect(provider.isDarkMode, isFalse);
    });

    test('loadSavedTheme updates themeMode and notifies when saved', () async {
      when(() => storage.loadThemeMode()).thenAnswer((_) async => ThemeMode.dark);
      var notifications = 0;
      provider.addListener(() => notifications++);

      await provider.loadSavedTheme();

      expect(provider.themeMode, ThemeMode.dark);
      expect(provider.isDarkMode, isTrue);
      expect(notifications, 1);
    });

    test('loadSavedTheme keeps default when nothing is saved', () async {
      when(() => storage.loadThemeMode()).thenAnswer((_) async => null);
      var notifications = 0;
      provider.addListener(() => notifications++);

      await provider.loadSavedTheme();

      expect(provider.themeMode, ThemeMode.light);
      expect(notifications, 0);
    });

    test('toggleTheme switches between light and dark and persists', () async {
      await provider.toggleTheme();

      expect(provider.themeMode, ThemeMode.dark);
      verify(() => storage.saveThemeMode(ThemeMode.dark)).called(1);

      await provider.toggleTheme();

      expect(provider.themeMode, ThemeMode.light);
      verify(() => storage.saveThemeMode(ThemeMode.light)).called(1);
    });

    test('setThemeMode ignores duplicate mode and persists new mode', () async {
      await provider.setThemeMode(ThemeMode.light);
      verifyNever(() => storage.saveThemeMode(any()));

      await provider.setThemeMode(ThemeMode.dark);
      expect(provider.themeMode, ThemeMode.dark);
      verify(() => storage.saveThemeMode(ThemeMode.dark)).called(1);
    });
  });
}
