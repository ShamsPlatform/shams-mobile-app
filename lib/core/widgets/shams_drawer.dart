import 'package:flutter/material.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shams_mobile_app/core/domain/entities/app_user.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/app/main_screen.dart';

class ShamsDrawer extends StatelessWidget {
  final int activeIndex;
  final AppUser currentUser;
  final VoidCallback onEditProfileTap;
  final VoidCallback onAboutTap;
  final VoidCallback onSignOut;
  final VoidCallback? onWorkshopDashboardTap;

  const ShamsDrawer({
    super.key,
    required this.activeIndex,
    required this.currentUser,
    required this.onEditProfileTap,
    required this.onAboutTap,
    required this.onSignOut,
    this.onWorkshopDashboardTap,
  });

  void _navigateTo(BuildContext context, int index) {
    Navigator.pop(context);
    if (activeIndex == index) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (context) => MainScreen(initialIndex: index),
      ),
      (route) => false,
    );
  }

  void _showSupportMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final ext = Theme.of(context).extension<ShamsExtendedColors>()!;

        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(25)),
          ),
          padding: const EdgeInsets.fromLTRB(25, 15, 25, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: ext.handleBar,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.technicalSupportTitle,
                style: GoogleFonts.tajawal(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: Color(0xFF25D366),
                ),
                title: Text(l10n.whatsapp,
                    style: GoogleFonts.tajawal(fontSize: 16)),
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
              ListTile(
                leading: Icon(
                  Icons.phone_in_talk_outlined,
                  color: colorScheme.primary,
                ),
                title: Text(
                  l10n.phoneCall,
                  style: GoogleFonts.tajawal(fontSize: 16),
                ),
                onTap: () async {
                  Navigator.pop(context);
                  final Uri url = Uri.parse('tel:+967776434968');
                  try {
                    await launchUrl(url);
                  } catch (_) {}
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.email_outlined,
                  color: Colors.orange,
                ),
                title: Text(
                  l10n.emailFull,
                  style: GoogleFonts.tajawal(fontSize: 16),
                ),
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
        );
      },
    );
  }

  Future<void> _handleLogout(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20)),
        child: Padding(
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
                        padding:
                            const EdgeInsets.symmetric(vertical: 12),
                        side: BorderSide(color: ext.borderLight),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        l10n.cancel,
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
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: AlignmentDirectional.topEnd,
                end: AlignmentDirectional.bottomStart,
                colors: [
                  colorScheme.primary,
                  colorScheme.primaryContainer,
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
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: user.hasWorkshop
                            ? colorScheme.secondary
                            : colorScheme.onPrimary
                                .withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
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
                              : colorScheme.onPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  user.name,
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: GoogleFonts.tajawal(
                    fontSize: 13,
                    color: colorScheme.onPrimary.withValues(alpha: 0.7),
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
                  onTap: () => _navigateTo(context, 2),
                ),
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
                if (user.hasWorkshop) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    child: Divider(color: ext.borderLight, height: 1),
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
          Divider(color: ext.borderLight, height: 1),
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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: isSelected
            ? colorScheme.primary.withValues(alpha: 0.06)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
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
    );
  }
}
