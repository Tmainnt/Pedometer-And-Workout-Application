import 'package:flutter/material.dart';

class AuthSwitchLink extends StatelessWidget {
  final String text;
  final String linkText;
  final VoidCallback onTap;

  const AuthSwitchLink({
    super.key,
    required this.text,
    required this.linkText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(text),
        InkWell(
          onTap: onTap,
          child: Text(
            " $linkText",
            style: const TextStyle(
              color: Colors.orange,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}