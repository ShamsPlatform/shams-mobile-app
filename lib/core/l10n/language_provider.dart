import 'package:flutter/widgets.dart';
import 'package:shams_mobile_app/core/l10n/language_storage.dart';

/// Manages the active [Locale] for the application.
///
/// Mirrors [ThemeProvider] in structure: wraps [LanguageStorage],
/// exposes [currentLocale], and notifies listeners on change.
class LanguageProvider extends ChangeNotifier {
  final LanguageStorage _storage;

  Locale _currentLocale = const Locale('ar', 'SA');

  LanguageProvider(this._storage);

  /// The currently active locale.
  Locale get currentLocale => _currentLocale;

  /// Whether the current locale is Arabic.
  bool get isArabic => _currentLocale.languageCode == 'ar';

  /// Loads the previously persisted locale (if any) from [LanguageStorage].
  /// Call this once during app startup before [runApp].
  Future<void> loadSavedLocale() async {
    final saved = _storage.loadLocale();
    if (saved != null) {
      _currentLocale = saved;
      notifyListeners();
    }
  }

  /// Switches the app locale to [locale] and persists the choice.
  Future<void> changeLanguage(Locale locale) async {
    if (_currentLocale == locale) return;
    _currentLocale = locale;
    await _storage.saveLocale(locale);
    notifyListeners();
  }
}
