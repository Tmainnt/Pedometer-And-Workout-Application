import 'package:flutter/material.dart';

class BottomNavbar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavbar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF7E8CFD),
      unselectedItemColor: Colors.black87,
      unselectedFontSize: 12,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled),
          label: 'หน้าหลัก',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'รายงาน'),
        BottomNavigationBarItem(
          icon: Icon(Icons.fitness_center),
          label: 'ท่าฝึก',
        ),
        BottomNavigationBarItem(icon: Icon(Icons.group), label: 'ชุมชน'),
      ],
    );
  }
}
