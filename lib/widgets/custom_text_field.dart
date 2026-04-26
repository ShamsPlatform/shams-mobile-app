//حقل الادخال
import 'package:flutter/material.dart';
import 'package:shams_mobile_app/utils/constants.dart';

class CustomTextField extends StatelessWidget {
  final String hintText;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: prefixIcon != null 
            ? Icon(prefixIcon, color: ShamsColors.textGray) 
            : null,
        suffixIcon: suffixIcon != null 
            ? Icon(suffixIcon, color: ShamsColors.textGray) 
            : null,
      ),
    );
  }
}