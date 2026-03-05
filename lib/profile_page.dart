import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pedometer_application/theme/font_color.dart';
import 'package:pedometer_application/theme/widget_colors.dart';
import 'package:pedometer_application/services/firestore_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, required this.UID});
  final String UID;

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final WidgetColors widgetColors = WidgetColors();
  final FontColor fontColor = FontColor();
  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firestoreService.getUserDataByUID(widget.UID),
      builder: (context, snapshot) {
        final check = firestoreService.checkHasData(snapshot);
        if (check != true) return check;

        final userData = snapshot.data!.data as Map<String, dynamic>;

        return Scaffold(
          appBar: AppBar(
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
            centerTitle: true,
            flexibleSpace: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: WidgetColors().applicationMainTheme(),
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            leading: IconButton(
              onPressed: () {
                Navigator.pop(context);
              },
              icon: Icon(
                Icons.cancel,
                color: Colors.white,
                size: 40,
                shadows: [
                  Shadow(
                    color: WidgetColors().boxShadowColor(),
                    blurRadius: 3,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
          body: Column(
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: widgetColors.lightTheme(),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: Stack(
                  children: [
                    Column(children: [SizedBox(height: 70)]),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
