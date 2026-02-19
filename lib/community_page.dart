import 'package:cloud_firestore/cloud_firestore.dart';
import 'services/firestore_service.dart';
import 'package:flutter/material.dart';
import 'widget/home/pedometer_app_bar.dart';
import 'theme/widget_colors.dart';
import 'widget/community/create_posts.dart';
import 'models/post.dart';

class CommunityPage extends StatefulWidget {
  const CommunityPage({super.key});

  @override
  State<CommunityPage> createState() => CommunityPageState();
}

class CommunityPageState extends State<CommunityPage> {
  bool isPressed = false;
  Color newPostBoxColor = Colors.white;
  final FirestoreService firestoreService = FirestoreService();
  final WidgetColors widgetColors = WidgetColors();

  @override
  Widget build(BuildContext context) {
    bool hasData = false;
    return Scaffold(
      appBar: PedometerAppBar(),
      body: StreamBuilder<DocumentSnapshot>(
        stream: firestoreService.getUserData(),
        builder: (context, snapshot) {
          dynamic checkSnapshot = firestoreService.checkHasData(snapshot);
          if (checkSnapshot != true) {
            return checkSnapshot;
          } else {
            hasData = true;
          }

          if (hasData) {
            var userData = snapshot.data!.data() as Map<String, dynamic>;
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                children: [
                  newPost(context, userData),
                  StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                    stream: firestoreService.getPostData(),
                    builder: (context, userPostSnapshot) {
                      dynamic checkPostSnapshot = firestoreService.checkHasData(
                        userPostSnapshot,
                      );
                      if (checkPostSnapshot != true) {
                        return checkPostSnapshot;
                      } else {
                        hasData = true;
                      }

                      if (hasData) {
                        final List userPost = userPostSnapshot.data!.docs.map((
                          doc,
                        ) {
                          doc.data();
                        }).toList();
                        return ListView.builder(
                          itemBuilder: (context, index) {
                            return Container(
                              height: 354,
                              decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: widgetColors.boxShadowColor(),
                                  ),
                                ],
                              ),
                              child: CreatePosts(
                                userPost: Post(userPost[index]),
                              ),
                            );
                          },
                          itemCount: checkSnapshot.length,
                        );
                      } else {
                        return Center(child: Text("ไม่พบข้อมูล"));
                      }
                    },
                  ),
                ],
              ),
            );
          } else {
            return Center(child: Text("ไม่พบข้อมูล"));
          }
        },
      ),
    );
  }

  // Widget สำหรับให้ผู้ใช้กดแล้วไปยังหน้าสร้างโพสต์ใหม่

  Widget newPost(BuildContext context, var userData) {
    return GestureDetector(
      child: Container(
        height: 35,
        padding: EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: newPostBoxColor,
          boxShadow: [
            BoxShadow(
              color: widgetColors.boxShadowColor(),
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: ListTile(
          title: Row(
            children: [
              CircleAvatar(backgroundImage: userData['imageUrl']),
              Text('เพิ่มโพสต์'),
            ],
          ),
          trailing: IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.add_circle_outline,
              color: Color.fromARGB(0, 158, 158, 158),
            ),
          ),
        ),
      ),
    );
  }
}
