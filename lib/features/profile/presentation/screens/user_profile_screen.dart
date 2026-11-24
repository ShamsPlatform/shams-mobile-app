import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/l10n/language_provider.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/core/widgets/primary_button.dart';
import 'package:shams_mobile_app/features/profile/presentation/providers/profile_provider.dart';
import 'package:shams_mobile_app/features/profile/presentation/screens/about_shams_screen.dart';
import 'package:shams_mobile_app/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:shams_mobile_app/features/profile/presentation/screens/privacy_security_screen.dart';
import 'package:shams_mobile_app/features/profile/presentation/widgets/profile_bottom_sheets.dart';
import 'package:shams_mobile_app/features/profile/presentation/widgets/profile_business_section.dart';
import 'package:shams_mobile_app/features/profile/presentation/widgets/profile_header_card.dart';
import 'package:shams_mobile_app/features/profile/presentation/widgets/profile_settings_section.dart';
import 'package:shams_mobile_app/features/workshops/presentation/screens/add_workshop_screen.dart';
import 'package:shams_mobile_app/features/workshops/presentation/screens/workshop_dashboard_screen.dart';

/// User profile screen coordinating header summary, workshop entry point,
/// preferences, app sharing, and sign-out.
class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  bool _isNotificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProfileProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<ShamsExtendedColors>()!;
    final l10n = AppLocalizations.of(context)!;
    final languageProvider = context.watch<LanguageProvider>();
    final currentUser =
        context.watch<ProfileProvider>().currentUserOrPlaceholder;
    final topPadding = MediaQuery.paddingOf(context).top;

    final overlayStyle = (theme.brightness == Brightness.dark
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.dark)
        .copyWith(statusBarColor: Colors.transparent);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: Scaffold(
        backgroundColor: colorScheme.surface,
        body: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  ProfileHeaderCard(
                    currentUser: currentUser,
                    onEditProfileTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const EditProfileScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  ProfileBusinessSection(
                    hasWorkshop: currentUser.hasWorkshop,
                    onTap: currentUser.hasWorkshop
                        ? _openWorkshopDashboard
                        : _openAddWorkshop,
                  ),
                  const SizedBox(height: 30),
                  ProfileSettingsSection(
                    notificationsEnabled: _isNotificationsEnabled,
                    onNotificationsChanged: (v) =>
                        setState(() => _isNotificationsEnabled = v),
                    onPrivacyTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PrivacySecurityScreen(),
                        ),
                      );
                    },
                    onLanguageTap: () => showProfileLanguageSheet(
                      context,
                      initialLanguage:
                          languageProvider.currentLocale.languageCode,
                      onSave: (lang) {
                        final targetLocale = lang == 'en'
                            ? const Locale('en', 'US')
                            : const Locale('ar', 'SA');
                        context
                            .read<LanguageProvider>()
                            .changeLanguage(targetLocale);
                      },
                    ),
                    onSupportTap: () => showProfileSupportSheet(
                      context,
                      onShowMessage: _showSnackBar,
                    ),
                    onAboutTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AboutShamsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: CustomSolidButton(
                      title: l10n.shareApp,
                      onPressed: () {
                        SharePlus.instance.share(
                          ShareParams(
                            text: l10n.shareAppText,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextButton.icon(
                    onPressed: () => showProfileLogoutSheet(context),
                    icon: Icon(
                      Icons.logout_rounded,
                      color: colorScheme.error,
                      size: 20,
                    ),
                    label: Text(
                      l10n.logout,
                      style: GoogleFonts.tajawal(
                        color: colorScheme.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
            if (topPadding > 0)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: topPadding,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: ext.backgroundLight.withValues(alpha: 0.92),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _openAddWorkshop() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddWorkshopScreen()),
    ).then((_) {
      if (!mounted) return;
      final hasWorkshop =
          context.read<ProfileProvider>().currentUserOrPlaceholder.hasWorkshop;
      if (hasWorkshop) {
        final l10n = AppLocalizations.of(context)!;
        _showSnackBar(l10n.workshopCreatedSuccess);
      }
    });
  }

  void _openWorkshopDashboard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const WorkshopDashboardScreen()),
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;
    final colorScheme = Theme.of(context).colorScheme;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isError ? colorScheme.onError : colorScheme.onTertiary,
          ),
        ),
        backgroundColor: isError ? colorScheme.error : colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
