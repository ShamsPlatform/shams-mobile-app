/// Compile-time environment configuration passed via `--dart-define-from-file`.
class Env {
  const Env._();

  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
  static const oauthRedirectUrl = String.fromEnvironment(
    'OAUTH_REDIRECT_URL',
    defaultValue: 'shams://login-callback/',
  );

  /// When true, client data sources skip notification inserts handled by DB triggers.
  static const useDbNotificationTriggers = bool.fromEnvironment(
    'USE_DB_NOTIFICATION_TRIGGERS',
    defaultValue: false,
  );

  /// Fails fast when required Supabase configuration is missing.
  static void validate() {
    if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
      throw StateError(
        'Missing SUPABASE_URL / SUPABASE_ANON_KEY. '
        'Run with --dart-define-from-file=env/dev.json',
      );
    }
  }
}
