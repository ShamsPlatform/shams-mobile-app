import 'package:flutter/material.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ShamsBottomNavBar — شريط التنقل السفلي لمنصة شمس
// ─────────────────────────────────────────────────────────────────────────────

class ShamsNavItem {
  final IconData activeIcon;
  final IconData inactiveIcon;
  /// Static label — used only when caller passes custom items.
  /// For the default items the bar resolves labels from l10n.
  final String label;

  const ShamsNavItem({
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
  });
}

class ShamsBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<ShamsNavItem>? items;

  const ShamsBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.items,
  });

  static const List<ShamsNavItem> defaultItems = [
    ShamsNavItem(
      activeIcon: Icons.home_rounded,
      inactiveIcon: Icons.home_outlined,
      label: 'homeNav',   // key resolved below
    ),
    ShamsNavItem(
      activeIcon: Icons.build_rounded,
      inactiveIcon: Icons.build_outlined,
      label: 'workshopsNav',
    ),
    ShamsNavItem(
      activeIcon: Icons.chat_bubble_rounded,
      inactiveIcon: Icons.chat_bubble_outline_rounded,
      label: 'chatsTitle',
    ),
    ShamsNavItem(
      activeIcon: Icons.person_rounded,
      inactiveIcon: Icons.person_outline_rounded,
      label: 'profileNav',
    ),
  ];

  String _resolveLabel(AppLocalizations l10n, String key) {
    switch (key) {
      case 'homeNav': return l10n.homeNav;
      case 'workshopsNav': return l10n.workshopsNav;
      case 'chatsTitle':
      case 'myChats':
      case 'chatsNav':
        return l10n.chatsTitle;
      case 'followNav': return l10n.followNav;
      case 'profileNav': return l10n.profileNav;
      default: return key;
    }
  }

  @override
  Widget build(BuildContext context) {
    final navItems = items ?? defaultItems;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
        border: Border(
          top: BorderSide(color: ext.dividerLight, width: 1.2),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64 + bottomPadding,
          child: Row(
            children: List.generate(navItems.length, (index) {
              return Expanded(
                child: _NavBarItem(
                  label: _resolveLabel(l10n, navItems[index].label),
                  activeIcon: navItems[index].activeIcon,
                  inactiveIcon: navItems[index].inactiveIcon,
                  isActive: index == currentIndex,
                  onTap: () => onTap(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _NavBarItem — عنصر تبويب واحد مع أنيميشن
// ─────────────────────────────────────────────────────────────────────────────

class _NavBarItem extends StatefulWidget {
  final String label;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final bool isActive;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.label,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavBarItem> createState() => _NavBarItemState();
}

class _NavBarItemState extends State<_NavBarItem> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // ── نقطة / شريط المؤشر ───────────────────────────────────────
          AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeOutCubic,
            width: widget.isActive ? 22 : 0,
            height: 3,
            margin: const EdgeInsets.only(bottom: 5),
            decoration: BoxDecoration(
              color: colorScheme.secondary,
              borderRadius: BorderRadius.circular(99),
            ),
          ),

          // ── الأيقونة مع أنيميشن التكبير والانتقال السلس ─────────────
          AnimatedScale(
            scale: _isPressed ? 0.92 : (widget.isActive ? 1.15 : 1.0),
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOutBack,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(
                    scale: Tween<double>(begin: 0.88, end: 1.0).animate(
                      CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      ),
                    ),
                    child: child,
                  ),
                );
              },
              child: Icon(
                widget.isActive ? widget.activeIcon : widget.inactiveIcon,
                key: ValueKey<int>(
                  widget.isActive
                      ? widget.activeIcon.codePoint
                      : widget.inactiveIcon.codePoint,
                ),
                size: 24,
                color: widget.isActive
                    ? colorScheme.secondary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          const SizedBox(height: 4),

          // ── التسمية ───────────────────────────────────────────
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            style: GoogleFonts.tajawal(
              fontSize: widget.isActive ? 12.5 : 11.5,
              fontWeight: widget.isActive
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: widget.isActive
                  ? colorScheme.secondary
                  : colorScheme.onSurfaceVariant,
            ),
            child: Text(
              widget.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
