import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/core/di/injection.dart';
import 'package:shams_mobile_app/core/theme/theme_provider.dart';
import 'package:shams_mobile_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:shams_mobile_app/providers/chat_provider.dart';
import 'package:shams_mobile_app/providers/feed_provider.dart';
import 'package:shams_mobile_app/providers/notification_provider.dart';
import 'package:shams_mobile_app/providers/user_provider.dart';
import 'package:shams_mobile_app/providers/workshop_provider.dart';

/// Top-level [MultiProvider] wiring for the application.
class AppProviders extends StatelessWidget {
  final ThemeProvider themeProvider;
  final Widget child;

  const AppProviders({
    super.key,
    required this.themeProvider,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => sl<AuthProvider>()..start()),
        ChangeNotifierProvider.value(value: themeProvider),
        ChangeNotifierProvider(create: (_) => WorkshopProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: child,
    );
  }
}
