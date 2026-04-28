// الزر الابيض مع الحدود الصفراء
import 'package:flutter/material.dart';
import 'package:shams_mobile_app/utils/constants.dart';

class CustomOutlinedButton extends StatelessWidget {
  final String title;
  final VoidCallback onPressed;
  final Widget? icon;

  const CustomOutlinedButton({
    super.key,
    required this.title,
    required this.onPressed,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final buttonStyle = OutlinedButton.styleFrom(
      foregroundColor: ShamsColors.solarYellow,
      side: const BorderSide(color: ShamsColors.solarYellow, width: 1.5),
    );
    if (icon != null) {
      return OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon!,
        label: Text(title),
        style: buttonStyle,
      );
    }
    return OutlinedButton(
      onPressed: onPressed,
      child: Text(title),
    );
  }
}