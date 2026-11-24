import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/l10n/l10n_mappers.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/core/widgets/primary_button.dart';
import 'package:shams_mobile_app/core/widgets/shams_modals.dart';
import 'package:shams_mobile_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';

/// Displays the technical support bottom sheet with external contact actions.
void showProfileSupportSheet(
  BuildContext context, {
  required void Function(String message, {bool isError}) onShowMessage,
}) {
  Future<void> launchContact(String uriString, String failureMessage) async {
    try {
      final success = await launchUrl(
        Uri.parse(uriString),
        mode: LaunchMode.externalApplication,
      );
      if (!success) {
        onShowMessage(failureMessage, isError: true);
      }
    } catch (_) {
      onShowMessage(failureMessage, isError: true);
    }
  }

  showShamsModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final colorScheme = Theme.of(sheetContext).colorScheme;
      final l10n = AppLocalizations.of(sheetContext)!;
      return Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
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
                  l10n.contactSupport,
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
                  onTap: () {
                    Navigator.pop(sheetContext);
                    launchContact(
                      'https://wa.me/967776434968',
                      l10n.whatsappError,
                    );
                  },
                ),
                const SizedBox(height: 10),
                ShamsSupportOptionTile(
                  icon: Icons.phone_in_talk_outlined,
                  iconColor: colorScheme.primary,
                  title: l10n.phoneCall,
                  subtitle: '+967 776 434 968',
                  subtitleTextDirection: TextDirection.ltr,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    launchContact(
                      'tel:+967776434968',
                      l10n.phoneError,
                    );
                  },
                ),
                const SizedBox(height: 10),
                ShamsSupportOptionTile(
                  icon: Icons.email_outlined,
                  iconColor: colorScheme.primary,
                  title: l10n.email,
                  subtitle: 'codyvex1@gmail.com',
                  subtitleTextDirection: TextDirection.ltr,
                  onTap: () {
                    Navigator.pop(sheetContext);
                    launchContact(
                      'mailto:codyvex1@gmail.com',
                      l10n.emailError,
                    );
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

/// Displays the sign-out confirmation bottom sheet.
void showProfileLogoutSheet(BuildContext context) {
  showShamsModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final colorScheme = Theme.of(sheetContext).colorScheme;
      final ext = Theme.of(sheetContext).extension<ShamsExtendedColors>()!;
      final l10n = AppLocalizations.of(sheetContext)!;
      return Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
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
                  l10n.logoutTitle,
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.error,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  l10n.logoutConfirm,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(
                    fontSize: 15,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 25),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(sheetContext),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size(0, 44),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: ext.borderLight),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l10n.cancel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.tajawal(
                            fontSize: 16,
                            color: colorScheme.onSurface,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final authProvider = sheetContext.read<AuthProvider>();
                          final ok = await authProvider.signOut();
                          if (!ok && sheetContext.mounted) {
                            Navigator.pop(sheetContext);
                            ScaffoldMessenger.of(sheetContext).showSnackBar(
                              SnackBar(
                                content: Text(
                                  l10n.localizeErrorMessage(
                                    authProvider.errorMessage,
                                    fallback: l10n.logoutError,
                                  ),
                                  style: GoogleFonts.tajawal(
                                    color: colorScheme.onError,
                                  ),
                                ),
                                backgroundColor: colorScheme.error,
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(0, 44),
                          backgroundColor: colorScheme.error,
                          foregroundColor: colorScheme.onError,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          l10n.logout,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.tajawal(
                            fontSize: 16,
                            color: colorScheme.onError,
                            fontWeight: FontWeight.bold,
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
      );
    },
  );
}

/// Displays the app language selection bottom sheet.
void showProfileLanguageSheet(
  BuildContext context, {
  required String initialLanguage,
  required ValueChanged<String> onSave,
}) {
  var tempLang = initialLanguage;
  showShamsModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) => StatefulBuilder(
      builder: (modalContext, setModalState) {
        final colorScheme = Theme.of(modalContext).colorScheme;
        final l10n = AppLocalizations.of(modalContext)!;
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(25),
            ),
          ),
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
                    l10n.changeLanguage,
                    style: GoogleFonts.tajawal(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 20),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setModalState(() => tempLang = 'ar'),
                    child: _LangOptionCard(
                      label: l10n.arabicOption,
                      selected: tempLang == 'ar',
                    ),
                  ),
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setModalState(() => tempLang = 'en'),
                    child: _LangOptionCard(
                      label: l10n.englishOption,
                      selected: tempLang == 'en',
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: CustomSolidButton(
                      title: l10n.save,
                      onPressed: () {
                        onSave(tempLang);
                        Navigator.pop(modalContext);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ),
  );
}

class _LangOptionCard extends StatelessWidget {
  const _LangOptionCard({
    required this.label,
    required this.selected,
  });

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: selected
            ? colorScheme.primary.withValues(alpha: 0.08)
            : colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? colorScheme.primary : ext.borderLight,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.tajawal(
              fontWeight: selected ? FontWeight.bold : FontWeight.normal,
              color: colorScheme.onSurface,
            ),
          ),
          Icon(
            selected
                ? Icons.check_circle_rounded
                : Icons.radio_button_unchecked_rounded,
            color: selected ? colorScheme.primary : ext.textHint,
          ),
        ],
      ),
    );
  }
}
