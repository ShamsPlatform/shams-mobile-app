import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
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

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passController.text.trim();

    setState(() {
      _emailError = email.isEmpty ? 'يرجى التحقق من البريد الإلكتروني' : null;
      _passError = password.isEmpty ? 'كلمة المرور غير صحيحة' : null;
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
                authProvider.errorMessage ?? 'حدث خطأ أثناء تسجيل الدخول',
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
    setState(() => _isLoading = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final ok = await authProvider.signInWithGoogle();
      if (!ok && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              authProvider.errorMessage ?? 'فشل تسجيل الدخول عبر جوجل',
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
              Text('مرحباً بعودتك!', style: GoogleFonts.tajawal(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onSurface)),
              const SizedBox(height: 8),
              Text('سجل الدخول للمتابعة في رحلتك مع شمس', style: GoogleFonts.tajawal(fontSize: 14, color: Theme.of(context).extension<ShamsExtendedColors>()!.textHint)),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 20)],
              ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _inputLabel('البريد الإلكتروني أو الهاتف'),
                    CustomTextField(hintText: 'example@mail.com', prefixIcon: Icons.email_outlined, controller: _emailController, errorText: _emailError),
                    const SizedBox(height: 20),
                    _inputLabel('كلمة المرور'),
                    CustomTextField(hintText: '••••••••', prefixIcon: Icons.lock_outline, isPassword: true, controller: _passController, errorText: _passError),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          'نسيت كلمة المرور؟',
                          style: GoogleFonts.tajawal(
                            color: Theme.of(context).colorScheme.primary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: _isLoading
                          ? Center(
                              child: CircularProgressIndicator(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            )
                          : CustomSolidButton(title: 'تسجيل الدخول', onPressed: _handleLogin),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              CustomOutlinedButton(title: 'Google تسجيل الدخول بواسطة', icon: const Icon(Icons.g_mobiledata, size: 30), onPressed: _handleGoogleLogin),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ليس لديك حساب؟',
                    style: GoogleFonts.tajawal(
                      color: Theme.of(context).extension<ShamsExtendedColors>()!.textHint,
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SignUpScreen()),
                    ),
                    child: Text(
                      'انضم إلينا الآن',
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