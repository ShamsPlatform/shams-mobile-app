import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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
    final email = _emailController.text.trim();
    final password = _passController.text.trim();
    final confirmPassword = _confirmPassController.text.trim();

    setState(() {
      _emailError = !email.contains('@') ? 'البريد الإلكتروني غير صالح' : null;
      _passError =
          password.length < 6 ? 'كلمة المرور قصيرة جداً (6 أحرف على الأقل)' : null;
      _confirmPassError =
          password != confirmPassword ? 'كلمتا المرور غير متطابقتين' : null;
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
    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final ok = await authProvider.signInWithGoogle();
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ?? 'حدث خطأ أثناء التسجيل',
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
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
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
              Text('انضم إلى مجتمع شمس', style: GoogleFonts.tajawal(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 8),
              Text('خطوتك الأولى لتجربة فريدة ومتميزة معنا', style: GoogleFonts.tajawal(fontSize: 14, color: Theme.of(context).extension<ShamsExtendedColors>()!.textHint)),
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
                    _inputLabel('البريد الإلكتروني'),
                    CustomTextField(hintText: 'example@mail.com', prefixIcon: Icons.email_outlined, controller: _emailController, errorText: _emailError),
                    const SizedBox(height: 16),
                    _inputLabel('كلمة المرور'),
                    CustomTextField(hintText: '••••••••', prefixIcon: Icons.lock_outline, isPassword: true, controller: _passController, errorText: _passError),
                    const SizedBox(height: 16),
                    _inputLabel('تأكيد كلمة المرور'),
                    CustomTextField(hintText: '••••••••', prefixIcon: Icons.lock_outline, isPassword: true, controller: _confirmPassController, errorText: _confirmPassError),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: CustomSolidButton(title: 'التالي', onPressed: _handleNext),
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
                            'أو إنشاء حساب عبر',
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
                    'لديك حساب بالفعل؟',
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
                      'تسجيل الدخول',
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