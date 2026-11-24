import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/core/theme/theme_provider.dart';

/// ShamsPlatformAppBar — شريط التطبيق الرئيسي لمنصة شمس
///
/// الاستخدام:
/// ```dart
/// Scaffold(
///   appBar: ShamsPlatformAppBar(
///     onMenuTap: () {},
///     onNotificationTap: () {},
///     onDarkModeTap: () {},   // اختياري — يُوصَل تلقائياً بـ ThemeProvider
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
  /// إذا كان null يُستخدم ThemeProvider.toggleTheme() مباشرة.
  final VoidCallback? onDarkModeTap;

  /// عدد الإشعارات غير المقروءة للعرض على الشارة
  final int unreadNotifications;

  const ShamsPlatformAppBar({
    super.key,
    this.onMenuTap,
    this.onNotificationTap,
    this.onDarkModeTap,
    this.unreadNotifications = 0,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final unreadCount = unreadNotifications;
    final themeProvider = context.watch<ThemeProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = themeProvider.isDarkMode;

    // Select logo asset based on current brightness
    final logoAsset = isDark
        ? 'assets/images/logo/shams texial logo for dark mode.png'
        : 'assets/images/logo/shams texial logo for light mode small height.png';

    // The dark-mode toggle icon reflects the current mode
    final darkModeIcon =
        isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined;

    final ext = Theme.of(context).extension<ShamsExtendedColors>();
    final dividerColor = ext?.dividerLight ?? colorScheme.outlineVariant;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: dividerColor,
            width: 1.0,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: kToolbarHeight,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ── أيقونة القائمة الجانبية (يمين — بداية RTL) ────────────
                SizedBox(
                  width: 76,
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: _AppBarIcon(
                      icon: Icons.menu_rounded,
                      color: colorScheme.onSurface,
                      onTap: onMenuTap,
                    ),
                  ),
                ),

                // ── الشعار (الوسط) ─────────────────────────────────────────
                Expanded(
                  child: Center(
                    child: Image.asset(
                      logoAsset,
                      height: 36,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // ── أيقونات الوضع الليلي والإشعارات (يسار — نهاية RTL) ─────
                SizedBox(
                  width: 76,
                  child: Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // أيقونة تبديل الوضع الليلي
                        _AppBarIcon(
                          icon: darkModeIcon,
                          color: colorScheme.onSurface,
                          onTap: onDarkModeTap ??
                              () => themeProvider.toggleTheme(),
                        ),

                        const SizedBox(width: 14),

                        // أيقونة الإشعارات مع شارة
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _AppBarIcon(
                              icon: Icons.notifications_outlined,
                              color: colorScheme.onSurface,
                              onTap: onNotificationTap,
                            ),
                            if (unreadCount > 0)
                              PositionedDirectional(
                                top: -4,
                                end: -6,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: ShamsColors.dangerRed,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: colorScheme.surface,
                                      width: 1.5,
                                    ),
                                  ),
                                  constraints: const BoxConstraints(
                                    minWidth: 16,
                                    minHeight: 16,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$unreadCount',
                                      style: const TextStyle(
                                        color: ShamsColors.bgWhite,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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
  final Color color;
  final VoidCallback? onTap;

  const _AppBarIcon({
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Icon(icon, size: 28, color: color),
    );
  }
}
