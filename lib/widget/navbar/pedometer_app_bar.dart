import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PedometerAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String subtitle;
  final bool isDetailPage;

  const PedometerAppBar({
    super.key,
    required this.title,
    this.subtitle = '',
    this.isDetailPage = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 124, 139, 253),
              Color.fromARGB(255, 123, 75, 253),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
        ),
      ),

      leading: IconButton(
        onPressed: () {
          if (isDetailPage) {
            Navigator.pop(context);
          }
        },
        icon: Icon(
          isDetailPage ? Icons.arrow_back_ios_new : Icons.menu, color: Colors.white, size: 40),
      ),

      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),

          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.orangeAccent,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),

      actions: isDetailPage ? null :[
        IconButton(
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
          },
          icon: const Icon(Icons.logout, color: Colors.white, size: 20),
        ),
        const Padding(
          padding: EdgeInsets.only(right: 15),
          child: Icon(Icons.account_circle, color: Colors.white, size: 40),
        ),
      ],
      centerTitle: true,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
