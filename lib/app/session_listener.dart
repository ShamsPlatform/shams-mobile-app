import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/app/navigation.dart';
import 'package:shams_mobile_app/core/presentation/resettable.dart';
import 'package:shams_mobile_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:shams_mobile_app/providers/chat_provider.dart';
import 'package:shams_mobile_app/providers/feed_provider.dart';
import 'package:shams_mobile_app/providers/notification_provider.dart';
import 'package:shams_mobile_app/providers/user_provider.dart';
import 'package:shams_mobile_app/providers/workshop_provider.dart';

/// Bridges [AuthProvider] state transitions to session-level side effects:
/// - On [AuthStatus.authenticated]: pops nested routes and triggers initial data loads once.
/// - On [AuthStatus.unauthenticated]: pops nested routes and resets all [Resettable] providers.
class SessionListener extends StatefulWidget {
  const SessionListener({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  State<SessionListener> createState() => _SessionListenerState();
}

class _SessionListenerState extends State<SessionListener> {
  AuthStatus _lastStatus = AuthStatus.unknown;
  int _sessionEpoch = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final status = context.watch<AuthProvider>().status;
    if (status == _lastStatus) return;

    _lastStatus = status;
    final epoch = ++_sessionEpoch;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _sessionEpoch != epoch) return;
      _handleStatusTransition(status, epoch);
    });
  }

  Future<void> _handleStatusTransition(AuthStatus status, int epoch) async {
    switch (status) {
      case AuthStatus.unknown:
        return;
      case AuthStatus.authenticated:
        rootNavigatorKey.currentState?.popUntil((route) => route.isFirst);
        final userProvider = context.read<UserProvider>();
        await userProvider.fetchUserData();
        if (!mounted || _sessionEpoch != epoch) return;

        final currentUser = userProvider.currentUser;
        context.read<WorkshopProvider>().fetchPublicWorkshops();
        context.read<NotificationProvider>().fetchNotifications();
        context.read<ChatProvider>().fetchChats();
        context.read<FeedProvider>().fetchFeed();

        if (currentUser.id.isNotEmpty && currentUser.hasWorkshop) {
          final username = currentUser.username ?? 'owner';
          await context
              .read<WorkshopProvider>()
              .fetchMyWorkshop(currentUser.id, username);
        }
      case AuthStatus.unauthenticated:
        rootNavigatorKey.currentState?.popUntil((route) => route.isFirst);
        final resettables = <Resettable>[
          context.read<UserProvider>(),
          context.read<WorkshopProvider>(),
          context.read<FeedProvider>(),
          context.read<ChatProvider>(),
          context.read<NotificationProvider>(),
        ];
        for (final provider in resettables) {
          provider.reset();
        }
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
