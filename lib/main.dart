import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shams_mobile_app/views/home.dart';
import 'package:shams_mobile_app/views/workshops/workshops_list_screen.dart';

import 'utils/theme.dart';

Future<void> main() async {
  // Ensure Flutter engine is fully initialized before calling native code.
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait for a consistent mobile experience.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Supabase.
  // TODO: Replace with your actual Supabase project URL and anon key,
  // ideally loaded from environment variables or a .env file via --dart-define.
  await Supabase.initialize(
    url: const String.fromEnvironment('SUPABASE_URL'),
    anonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  runApp(const ShamsApp());
}

/// Root widget of the Shams Platform application.
class ShamsApp extends StatelessWidget {
  const ShamsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return
    // MultiProvider(
    //   // Register your controllers/providers here as the app grows.
    //   // Example:
    //   //   ChangeNotifierProvider(create: (_) => AuthController()),
    //   //   ChangeNotifierProvider(create: (_) => HomeController()),
    //   providers: const [],
    //   child:
    MaterialApp(
      // ── App Identity ────────────────────────────────────────────
      title: 'شمس',
      debugShowCheckedModeBanner: false,

      // ── Theme ───────────────────────────────────────────────────
      theme: ShamsTheme.light,

      // ── Locale & RTL ────────────────────────────────────────────
      locale: const Locale('ar', 'SA'),
      supportedLocales: const [
        Locale('ar', 'SA'), // Arabic (Saudi Arabia) — primary
        Locale('en', 'US'), // English — fallback
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ── Entry Point ─────────────────────────────────────────────
      // home: const Scaffold(body: Center(child: Text('شمس — جاهز للبناء 🌟'))),
      home: const WorkshopsListScreen(),
    );
    // );
  }
}
