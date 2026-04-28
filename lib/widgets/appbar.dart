import 'package:flutter/material.dart';
import 'package:shams_mobile_app/utils/constants.dart';

/// ShamsPlatformAppBar — شريط التطبيق الرئيسي لمنصة شمس
///
/// الاستخدام:
/// ```dart
/// Scaffold(
///   appBar: ShamsPlatformAppBar(
///     onMenuTap: () {},
///     onNotificationTap: () {},
///     onDarkModeTap: () {},
///   ),
/// )
/// ```
class ShamsPlatformAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  /// callback عند الضغط على أيقونة القائمة الجانبية
  final VoidCallback? onMenuTap;

  /// callback عند الضغط على أيقونة الإشعارات
  final VoidCallback? onNotificationTap;

  /// callback عند الضغط على أيقونة الوضع الليلي
  final VoidCallback? onDarkModeTap;

  /// هل توجد إشعارات غير مقروءة؟
  final bool hasUnreadNotifications;

  const ShamsPlatformAppBar({
    super.key,
    this.onMenuTap,
    this.onNotificationTap,
    this.onDarkModeTap,
    this.hasUnreadNotifications = false,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        color: ShamsColors.solarYellow,
        child: SafeArea(
          bottom: false,
          child: SizedBox(
            height: kToolbarHeight,
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── الشعار (يمين — بداية RTL) ────────────────────
                  // Flexible يمنع overflow إذا كانت الصورة عريضة جداً
                  Flexible(
                    child: Image.asset(
                      'assets/images/logo/shams texial logo for light mode small height.png',

                      height: double.infinity,
                      fit: BoxFit.fitHeight,
                      // alignment: Alignment.centerRight,
                      // color: ShamsColors.textGray,
                      // colorBlendMode: BlendMode.srcIn,
                    ),
                  ),

                  // ── أيقونات (يسار — نهاية RTL) ───────────────────
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // أيقونة الوضع الليلي
                      _AppBarIcon(
                        icon: Icons.dark_mode_outlined,
                        onTap: onDarkModeTap,
                      ),

                      const SizedBox(width: 14),

                      // أيقونة الإشعارات مع شارة
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _AppBarIcon(
                            icon: Icons.notifications_outlined,
                            onTap: onNotificationTap,
                          ),
                          if (hasUnreadNotifications)
                            Positioned(
                              top: -2,
                              left: -2,
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE53935),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: ShamsColors.solarYellow,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(width: 14),

                      // أيقونة القائمة الجانبية
                      _AppBarIcon(icon: Icons.menu_rounded, onTap: onMenuTap),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _AppBarIcon — أيقونة بسيطة في شريط التطبيق
// ─────────────────────────────────────────────────────────────────────────────

class _AppBarIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;

  const _AppBarIcon({required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Icon(icon, size: 24, color: ShamsColors.textGray),
    );
  }
}
