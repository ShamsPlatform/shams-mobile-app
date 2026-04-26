//تصميم الزر الممتلئ الاصفر الخاص بتسجيل الدخول وانشاء حساب وتابعة
import 'package:flutter/material.dart';
import 'package:shams_mobile_app/utils/constants.dart';

class CustomSolidButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  const CustomSolidButton({super.key,required this.title,required this.onPressed});
  
  @override
  Widget build(BuildContext context) {
    
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: ShamsColors.solarYellow,
        foregroundColor: ShamsColors.bgWhite,
      ),
      child: Text(title),
    );
  }
}