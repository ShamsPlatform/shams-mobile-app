//الترويسة العلوية مع الشعار
import 'package:flutter/material.dart';
import 'package:shams_mobile_app/utils/constants.dart';


class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 20.0, right: 20.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset('assets/images/logo/shams logo.png', height: 40,
            fit: BoxFit.contain,)
          ],
        ),
 
      ),
    );
  }
}