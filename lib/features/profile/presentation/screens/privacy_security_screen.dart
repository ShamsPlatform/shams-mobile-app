import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/core/widgets/shams_modals.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: colorScheme.onSurface,
            size: 26,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(color: ext.dividerLight, height: 1.0),
        ),
        title: Text(
          l10n.privacySecurity,
          style: GoogleFonts.tajawal(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ),

      // ── Body ────────────────────────────────────────────────────────────
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        children: [
          // ── مقدمة ───────────────────────────────────────────────────────
          _buildIntroText(context, l10n.privacyIntro),
          const SizedBox(height: 28),

          // ── تشفير البيانات ──────────────────────────────────────────────
          _buildSection(
            context: context,
            icon: Icons.lock_outline_rounded,
            title: l10n.dataEncryption,
            body: l10n.dataEncryptionBody,
          ),
          const SizedBox(height: 24),

          // ── أمان الحساب ─────────────────────────────────────────────────
          _buildSection(
            context: context,
            icon: Icons.security_rounded,
            title: l10n.accountSecurity,
            body: l10n.accountSecurityBody,
          ),
          const SizedBox(height: 24),

          // ── مشاركة المعلومات ────────────────────────────────────────────
          _buildSection(
            context: context,
            icon: Icons.share_outlined,
            title: l10n.informationSharing,
            body: l10n.informationSharingBody,
          ),
          const SizedBox(height: 24),

          // ── الوصول للموقع ───────────────────────────────────────────────
          _buildSection(
            context: context,
            icon: Icons.location_on_outlined,
            title: l10n.locationAccess,
            body: l10n.locationAccessBody,
          ),
          const SizedBox(height: 40),

          // ── سياسة الخصوصية الكاملة ──────────────────────────────────────
          _buildFullPolicyButton(context, l10n.fullPrivacyPolicy),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // المقدمة النصية
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildIntroText(BuildContext context, String intro) {
    return Text(
      intro,
      style: GoogleFonts.tajawal(
        fontSize: 14,
        height: 1.7,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // قسم واحد: أيقونة + عنوان + نص
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildSection({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String body,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // العنوان مع الأيقونة
        Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 18,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.tajawal(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // النص التوضيحي
        Text(
          body,
          style: GoogleFonts.tajawal(
            fontSize: 13,
            height: 1.7,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        // خط فاصل خفيف
        Divider(color: ext.dividerLight, thickness: 1),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // زر سياسة الخصوصية الكاملة
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildFullPolicyButton(BuildContext context, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Center(
      child: OutlinedButton.icon(
        onPressed: () => _showFullPolicyModal(context),
        icon: const Icon(Icons.open_in_new_rounded, size: 18),
        label: Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          foregroundColor: colorScheme.primary,
          side: BorderSide(color: colorScheme.primary, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  void _showFullPolicyModal(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;

    showShamsModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(24, 14, 24, 24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Center(child: ShamsSheetHandle()),
                    const SizedBox(height: 16),
                    Text(
                      l10n.fullPrivacyPolicy,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.tajawal(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.privacyIntro,
                      style: GoogleFonts.tajawal(
                        fontSize: 13.5,
                        height: 1.7,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildPolicySummaryItem(
                      sheetContext,
                      title: l10n.dataEncryption,
                      body: l10n.dataEncryptionBody,
                    ),
                    _buildPolicySummaryItem(
                      sheetContext,
                      title: l10n.accountSecurity,
                      body: l10n.accountSecurityBody,
                    ),
                    _buildPolicySummaryItem(
                      sheetContext,
                      title: l10n.informationSharing,
                      body: l10n.informationSharingBody,
                    ),
                    _buildPolicySummaryItem(
                      sheetContext,
                      title: l10n.locationAccess,
                      body: l10n.locationAccessBody,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.copyrightLabel,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.tajawal(
                        fontSize: 12,
                        color: ext.textHint,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton(
                      onPressed: () => Navigator.pop(sheetContext),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 48),
                        foregroundColor: colorScheme.primary,
                        side: BorderSide(color: colorScheme.primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        l10n.close,
                        style: GoogleFonts.tajawal(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPolicySummaryItem(
    BuildContext context, {
    required String title,
    required String body,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: ext.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ext.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.tajawal(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: GoogleFonts.tajawal(
              fontSize: 12.5,
              height: 1.6,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
