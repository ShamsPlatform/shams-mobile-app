import 'package:flutter/material.dart';
import 'package:shams_mobile_app/widgets/custom_solid_button.dart'; // استدعاء الزر المخصص

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0), // مسافة فارغة حول الزر
          child: CustomSolidButton(
            title: 'تسجيل الدخول', // النص الذي سنختبره
            onPressed: () {
              print('تم الضغط على الزر بنجاح!');
            },
          ),
        ),
      ),
    );
  }
}