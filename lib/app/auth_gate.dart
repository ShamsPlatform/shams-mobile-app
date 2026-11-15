import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shams_mobile_app/app/main_screen.dart';
import 'package:shams_mobile_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:shams_mobile_app/views/auth/welcome.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final status = context.select<AuthProvider, AuthStatus>((p) => p.status);

    return switch (status) {
      AuthStatus.unknown => const Scaffold(
          backgroundColor: Colors.white,
          body: Center(child: CircularProgressIndicator()),
        ),
      AuthStatus.authenticated => const MainScreen(),
      AuthStatus.unauthenticated => const WelcomeScreen(),
    };
  }
}
