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
      activeIcon: Icons.people_alt_rounded,
      inactiveIcon: Icons.people_alt_outlined,
      label: 'followNav',
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

class _NavBarItemState extends State<_NavBarItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _iconSizeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    _scaleAnim = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _iconSizeAnim = Tween<double>(begin: 24.0, end: 28.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.isActive) _controller.value = 1.0;
  }

  @override
  void didUpdateWidget(_NavBarItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _controller.forward(from: 0.0);
    } else if (!widget.isActive && oldWidget.isActive) {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── نقطة المؤشر ───────────────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                width: widget.isActive ? 20 : 0,
                height: 3,
                margin: const EdgeInsets.only(bottom: 5),
                decoration: BoxDecoration(
                  color: colorScheme.secondary,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),

              // ── الأيقونة ──────────────────────────────────────────
              ScaleTransition(
                scale: _scaleAnim,
                child: Icon(
                  widget.isActive ? widget.activeIcon : widget.inactiveIcon,
                  size: widget.isActive ? _iconSizeAnim.value : 24,
                  color: widget.isActive
                      ? colorScheme.secondary
                      : colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 4),

              // ── التسمية ───────────────────────────────────────────
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: GoogleFonts.tajawal(
                  fontSize: widget.isActive ? 12.5 : 11.5,
                  fontWeight: widget.isActive
                      ? FontWeight.w700
                      : FontWeight.w400,
                  color: widget.isActive
                      ? colorScheme.secondary
                      : colorScheme.onSurfaceVariant,
                ),
                child: Text(widget.label),
              ),
            ],
          );
        },
      ),
    );
  }
}
