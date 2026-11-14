import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's selected [ThemeMode] in [SharedPreferences].
class ThemeStorage {
  static const String themeModeKey = 'shams_theme_mode';

  final SharedPreferences _prefs;

  const ThemeStorage(this._prefs);

  Future<ThemeMode?> loadThemeMode() async {
    final savedIndex = _prefs.getInt(themeModeKey);
    if (savedIndex == null ||
        savedIndex < 0 ||
        savedIndex >= ThemeMode.values.length) {
      return null;
    }
    return ThemeMode.values[savedIndex];
  }

  Future<void> saveThemeMode(ThemeMode mode) async {
    await _prefs.setInt(themeModeKey, mode.index);
  }
}
