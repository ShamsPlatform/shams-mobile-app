import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/l10n/l10n_mappers.dart';
import 'package:shams_mobile_app/core/widgets/primary_button.dart';
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

  showModalBottomSheet(
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
        padding: const EdgeInsets.fromLTRB(25, 15, 25, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              l10n.contactSupport,
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
              title: Text(l10n.whatsapp, style: GoogleFonts.tajawal(fontSize: 16)),
              onTap: () {
                Navigator.pop(sheetContext);
                launchContact(
                  'https://wa.me/967776434968',
                  l10n.whatsappError,
                );
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
              onTap: () {
                Navigator.pop(sheetContext);
                launchContact(
                  'tel:+967776434968',
                  l10n.phoneError,
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.email_outlined, color: Colors.orange),
              title: Text(l10n.email, style: GoogleFonts.tajawal(fontSize: 16)),
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
      );
    },
  );
}

/// Displays the sign-out confirmation bottom sheet.
void showProfileLogoutSheet(BuildContext context) {
  showModalBottomSheet(
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
        padding: const EdgeInsets.fromLTRB(25, 15, 25, 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
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
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.cancel,
                      style: GoogleFonts.tajawal(
                        fontSize: 16,
                        color: Colors.grey.shade700,
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
                              style: GoogleFonts.tajawal(),
                            ),
                            backgroundColor: colorScheme.error,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.error,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      l10n.logout,
                      style: GoogleFonts.tajawal(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
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
  showModalBottomSheet(
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
          padding: const EdgeInsets.fromLTRB(25, 15, 25, 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                l10n.changeLanguage,
                style: GoogleFonts.tajawal(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => setModalState(() => tempLang = 'ar'),
                child: _LangOptionCard(
                  label: l10n.arabicOption,
                  selected: tempLang == 'ar',
                ),
              ),
              GestureDetector(
                onTap: () => setModalState(() => tempLang = 'en'),
                child: _LangOptionCard(
                  label: l10n.englishOption,
                  selected: tempLang == 'en',
                ),
              ),
              const SizedBox(height: 25),
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

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: selected ? colorScheme.secondaryContainer : colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? colorScheme.secondary : Colors.transparent,
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
          if (selected)
            Icon(Icons.check_box, color: colorScheme.secondary)
          else
            const Icon(
              Icons.check_box_outline_blank,
              color: Colors.grey,
            ),
        ],
      ),
    );
  }
}
