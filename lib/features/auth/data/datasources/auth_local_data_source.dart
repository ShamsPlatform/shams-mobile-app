import 'package:shared_preferences/shared_preferences.dart';

abstract interface class AuthLocalDataSource {
  Future<void> clearLegacyKeys();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  AuthLocalDataSourceImpl(this._prefs);

  static const _legacyIsLoggedInKey = 'is_logged_in';
  static const _legacyEmailKey = 'user_email';

  final SharedPreferences _prefs;

  @override
  Future<void> clearLegacyKeys() async {
    await _prefs.remove(_legacyIsLoggedInKey);
    await _prefs.remove(_legacyEmailKey);
  }
}
