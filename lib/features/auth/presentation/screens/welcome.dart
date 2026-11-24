import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/core/widgets/primary_button.dart';
import 'package:shams_mobile_app/core/widgets/outlined_button.dart';
import 'package:shams_mobile_app/features/auth/presentation/screens/signin.dart';
import 'package:shams_mobile_app/features/auth/presentation/screens/signup.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<ShamsExtendedColors>()!;

    return Scaffold(
      backgroundColor: ext.backgroundLight,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const Spacer(flex: 2),
                      // ── الشعار والاسم ──
                      Image.asset('assets/images/logo/shams logo.png', height: 100),
                      const SizedBox(height: 16),
                      Text(
                        l10n.appTitle,
                        style: GoogleFonts.tajawal(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      ),
                      Text(
                        l10n.welcomeTagline,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          color: ext.textHint,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Spacer(),
                      // ── بطاقات المميزات (Feature Highlights) ──
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildFeatureCard(context, Icons.bolt_rounded, l10n.highEfficiency),
                            const SizedBox(width: 16),
                            _buildFeatureCard(context, Icons.settings_suggest_rounded, l10n.smartControl),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Spacer(),
                      // ── الأزرار الأساسية ──
                      ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 52),
                        child: SizedBox(
                          width: double.infinity,
                          child: CustomSolidButton(
                            title: l10n.signup,
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen())),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ConstrainedBox(
                        constraints: const BoxConstraints(minHeight: 52),
                        child: SizedBox(
                          width: double.infinity,
                          child: CustomOutlinedButton(
                            title: l10n.signin,
                            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignInScreen())),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        l10n.termsOfServiceNotice,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.tajawal(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, IconData icon, String label) {
    final colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: colorScheme.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GoogleFonts.tajawal(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

