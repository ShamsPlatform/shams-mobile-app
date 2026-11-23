import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

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
          child: Container(color: Colors.grey.withValues(alpha: 0.1), height: 1.0),
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
          _buildIntroText(l10n.privacyIntro),
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

  Widget _buildIntroText(String intro) {
    return Text(
      intro,
      style: GoogleFonts.tajawal(
        fontSize: 14,
        height: 1.7,
        color: Colors.grey.shade600,
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
                color: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 18,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: GoogleFonts.tajawal(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onSurface,
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
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 12),
        // خط فاصل خفيف
        Divider(color: Colors.grey.withValues(alpha: 0.15), thickness: 1),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // زر سياسة الخصوصية الكاملة
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildFullPolicyButton(BuildContext context, String label) {
    return Center(
      child: GestureDetector(
        onTap: () {
          // TODO: افتح صفحة سياسة الخصوصية الكاملة
        },
        child: Text(
          label,
          style: GoogleFonts.tajawal(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.secondary,
            decoration: TextDecoration.underline,
            decorationColor: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
    );
  }
}
