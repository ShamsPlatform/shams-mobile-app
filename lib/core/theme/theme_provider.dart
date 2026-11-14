import 'package:flutter/material.dart';
import 'package:shams_mobile_app/core/theme/theme_storage.dart';

/// ThemeProvider — مدير وضع السمة (فاتح / داكن)
///
/// يحفظ تفضيل المستخدم في [ThemeStorage] ويُعيد تحميله عند بدء التطبيق.
class ThemeProvider extends ChangeNotifier {
  final ThemeStorage _storage;

  ThemeProvider(this._storage);

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  /// يُحمَّل عند بدء التشغيل — يُعيد قراءة التفضيل المحفوظ.
  Future<void> loadSavedTheme() async {
    final savedMode = await _storage.loadThemeMode();
    if (savedMode != null) {
      _themeMode = savedMode;
      notifyListeners();
    }
  }

  /// يُبدّل بين الوضع الفاتح والداكن ويحفظ الاختيار.
  Future<void> toggleTheme() async {
    _themeMode =
        _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    await _storage.saveThemeMode(_themeMode);
  }

  /// يضبط وضع السمة مباشرة.
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    _themeMode = mode;
    notifyListeners();
    await _storage.saveThemeMode(mode);
  }
}
