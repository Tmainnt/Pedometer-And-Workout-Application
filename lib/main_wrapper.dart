import 'package:flutter/material.dart';
import 'package:pedometer_application/home_page.dart';
import 'package:pedometer_application/sceen/community/notification_page.dart';
import 'package:pedometer_application/sceen/workout/workout_page.dart';
import 'package:pedometer_application/widget/home/pedometer_app_bar.dart';
import 'package:pedometer_application/widget/navbar/buttom_navbar.dart';
import 'package:pedometer_application/sceen/community/community_page.dart';
import 'package:pedometer_application/sceen/community/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
    const Center(child: Text("หน้า รายงาน")),
    const WorkoutPage(),
    const CommunityPage(),
    const NotificationPage(),
    ProfilePage(UID: uid, currentUserRole: "user"),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PedometerAppBar(),
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomNavbar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
