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
import 'package:shams_mobile_app/features/auth/presentation/screens/signup.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  String? _emailError, _passError;
  bool _isLoading = false;
  bool _isGoogleLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final l10n = AppLocalizations.of(context)!;
    final email = _emailController.text.trim();
    final password = _passController.text.trim();

    setState(() {
      _emailError = email.isEmpty ? l10n.pleaseVerifyEmail : null;
      _passError = password.isEmpty ? l10n.incorrectPassword : null;
    });

    if (_emailError == null && _passError == null) {
      setState(() => _isLoading = true);
      try {
        final authProvider = context.read<AuthProvider>();
        final ok = await authProvider.signInWithEmail(
          email: email,
          password: password,
        );
        if (!ok && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                l10n.localizeErrorMessage(
                  authProvider.errorMessage,
                  fallback: l10n.signInError,
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
  }

  Future<void> _handleGoogleLogin() async {
    final l10n = AppLocalizations.of(context)!;
    setState(() => _isGoogleLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final ok = await authProvider.signInWithGoogle();
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              l10n.localizeErrorMessage(
                authProvider.errorMessage,
                fallback: l10n.googleSignInFailed,
              ),
              style: GoogleFonts.tajawal(),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGoogleLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final ext = theme.extension<ShamsExtendedColors>()!;

    return Scaffold(
        backgroundColor: ext.backgroundLight,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(
            color: colorScheme.onSurface,
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Text(
                l10n.welcomeBackExclaim,
                textAlign: TextAlign.center,
                style: GoogleFonts.tajawal(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.signInSubtitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  color: ext.textHint,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: colorScheme.surface,
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
                    _inputLabel(l10n.emailOrPhone),
                    CustomTextField(
                      hintText: 'example@mail.com',
                      prefixIcon: Icons.email_outlined,
                      controller: _emailController,
                      errorText: _emailError,
                    ),
                    const SizedBox(height: 20),
                    _inputLabel(l10n.password),
                    CustomTextField(
                      hintText: '••••••••',
                      prefixIcon: Icons.lock_outline,
                      isPassword: true,
                      controller: _passController,
                      errorText: _passError,
                    ),
                    Align(
                      alignment: AlignmentDirectional.centerEnd,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          l10n.forgotPassword,
                          style: GoogleFonts.tajawal(
                            color: colorScheme.primary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 50),
                      child: SizedBox(
                        width: double.infinity,
                        child: _isLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: colorScheme.primary,
                                ),
                              )
                            : CustomSolidButton(
                                title: l10n.signin,
                                onPressed: (_isLoading || _isGoogleLoading) ? null : _handleLogin,
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        return Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: ext.borderLight,
                              ),
                            ),
                            ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: constraints.maxWidth * 0.72,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  l10n.orSignUpWith,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: GoogleFonts.tajawal(
                                    color: ext.textHint,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: ext.borderLight,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                    ConstrainedBox(
                      constraints: const BoxConstraints(minHeight: 50),
                      child: SizedBox(
                        width: double.infinity,
                        child: _isGoogleLoading
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: colorScheme.primary,
                                ),
                              )
                            : CustomOutlinedButton(
                                title: l10n.signInWithGoogle,
                                icon: const Icon(Icons.g_mobiledata_rounded, size: 28),
                                foregroundColor: colorScheme.onSurface,
                                borderColor: ext.borderLight,
                                onPressed: (_isLoading || _isGoogleLoading) ? null : _handleGoogleLogin,
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    l10n.dontHaveAccount,
                    style: GoogleFonts.tajawal(
                      color: ext.textHint,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpScreen()),
                    ),
                    child: Text(
                      l10n.joinUsNow,
                      style: GoogleFonts.tajawal(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w700,
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

