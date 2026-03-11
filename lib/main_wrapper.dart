import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pedometer_application/screen/community/community_page.dart';
import 'package:pedometer_application/screen/community/notification_page.dart';
import 'package:pedometer_application/screen/community/profile_page.dart';
import 'package:pedometer_application/screen/history_page.dart';
import 'package:pedometer_application/screen/home_page.dart';
import 'package:pedometer_application/widget/navbar/buttom_navbar.dart';
import 'package:pedometer_application/screen/workout/workout_page.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  final String uid = FirebaseAuth.instance.currentUser!.uid;

  late final List<Widget> _pages = [
    const HomePage(),
    const HistoryPage(),
    const WorkoutPage(),
    const CommunityPage(),
    const NotificationPage(),
    ProfilePage(UID: uid, currentUserRole: "user"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
