import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/features/profile/presentation/widgets/profile_business_section.dart';

/// Settings and preferences group displayed in the user profile screen.
class ProfileSettingsSection extends StatelessWidget {
  const ProfileSettingsSection({
    super.key,
    required this.notificationsEnabled,
    required this.onNotificationsChanged,
    required this.onPrivacyTap,
    required this.onLanguageTap,
    required this.onSupportTap,
    required this.onAboutTap,
  });

  final bool notificationsEnabled;
  final ValueChanged<bool> onNotificationsChanged;
  final VoidCallback onPrivacyTap;
  final VoidCallback onLanguageTap;
  final VoidCallback onSupportTap;
  final VoidCallback onAboutTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ProfileSectionHeader(
          title: 'الإعدادات والتفضيلات',
          icon: Icons.settings_rounded,
        ),
        const SizedBox(height: 15),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 25),
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              _ProfileSettingTile(
                icon: Icons.notifications_none_rounded,
                title: 'الإشعارات',
                showDivider: true,
                trailing: SizedBox(
                  height: 30,
                  child: Transform.scale(
                    scale: 0.8,
                    child: Switch.adaptive(
                      value: notificationsEnabled,
                      onChanged: onNotificationsChanged,
                      activeThumbColor: Colors.white,
                      activeTrackColor: colorScheme.secondary,
                    ),
                  ),
                ),
              ),
              _ProfileSettingTile(
                icon: Icons.shield_outlined,
                title: 'الخصوصية والأمان',
                showDivider: true,
                onTap: onPrivacyTap,
              ),
              _ProfileSettingTile(
                icon: Icons.language_rounded,
                title: 'تغيير اللغة',
                trailing: const _LanguagePill(),
                showDivider: true,
                onTap: onLanguageTap,
              ),
              _ProfileSettingTile(
                icon: Icons.headset_mic_outlined,
                title: 'تواصل مع الدعم',
                showDivider: true,
                onTap: onSupportTap,
              ),
              _ProfileSettingTile(
                icon: Icons.info_outline_rounded,
                title: 'عن شمس',
                showDivider: false,
                onTap: onAboutTap,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ProfileSettingTile extends StatelessWidget {
  const _ProfileSettingTile({
    required this.icon,
    required this.title,
    this.trailing,
    this.onTap,
    this.showDivider = true,
  });

  final IconData icon;
  final String title;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;

    return Column(
      children: [
        ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          horizontalTitleGap: 18,
          leading: Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              color: ext.backgroundLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colorScheme.secondary, size: 22),
          ),
          title: Text(
            title,
            textAlign: TextAlign.right,
            style: GoogleFonts.tajawal(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          trailing: trailing ??
              const Icon(Icons.chevron_left, color: Colors.grey, size: 20),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Divider(
              height: 1,
              color: Colors.grey.withValues(alpha: 0.1),
            ),
          ),
      ],
    );
  }
}

class _LanguagePill extends StatelessWidget {
  const _LanguagePill();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: ext.backgroundLight,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          Text(
            'عربي',
            style: GoogleFonts.tajawal(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}
