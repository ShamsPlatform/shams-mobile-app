import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/core/di/injection.dart';
import 'package:shams_mobile_app/core/theme/theme_provider.dart';
import 'package:shams_mobile_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:shams_mobile_app/features/chat/presentation/providers/chat_list_provider.dart';
import 'package:shams_mobile_app/features/posts/presentation/providers/feed_provider.dart';
import 'package:shams_mobile_app/providers/notification_provider.dart';
import 'package:shams_mobile_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:shams_mobile_app/features/workshops/presentation/providers/my_workshop_provider.dart';
import 'package:shams_mobile_app/features/workshops/presentation/providers/workshops_provider.dart';

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
        ChangeNotifierProvider(create: (_) => sl<WorkshopsProvider>()),
        ChangeNotifierProvider(
          create: (context) {
            final workshopsProvider = context.read<WorkshopsProvider>();
            return sl<MyWorkshopProvider>()
              ..setSyncCallbacks(
                onSyncWorkshop: workshopsProvider.applyMyWorkshop,
                onReloadDirectory: workshopsProvider.load,
              );
          },
        ),
        ChangeNotifierProvider(create: (_) => sl<ProfileProvider>()),
        ChangeNotifierProvider(create: (_) => sl<FeedProvider>()),
        ChangeNotifierProvider(create: (_) => sl<ChatListProvider>()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: child,
    );
  }
}
