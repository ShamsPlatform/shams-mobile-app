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
    return Scaffold(
        backgroundColor:
            Theme.of(context).extension<ShamsExtendedColors>()!.backgroundLight,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
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
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
                Text(
                  l10n.welcomeTagline,
                  style: GoogleFonts.tajawal(
                    fontSize: 14,
                    color: Theme.of(context).extension<ShamsExtendedColors>()!.textHint,
                  ),
                ),
                const Spacer(),
                // ── بطاقات المميزات (Feature Highlights) ──
                Row(
                  children: [
                    _buildFeatureCard(context, Icons.bolt_rounded, l10n.highEfficiency),
                    const SizedBox(width: 16),
                    _buildFeatureCard(context, Icons.settings_suggest_rounded, l10n.smartControl),
                  ],
                ),
                const Spacer(),
                // ── الأزرار الأساسية ──
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: CustomSolidButton(
                    title: l10n.signup,
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen())),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: CustomOutlinedButton(
                    title: l10n.signin,
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SignInScreen())),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  l10n.termsOfServiceNotice,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.tajawal(fontSize: 11, color: const Color(0xFFBFC3CE)),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      );
  }

  Widget _buildFeatureCard(BuildContext context, IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Theme.of(context).colorScheme.primary, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.tajawal(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

