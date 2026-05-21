import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../utils/constants.dart';
import '../../providers/notification_provider.dart';
import '../../models/notification_model.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    // Automatically mark all notifications as read upon opening this screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<NotificationProvider>().markAllAsRead();
      }
    });
  }

  String _formatRelativeTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'الآن';
    } else if (difference.inHours < 1) {
      final minutes = difference.inMinutes;
      if (minutes == 1) return 'منذ دقيقة';
      if (minutes == 2) return 'منذ دقيقتين';
      if (minutes >= 3 && minutes <= 10) return 'منذ $minutes دقائق';
      return 'منذ $minutes دقيقة';
    } else if (difference.inDays < 1) {
      final hours = difference.inHours;
      if (hours == 1) return 'منذ ساعة';
      if (hours == 2) return 'منذ ساعتين';
      if (hours >= 3 && hours <= 10) return 'منذ $hours ساعات';
      return 'منذ $hours ساعة';
    } else {
      final days = difference.inDays;
      if (days == 1) return 'منذ يوم';
      if (days == 2) return 'منذ يومين';
      if (days >= 3 && days <= 10) return 'منذ $days أيام';
      return 'منذ $days يوم';
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifications = context.watch<NotificationProvider>().notifications;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'الإشعارات',
            style: GoogleFonts.tajawal(
              color: ShamsColors.textGray,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0.5,
          leading: IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, color: ShamsColors.textGray, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: notifications.isEmpty
            ? Center(
                child: Text(
                  'لا توجد إشعارات حالياً',
                  style: GoogleFonts.tajawal(
                    fontSize: 16,
                    color: ShamsColors.textHint,
                  ),
                ),
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 10),
                itemCount: notifications.length,
                separatorBuilder: (context, index) => const Divider(
                  color: ShamsColors.dividerLight,
                  height: 1,
                  indent: 70,
                ),
                itemBuilder: (context, index) {
                  final NotificationModel notification = notifications[index];
                  final notificationIcon = notification.icon ?? Icons.notifications_rounded;
                  final notificationColor = notification.color ?? ShamsColors.primaryBlue;

                  return Dismissible(
                    key: Key(notification.id),
                    direction: DismissDirection.horizontal,
                    background: Container(
                      color: ShamsColors.dangerRed,
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete_rounded, color: Colors.white),
                    ),
                    secondaryBackground: Container(
                      color: ShamsColors.dangerRed,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: const Icon(Icons.delete_rounded, color: Colors.white),
                    ),
                    onDismissed: (direction) {
                      context.read<NotificationProvider>().deleteNotification(notification.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'تم حذف الإشعار',
                            style: GoogleFonts.tajawal(fontSize: 14, color: Colors.white),
                          ),
                          backgroundColor: ShamsColors.textGray,
                          duration: const Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      leading: CircleAvatar(
                        backgroundColor: notificationColor.withOpacity(0.1),
                        child: Icon(notificationIcon, color: notificationColor, size: 20),
                      ),
                      title: Text(
                        notification.title,
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: ShamsColors.textGray,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          _formatRelativeTime(notification.timestamp),
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: ShamsColors.textHint,
                          ),
                        ),
                      ),
                      onTap: () {},
                    ),
                  );
                },
              ),
      ),
    );
  }
}
