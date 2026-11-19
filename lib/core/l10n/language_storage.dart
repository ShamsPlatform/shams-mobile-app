import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's selected [Locale] in [SharedPreferences].
class LanguageStorage {
  static const String _localeKey = 'shams_locale';

  final SharedPreferences _prefs;

  const LanguageStorage(this._prefs);

  /// Saves [locale] to persistent storage.
  Future<void> saveLocale(Locale locale) async {
    final value = '${locale.languageCode}_${locale.countryCode ?? ''}';
    await _prefs.setString(_localeKey, value);
  }

  /// Loads the previously saved [Locale], or returns `null` if none saved.
  Locale? loadLocale() {
    final raw = _prefs.getString(_localeKey);
    if (raw == null || raw.isEmpty) return null;
    final parts = raw.split('_');
    if (parts.length >= 2 && parts[1].isNotEmpty) {
      return Locale(parts[0], parts[1]);
    }
    return Locale(parts[0]);
  }
}
