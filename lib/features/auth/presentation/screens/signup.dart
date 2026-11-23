import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/core/l10n/generated/app_localizations.dart';
import 'package:shams_mobile_app/core/l10n/l10n_mappers.dart';
import 'package:shams_mobile_app/core/theme/shams_colors.dart';
import 'package:shams_mobile_app/core/widgets/outlined_button.dart';
import 'package:shams_mobile_app/core/widgets/primary_button.dart';
import 'package:shams_mobile_app/core/widgets/text_field.dart';
import 'package:shams_mobile_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:shams_mobile_app/features/auth/presentation/screens/signin.dart';
import 'package:shams_mobile_app/features/auth/presentation/screens/signup_profile_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  final _confirmPassController = TextEditingController();

  String? _emailError, _passError, _confirmPassError;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  void _handleNext() {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final password = _passController.text.trim();
    final confirmPassword = _confirmPassController.text.trim();

    setState(() {
      _emailError = !email.contains('@') ? l10n.invalidEmail : null;
      _passError =
          password.length < 6 ? l10n.passwordTooShort : null;
      _confirmPassError =
          password != confirmPassword ? l10n.passwordsDoNotMatch : null;
    });

    if (_emailError == null && _passError == null && _confirmPassError == null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SignUpProfileScreen(
            email: email,
            password: password,
          ),
        ),
      );
    }
  }

  Future<void> _handleGoogleSignUp() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final ok = await authProvider.signInWithGoogle();
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.localizeErrorMessage(
                authProvider.errorMessage,
                fallback: l10n.signUpError,
              ),
              style: GoogleFonts.tajawal(),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
        backgroundColor: Theme.of(context).extension<ShamsExtendedColors>()!.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(l10n.joinShamsCommunity, style: GoogleFonts.tajawal(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 8),
              Text(l10n.signUpSubtitle, style: GoogleFonts.tajawal(fontSize: 14, color: Theme.of(context).extension<ShamsExtendedColors>()!.textHint)),
              const SizedBox(height: 32),
              // ── بطاقة الإدخال ──
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 20,
                  ),
                ],
              ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _inputLabel(l10n.emailFull),
                    CustomTextField(hintText: 'example@mail.com', prefixIcon: Icons.email_outlined, controller: _emailController, errorText: _emailError),
                    const SizedBox(height: 16),
                    _inputLabel(l10n.password),
                    CustomTextField(hintText: '••••••••', prefixIcon: Icons.lock_outline, isPassword: true, controller: _passController, errorText: _passError),
                    const SizedBox(height: 16),
                    _inputLabel(l10n.confirmPassword),
                    CustomTextField(hintText: '••••••••', prefixIcon: Icons.lock_outline, isPassword: true, controller: _confirmPassController, errorText: _confirmPassError),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: CustomSolidButton(title: l10n.next, onPressed: _handleNext),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: Divider(
                            color: Theme.of(context)
                                .extension<ShamsExtendedColors>()!
                                .borderLight,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            l10n.orSignUpWith,
                            style: GoogleFonts.tajawal(
                              color: Theme.of(context)
                                  .extension<ShamsExtendedColors>()!
                                  .textHint,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        Expanded(
                          child: Divider(
                            color: Theme.of(context)
                                .extension<ShamsExtendedColors>()!
                                .borderLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: _isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            )
                          : CustomOutlinedButton(
                              title: 'Google',
                              icon: const Icon(Icons.g_mobiledata_rounded),
                              onPressed: _handleGoogleSignUp,
                            ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l10n.alreadyHaveAccount,
                    style: GoogleFonts.tajawal(
                      color: Theme.of(context).extension<ShamsExtendedColors>()!.textHint,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignInScreen()),
                    ),
                    child: Text(
                      l10n.signin,
                      style: GoogleFonts.tajawal(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
  }

  Widget _inputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.tajawal(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
