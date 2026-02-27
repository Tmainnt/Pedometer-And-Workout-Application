import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PedometerAppBar extends StatelessWidget implements PreferredSizeWidget {
  const PedometerAppBar({super.key});

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
        onPressed: () {},
        icon: const Icon(Icons.menu, color: Colors.white, size: 40),
      ),

      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Pedometer',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),

          Text(
            '& Workout',
            style: const TextStyle(
              color: Colors.orangeAccent,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),

      actions: [
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
