import 'package:flutter/material.dart';
import 'package:shams_mobile_app/app/main_screen.dart';
import 'package:shams_mobile_app/services/local_storage_service.dart';
import 'package:shams_mobile_app/views/auth/welcome.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // 💡 التعديل الجذري: استخدام FutureBuilder بدلاً من StreamBuilder
    return FutureBuilder<bool>(
      // نطلب من حارس الذاكرة أن يخبرنا: هل المستخدم مسجل دخوله؟
      future: LocalStorageService.isLoggedIn(),
      builder: (context, snapshot) {
        // 1. حالة الانتظار (أثناء قراءة الذاكرة التي تأخذ أجزاء من الثانية)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Colors.white,
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. النتيجة: جلب القيمة (إذا لم تكن موجودة، نعتبرها false)
        final bool isLoggedIn = snapshot.data ?? false;

        // 3. اتخاذ القرار (التوجيه)
        if (isLoggedIn) {
          return const MainScreen(); // المستخدم موجود في الذاكرة -> الرئيسية
        }

        return const WelcomeScreen(); // المستخدم غير موجود -> شاشة الترحيب
      },
    );
  }
}
