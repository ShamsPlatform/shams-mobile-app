import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/l10n/l10n_mappers.dart';
import 'package:shams_mobile_app/core/presentation/view_status.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/features/chat/presentation/screens/chat_conversation_screen.dart';
import 'package:shams_mobile_app/features/notifications/domain/entities/app_notification.dart';
import 'package:shams_mobile_app/features/notifications/presentation/providers/notification_provider.dart';
import 'package:shams_mobile_app/features/notifications/presentation/widgets/notification_tile.dart';
import 'package:shams_mobile_app/features/posts/presentation/screens/post_detail_screen.dart';
import 'package:shams_mobile_app/features/workshops/presentation/screens/workshop_profile_screen.dart';

/// Displays user notifications with read, mark-all-read, swipe-to-delete,
/// and type-based target navigation.
class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final notifications = provider.notifications;
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
        backgroundColor: ext.backgroundLight,
        appBar: AppBar(
          title: Text(
            l10n.notifications,
            style: GoogleFonts.tajawal(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: colorScheme.surface,
          elevation: 0.5,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: colorScheme.onSurface,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            if (provider.unreadCount > 0)
              TextButton(
                onPressed: () =>
                    context.read<NotificationProvider>().markAllAsRead(),
                child: Text(
                  l10n.markAllRead,
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        body: provider.status == ViewStatus.loading && notifications.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : notifications.isEmpty
                ? _buildEmptyState(context)
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    itemCount: notifications.length,
                    separatorBuilder: (context, index) => Divider(
                      color: ext.dividerLight,
                      height: 1,
                      indent: 70,
                    ),
                    itemBuilder: (context, index) {
                      final notif = notifications[index];
                      return Dismissible(
                        key: Key(notif.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          color: colorScheme.error,
                          alignment: AlignmentDirectional.centerEnd,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: const Icon(
                            Icons.delete_rounded,
                            color: Colors.white,
                          ),
                        ),
                        onDismissed: (_) {
                          context
                              .read<NotificationProvider>()
                              .deleteNotification(notif.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                l10n.notificationDeleted,
                                style: GoogleFonts.tajawal(
                                  fontSize: 14,
                                  color: colorScheme.onInverseSurface,
                                ),
                              ),
                              backgroundColor: colorScheme.inverseSurface,
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                          );
                        },
                        child: NotificationTile(
                          notif: notif,
                          onTap: () => _handleNotifTap(context, notif),
                        ),
                      );
                    },
                  ),
      );
  }

  Future<void> _handleNotifTap(
    BuildContext context,
    AppNotification notif,
  ) async {
    final notifProvider = context.read<NotificationProvider>();
    final l10n = AppLocalizations.of(context)!;
    if (!notif.isRead) {
      notifProvider.markAsRead(notif.id);
    }

    switch (notif.type) {
      case NotificationType.like:
      case NotificationType.comment:
      case NotificationType.reply:
        if (notif.targetId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PostDetailScreen(postId: notif.targetId!),
            ),
          );
        }
        break;
      case NotificationType.workshopUpdate:
        if (notif.targetId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => WorkshopProfile(workshopId: notif.targetId!),
            ),
          );
        }
        break;
      case NotificationType.maintenanceStatus:
        if (notif.targetId != null) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => const Center(child: CircularProgressIndicator()),
          );

          final chatId = await notifProvider.resolveMaintenanceChatId(
            notif.targetId!,
          );
          if (!context.mounted) return;
          Navigator.pop(context);

          if (chatId != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatConversationScreen(chatId: chatId),
              ),
            );
          } else {
            final error = notifProvider.errorMessage;
            ScaffoldMessenger.of(context).showSnackBar(
              _infoSnack(
                error != null
                    ? l10n.chatLoadError(l10n.localizeErrorMessage(error))
                    : l10n.maintenanceChatNotFound,
              ),
            );
          }
        }
        break;
      case NotificationType.message:
        if (notif.targetId != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatConversationScreen(chatId: notif.targetId!),
            ),
          );
        }
        break;
      case NotificationType.system:
        break;
    }
  }

  SnackBar _infoSnack(String text) => SnackBar(
        content: Text(text, style: GoogleFonts.tajawal()),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      );

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 60,
            color: ext.textHint.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noNotificationsNow,
            style: GoogleFonts.tajawal(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l10n.notificationsWillAppearHere,
            style: GoogleFonts.tajawal(
              fontSize: 13,
              color: ext.textHint,
            ),
          ),
        ],
      ),
    );
  }
}

