import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pedometer_application/screen/community/community_page.dart';
import 'package:pedometer_application/screen/community/notification_page.dart';
import 'package:pedometer_application/screen/community/profile_page.dart';
import 'package:pedometer_application/screen/history_page.dart';
import 'package:pedometer_application/screen/home_page.dart';
import 'package:pedometer_application/widget/navbar/buttom_navbar.dart';
import 'package:pedometer_application/screen/workout/workout_page.dart';
import 'package:pedometer_application/widget/navbar/pedometer_app_bar.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;
  bool _isRunning = false;

  final String uid = FirebaseAuth.instance.currentUser!.uid;

  late final List<Widget> _pages = [
    HomePage(
      onRunningStateChanged: (isRunning) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _isRunning != isRunning) {
            setState(() {
              _isRunning = isRunning;
            });
          }
        });
      },
    ),
    const HistoryPage(),
    const WorkoutPage(),
    const CommunityPage(),
    const NotificationPage(),
    ProfilePage(UID: uid, currentUserRole: "user"),
  ];

  @override
  Widget build(BuildContext context) {
    bool shouldHideAppBar = _selectedIndex == 0 && _isRunning;

    return Scaffold(
      appBar: shouldHideAppBar ? null : PedometerAppBar(),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
      ),
    );
  }
}
