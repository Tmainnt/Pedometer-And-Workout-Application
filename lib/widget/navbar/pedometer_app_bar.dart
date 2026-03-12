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
          isDetailPage ? Icons.arrow_back_ios_new : Icons.menu,
          color: Colors.white,
          size: 40,
        ),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: const TextStyle(
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
      actions: isDetailPage
          ? null
          : [
              // 🟢 เปลี่ยนจาก IconButton ธรรมดา เป็น PopupMenuButton
              Padding(
                padding: const EdgeInsets.only(right: 15),
                child: PopupMenuButton<String>(
                  // ทำให้ Dropdown เด้งลงมาใต้แถบ AppBar พอดี
                  offset: const Offset(0, 50),
                  // ปรับขอบ Dropdown ให้โค้งมนดูทันสมัย
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  // เมื่อกดเลือกเมนู
                  onSelected: (value) async {
                    if (value == 'logout') {
                      await FirebaseAuth.instance.signOut();
                    }
                  },
                  // รูป Profile ที่โชว์บน AppBar
                  child: const Icon(
                    Icons.account_circle,
                    color: Colors.white,
                    size: 40,
                  ),
                  // รายการเมนูใน Dropdown
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: Colors.redAccent),
                          SizedBox(width: 10),
                          Text(
                            'ออกจากระบบ',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
      centerTitle: true,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}