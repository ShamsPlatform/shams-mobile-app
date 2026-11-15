import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shams_mobile_app/app/app.dart';
import 'package:shams_mobile_app/app/app_providers.dart';
import 'package:shams_mobile_app/core/config/env.dart';
import 'package:shams_mobile_app/core/di/injection.dart';
import 'package:shams_mobile_app/core/theme/theme_provider.dart';
import 'package:shams_mobile_app/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  Env.validate();
  try {
    await Supabase.initialize(url: Env.supabaseUrl, anonKey: Env.supabaseAnonKey);
  } catch (e) {
    debugPrint('Supabase initialization failed: $e');
    debugPrint('Continuing in offline mode for UI testing.');
  }
  await initDependencies();
  await sl<AuthLocalDataSource>().clearLegacyKeys();
  final themeProvider = ThemeProvider(sl());
  await themeProvider.loadSavedTheme();
  runApp(AppProviders(themeProvider: themeProvider, child: const ShamsApp()));
}
