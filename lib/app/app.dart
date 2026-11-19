import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/app/auth_gate.dart';
import 'package:shams_mobile_app/app/navigation.dart';
import 'package:shams_mobile_app/app/session_listener.dart';
import 'package:shams_mobile_app/core/l10n/language_provider.dart';
import 'package:shams_mobile_app/core/theme/shams_theme.dart';
import 'package:shams_mobile_app/core/theme/theme_provider.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';

/// Root widget of the Shams Platform application.
class ShamsApp extends StatelessWidget {
  const ShamsApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final languageProvider = context.watch<LanguageProvider>();

    return MaterialApp(
      navigatorKey: rootNavigatorKey,

      // ── App Identity ────────────────────────────────────────────
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,

      // ── Theme ───────────────────────────────────────────────────
      theme: ShamsTheme.light,
      darkTheme: ShamsTheme.dark,
      themeMode: themeProvider.themeMode,

      // ── Locale & RTL ────────────────────────────────────────────
      locale: languageProvider.currentLocale,
      supportedLocales: const [
        Locale('ar', 'SA'), // Arabic (Saudi Arabia) — primary
        Locale('en', 'US'), // English — secondary
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // ── Entry Point ─────────────────────────────────────────────
      builder: (context, child) {
        return SessionListener(
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const AuthGate(),
    );
  }
}
