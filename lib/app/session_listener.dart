import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/app/navigation.dart';
import 'package:shams_mobile_app/core/presentation/resettable.dart';
import 'package:shams_mobile_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:shams_mobile_app/providers/chat_provider.dart';
import 'package:shams_mobile_app/features/posts/presentation/providers/feed_provider.dart';
import 'package:shams_mobile_app/providers/notification_provider.dart';
import 'package:shams_mobile_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:shams_mobile_app/features/workshops/presentation/providers/my_workshop_provider.dart';
import 'package:shams_mobile_app/features/workshops/presentation/providers/workshops_provider.dart';

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
        final profileProvider = context.read<ProfileProvider>();
        await profileProvider.load();
        if (!mounted || _sessionEpoch != epoch) return;

        final currentUser = profileProvider.currentUserOrPlaceholder;
        context.read<WorkshopsProvider>().load();
        context.read<NotificationProvider>().fetchNotifications();
        context.read<ChatProvider>().fetchChats();
        context.read<FeedProvider>().load();

        if (currentUser.id.isNotEmpty && currentUser.hasWorkshop) {
          final username = currentUser.username ?? 'owner';
          await context.read<MyWorkshopProvider>().load(
                userId: currentUser.id,
                fallbackUsername: username,
              );
        }
      case AuthStatus.unauthenticated:
        rootNavigatorKey.currentState?.popUntil((route) => route.isFirst);
        final resettables = <Resettable>[
          context.read<ProfileProvider>(),
          context.read<MyWorkshopProvider>(),
          context.read<WorkshopsProvider>(),
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
