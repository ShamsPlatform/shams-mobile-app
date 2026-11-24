import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';

class AboutShamsScreen extends StatelessWidget {
  const AboutShamsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final ext = Theme.of(context).extension<ShamsExtendedColors>()!;
    return Scaffold(
      backgroundColor: colorScheme.surface,

      // ── AppBar ──────────────────────────────────────────────────────────
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
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
      ),

      // ── Body ────────────────────────────────────────────────────────────
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── شعار التطبيق ──────────────────────────────────────────────
            _buildLogo(context),
            const SizedBox(height: 10),

            // ── اسم التطبيق ───────────────────────────────────────────────
            Text(
              l10n.appTitle,
              style: GoogleFonts.tajawal(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 28),

            // ── من نحن؟ ──────────────────────────────────────────────────
            _buildSectionHeader(context, l10n.whoWeAre),
            const SizedBox(height: 10),
            _buildBodyText(context, l10n.aboutDescription),
            const SizedBox(height: 28),

            // ── رؤيتنا ───────────────────────────────────────────────────
            _buildVisionCard(context, l10n),
            const SizedBox(height: 28),

            // ── لماذا تختارنا؟ ────────────────────────────────────────────
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: _buildSectionHeader(context, l10n.whyChooseUs),
            ),
            const SizedBox(height: 16),
            _buildFeaturesGrid(context, l10n),
            const SizedBox(height: 36),

            // ── وسائل التواصل ─────────────────────────────────────────────
            _buildSocialRow(context),
            const SizedBox(height: 16),

            // ── رقم الإصدار ───────────────────────────────────────────────
            Text(
              l10n.versionLabel,
              style: GoogleFonts.tajawal(
                fontSize: 12,
                color: ext.textHint,
              ),
            ),
            const SizedBox(height: 8),
            // ── حقوق النشر ────────────────────────────────────────────────
            Text(
              l10n.copyrightLabel,
              style: GoogleFonts.tajawal(
                fontSize: 11,
                color: ext.textHint,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // شعار التطبيق
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildLogo(BuildContext context) {
    return Container(
      width: 150,
      height: 150,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(100),
      ),
      // padding: const EdgeInsets.all(1),
      child: Image.asset(
        'assets/images/logo/shams logo.png',
        fit: BoxFit.cover,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // عنوان قسم
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.secondary,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            title,
            style: GoogleFonts.tajawal(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // نص توضيحي
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildBodyText(BuildContext context, String text) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: GoogleFonts.tajawal(
        fontSize: 14,
        height: 1.8,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // كارد الرؤية
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildVisionCard(BuildContext context, AppLocalizations l10n) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      color: colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: colorScheme.secondary.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.remove_red_eye_outlined,
                color: colorScheme.onSecondaryContainer,
                size: 26,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.ourVision,
              style: GoogleFonts.tajawal(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.visionDescription,
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: 13,
                height: 1.7,
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // شبكة المميزات — 3 أعمدة
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildFeaturesGrid(BuildContext context, AppLocalizations l10n) {
    // قائمة المميزات
    final List<Map<String, dynamic>> features = [
      {'icon': Icons.bolt_rounded, 'label': l10n.featureAccessibility},
      {'icon': Icons.eco_rounded, 'label': l10n.featureSustainability},
      {'icon': Icons.store_outlined, 'label': l10n.featureDirectWorkshop},
      {'icon': Icons.verified_user_outlined, 'label': l10n.featureHighReliability},
      {'icon': Icons.support_agent_rounded, 'label': l10n.featureContinuousSupport},
      {'icon': Icons.speed_rounded, 'label': l10n.featureFastPerformance},
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale =
            MediaQuery.textScalerOf(context).scale(1.0).clamp(1.0, 2.0);
        final crossAxisCount =
            (constraints.maxWidth < 290 && textScale > 1.25) ? 2 : 3;
        final mainAxisExtent = 54 + 8 + (12 * 1.3 * 2 * textScale) + 20;

        return GridView.builder(
          // منع GridView من التمرير داخل SingleChildScrollView
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 16,
            crossAxisSpacing: 12,
            mainAxisExtent: mainAxisExtent,
          ),
          itemCount: features.length,
          itemBuilder: (context, index) {
            return _buildFeatureItem(
              context: context,
              icon: features[index]['icon'] as IconData,
              label: features[index]['label'] as String,
            );
          },
        );
      },
    );
  }

  Widget _buildFeatureItem({
    required BuildContext context,
    required IconData icon,
    required String label,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: colorScheme.primary.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: colorScheme.primary, size: 26),
        ),
        const SizedBox(height: 8),
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.tajawal(
              fontSize: 12,
              height: 1.25,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────────
  // أيقونات وسائل التواصل الاجتماعي
  // ─────────────────────────────────────────────────────────────────────────────

  Widget _buildSocialRow(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialIcon(context, Icons.camera_alt_outlined), // Instagram
        const SizedBox(width: 20),
        _buildSocialIcon(context, Icons.alternate_email), // X (Twitter)
        const SizedBox(width: 20),
        _buildSocialIcon(context, Icons.facebook_outlined), // Facebook
      ],
    );
  }

  Widget _buildSocialIcon(BuildContext context, IconData icon) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 22, color: Theme.of(context).extension<ShamsExtendedColors>()!.textHint),
    );
  }
}
