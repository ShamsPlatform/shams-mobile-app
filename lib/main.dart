import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shams_mobile_app/app/app.dart';
import 'package:shams_mobile_app/app/app_providers.dart';
import 'package:shams_mobile_app/core/config/env.dart';
import 'package:shams_mobile_app/core/di/injection.dart';
import 'package:shams_mobile_app/providers/theme_provider.dart';
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
  final themeProvider = ThemeProvider();
  await themeProvider.loadSavedTheme();
  runApp(AppProviders(themeProvider: themeProvider, child: const ShamsApp()));
}
