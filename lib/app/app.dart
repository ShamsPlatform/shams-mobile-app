import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/app/auth_gate.dart';
import 'package:shams_mobile_app/app/navigation.dart';
import 'package:shams_mobile_app/core/theme/theme_provider.dart';
import 'package:shams_mobile_app/core/theme/shams_theme.dart';

/// Root widget of the Shams Platform application.
class ShamsApp extends StatelessWidget {
  const ShamsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      navigatorKey: rootNavigatorKey,

      // ── App Identity ────────────────────────────────────────────
      title: 'شمس',
      debugShowCheckedModeBanner: false,

      // ── Theme ───────────────────────────────────────────────────
      theme: ShamsTheme.light,
      darkTheme: ShamsTheme.dark,
      themeMode: themeProvider.themeMode,

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
      home: const AuthGate(),
    );
  }
}
