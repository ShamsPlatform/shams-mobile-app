import 'package:flutter/material.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shams_mobile_app/core/domain/entities/app_user.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/core/widgets/shams_modals.dart';
import 'package:shams_mobile_app/app/main_screen.dart';

class ShamsDrawer extends StatelessWidget {
  final int activeIndex;
  final AppUser currentUser;
  final VoidCallback onEditProfileTap;
  final VoidCallback onAboutTap;
  final VoidCallback onSignOut;
  final VoidCallback? onWorkshopDashboardTap;
  final ValueChanged<int>? onTabSelected;
  final VoidCallback? onMaintenanceRequestsTap;

  const ShamsDrawer({
    super.key,
    required this.activeIndex,
    required this.currentUser,
    required this.onEditProfileTap,
    required this.onAboutTap,
    required this.onSignOut,
    this.onWorkshopDashboardTap,
    this.onTabSelected,
    this.onMaintenanceRequestsTap,
  });

  void _navigateTo(BuildContext context, int index) {
    Navigator.pop(context);
    if (activeIndex == index) return;
    if (onTabSelected != null) {
      onTabSelected!(index);
    } else {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => MainScreen(initialIndex: index),
        ),
        (route) => false,
      );
    }
  }

  void _showSupportMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showShamsModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return Material(
          color: colorScheme.surface,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(25)),
          clipBehavior: Clip.antiAlias,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(25, 15, 25, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ShamsSheetHandle(),
                  const SizedBox(height: 20),
                  Text(
                    l10n.technicalSupportTitle,
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ShamsSupportOptionTile(
                    icon: Icons.chat_bubble_outline_rounded,
                    iconColor: const Color(0xFF25D366),
                    title: l10n.whatsapp,
                    subtitle: '+967 776 434 968',
                    subtitleTextDirection: TextDirection.ltr,
                    onTap: () async {
                      Navigator.pop(context);
                      final Uri url =
                          Uri.parse('https://wa.me/967776434968');
                      try {
                        await launchUrl(url,
                            mode: LaunchMode.externalApplication);
                      } catch (_) {}
                    },
                  ),
                  const SizedBox(height: 10),
                  ShamsSupportOptionTile(
                    icon: Icons.phone_in_talk_outlined,
                    iconColor: colorScheme.primary,
                    title: l10n.phoneCall,
                    subtitle: '+967 776 434 968',
                    subtitleTextDirection: TextDirection.ltr,
                    onTap: () async {
                      Navigator.pop(context);
                      final Uri url = Uri.parse('tel:+967776434968');
                      try {
                        await launchUrl(url);
                      } catch (_) {}
                    },
                  ),
                  const SizedBox(height: 10),
                  ShamsSupportOptionTile(
                    icon: Icons.email_outlined,
                    iconColor: colorScheme.primary,
                    title: l10n.emailFull,
                    subtitle: 'codyvex1@gmail.com',
                    subtitleTextDirection: TextDirection.ltr,
                    onTap: () async {
                      Navigator.pop(context);
                      final Uri url =
                          Uri.parse('mailto:codyvex1@gmail.com');
                      try {
                        await launchUrl(url);
                      } catch (_) {}
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showShamsDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.logout_rounded,
                color: colorScheme.error,
                size: 40,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.logoutTitle,
                style: GoogleFonts.tajawal(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.logoutConfirm,
                textAlign: TextAlign.center,
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  color: colorScheme.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: ext.borderLight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        l10n.cancel,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.tajawal(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(0, 44),
                        backgroundColor: colorScheme.error,
                        foregroundColor: colorScheme.onError,
                        elevation: 0,
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        l10n.logout,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.tajawal(
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    if (confirmed == true && context.mounted) {
      onSignOut();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = currentUser;
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    final hasAvatar = user.profileImageUrl != null &&
        user.profileImageUrl!.isNotEmpty &&
        user.profileImageUrl!.startsWith('http');

    return Drawer(
      child: Column(
        children: [
          // ── Drawer Header ──────────────────────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: [
                  Color(0xFF003D99), // Deep Royal Blue (>7:1 contrast)
                  Color(0xFF0052CC), // Shams Brand Blue
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: ext.avatarFallbackBg,
                      backgroundImage: hasAvatar
                          ? NetworkImage(user.profileImageUrl!)
                          : null,
                      child: !hasAvatar
                          ? Text(
                              user.name.isNotEmpty
                                  ? user.name[0].toUpperCase()
                                  : 'U',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF003D99),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Flexible(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: user.hasWorkshop
                              ? colorScheme.secondary
                              : Colors.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(20),
                          border: user.hasWorkshop
                              ? null
                              : Border.all(
                                  color: Colors.white.withValues(alpha: 0.35),
                                  width: 1.0,
                                ),
                        ),
                        child: Text(
                          user.hasWorkshop
                              ? l10n.workshopOwner
                              : l10n.shamsClient,
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: user.hasWorkshop
                                ? colorScheme.onSecondary
                                : Colors.white,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  user.name == 'جاري التحميل...' ? l10n.loadingLabel : user.name,
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.88),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // ── Menu Items ─────────────────────────────────────────────────
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // ── Group 1: Navigation Tabs ─────────────────────────────
                _buildMenuItem(
                  context: context,
                  icon: Icons.home_rounded,
                  title: l10n.home,
                  isSelected: activeIndex == 0,
                  onTap: () => _navigateTo(context, 0),
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.engineering_rounded,
                  title: l10n.workshops,
                  isSelected: activeIndex == 1,
                  onTap: () => _navigateTo(context, 1),
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.chat_bubble_outline_rounded,
                  title: l10n.myChats,
                  isSelected: activeIndex == 2,
                  onTap: () => _navigateTo(context, 2),
                ),

                // ── Subtle Divider between Navigation and Account Utilities ──
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Divider(color: ext.dividerLight, height: 1),
                ),

                // ── Group 2: Account & Maintenance Utilities ─────────────
                _buildMenuItem(
                  context: context,
                  icon: Icons.edit_note_rounded,
                  title: l10n.editMyProfile,
                  isSelected: false,
                  onTap: () {
                    Navigator.pop(context);
                    onEditProfileTap();
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.build_circle_outlined,
                  title: l10n.myMaintenanceRequests,
                  isSelected: false,
                  onTap: () {
                    Navigator.pop(context);
                    if (onMaintenanceRequestsTap != null) {
                      onMaintenanceRequestsTap!();
                    }
                  },
                ),

                // ── Subtle Divider between Account and Support/Platform ────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Divider(color: ext.dividerLight, height: 1),
                ),

                // ── Group 3: Platform Information & Support ───────────────
                _buildMenuItem(
                  context: context,
                  icon: Icons.info_outline_rounded,
                  title: l10n.aboutShamsPlatform,
                  isSelected: false,
                  onTap: () {
                    Navigator.pop(context);
                    onAboutTap();
                  },
                ),
                _buildMenuItem(
                  context: context,
                  icon: Icons.support_agent_rounded,
                  title: l10n.technicalSupportContact,
                  isSelected: false,
                  onTap: () {
                    Navigator.pop(context);
                    _showSupportMenu(context);
                  },
                ),

                // ── Group 4: Workshop Management (Conditional) ───────────
                if (user.hasWorkshop) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 6),
                    child: Divider(color: ext.dividerLight, height: 1),
                  ),
                  _buildMenuItem(
                    context: context,
                    icon: Icons.dashboard_customize_rounded,
                    title: l10n.workshopDashboard,
                    isSelected: false,
                    onTap: () {
                      Navigator.pop(context);
                      onWorkshopDashboardTap?.call();
                    },
                  ),
                ],
              ],
            ),
          ),

          // ── Footer (Logout) ────────────────────────────────────────────
          Divider(color: ext.dividerLight, height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: _buildMenuItem(
              context: context,
              icon: Icons.logout_rounded,
              title: l10n.logout,
              isSelected: false,
              textColor: colorScheme.error,
              iconColor: colorScheme.error,
              onTap: () => _handleLogout(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    Color? textColor,
    Color? iconColor,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;

    final finalTextColor = textColor ??
        (isSelected ? colorScheme.primary : colorScheme.onSurface);
    final finalIconColor = iconColor ??
        (isSelected ? colorScheme.primary : ext.textHint);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      child: Material(
        color: isSelected
            ? colorScheme.primary.withValues(alpha: 0.08)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        clipBehavior: Clip.antiAlias,
        child: ListTile(
          leading: Icon(icon, color: finalIconColor, size: 22),
          title: Text(
            title,
            style: GoogleFonts.tajawal(
              fontSize: 14,
              fontWeight:
                  isSelected ? FontWeight.bold : FontWeight.w500,
              color: finalTextColor,
            ),
          ),
          onTap: onTap,
          dense: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
