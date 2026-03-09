import 'package:flutter/material.dart';

class AuthHeader extends StatelessWidget{
  final String title;
  final String highlightTitle;
  final String subtitle;

  const AuthHeader({
    super.key,
    required this.title,
    required this.highlightTitle,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              highlightTitle,
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}