import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
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
                'تواصل مع الدعم',
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
                title: Text('واتساب', style: GoogleFonts.tajawal(fontSize: 16)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  launchContact(
                    'https://wa.me/967776434968',
                    'لم نتمكن من فتح تطبيق واتساب. يرجى التأكد من تثبيت التطبيق.',
                  );
                },
              ),
              ListTile(
                leading: Icon(
                  Icons.phone_in_talk_outlined,
                  color: colorScheme.primary,
                ),
                title: Text(
                  'اتصال هاتفي',
                  style: GoogleFonts.tajawal(fontSize: 16),
                ),
                onTap: () {
                  Navigator.pop(sheetContext);
                  launchContact(
                    'tel:+967776434968',
                    'تعذر إجراء الاتصال الهاتفي حالياً.',
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.email_outlined, color: Colors.orange),
                title: Text('إيميل', style: GoogleFonts.tajawal(fontSize: 16)),
                onTap: () {
                  Navigator.pop(sheetContext);
                  launchContact(
                    'mailto:codyvex1@gmail.com',
                    'لم نتمكن من فتح تطبيق البريد الإلكتروني.',
                  );
                },
              ),
            ],
          ),
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
      return Directionality(
        textDirection: TextDirection.rtl,
        child: Container(
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
                'تسجيل الخروج',
                style: GoogleFonts.tajawal(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.error,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'هل أنت متأكد أنك تريد تسجيل الخروج؟',
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
                        'إلغاء',
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
                                authProvider.errorMessage ??
                                    'حدث خطأ أثناء تسجيل الخروج',
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
                        'تسجيل الخروج',
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
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
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
                  'تغيير اللغة',
                  style: GoogleFonts.tajawal(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => setModalState(() => tempLang = 'ar'),
                  child: _LangOptionCard(
                    label: 'عربي (AR)',
                    selected: tempLang == 'ar',
                  ),
                ),
                GestureDetector(
                  onTap: () {},
                  child: const _LangOptionCard(
                    label: 'English (EN)',
                    selected: false,
                    badgeText: 'قريباً',
                  ),
                ),
                const SizedBox(height: 25),
                CustomSolidButton(
                  title: 'حفظ',
                  onPressed: () {
                    onSave(tempLang);
                    Navigator.pop(modalContext);
                  },
                ),
              ],
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
    this.badgeText,
  });

  final String label;
  final bool selected;
  final String? badgeText;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDisabled = badgeText != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: selected
            ? colorScheme.secondaryContainer
            : (isDisabled
                ? colorScheme.surfaceContainerHighest
                : colorScheme.surface),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected ? colorScheme.secondary : Colors.transparent,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                label,
                style: GoogleFonts.tajawal(
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  color: isDisabled
                      ? Colors.grey.shade400
                      : colorScheme.onSurface,
                ),
              ),
              if (badgeText != null) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    badgeText!,
                    style: GoogleFonts.tajawal(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (selected)
            Icon(Icons.check_box, color: colorScheme.secondary)
          else
            Icon(
              Icons.check_box_outline_blank,
              color: isDisabled ? Colors.grey.shade300 : Colors.grey,
            ),
        ],
      ),
    );
  }
}
