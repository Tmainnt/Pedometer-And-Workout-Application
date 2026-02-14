import 'package:flutter/material.dart';
import 'package:pedometer_application/home_page.dart';
import 'package:pedometer_application/widget/navbar/buttom_navbar.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({super.key});

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const Center(child: Text("หน้า รายงาน")),
    const Center(child: Text("หน้า ท่าฝึก")),
    const Center(child: Text("หน้า ชุมชน")),
    const Center(child: Text("หน้า ห้องสนทนา")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavbar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
       ),
    );
  }
}
