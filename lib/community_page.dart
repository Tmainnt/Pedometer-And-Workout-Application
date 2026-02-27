import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pedometer_application/new_post.dart';
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
    return Scaffold(
      appBar: PedometerAppBar(),
      body: StreamBuilder<DocumentSnapshot>(
        stream: firestoreService.getUserData(),
        builder: (context, snapshot) {
          final checkSnapshot = firestoreService.checkHasData(snapshot);
          if (checkSnapshot != true) {
            return checkSnapshot;
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;

          return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: firestoreService.getPostData(),
            builder: (context, postSnapshot) {
              final checkPostSnapshot = firestoreService.checkHasData(
                postSnapshot,
              );
              if (checkPostSnapshot != true) {
                return checkPostSnapshot;
              }

              // userPost จะเป็น List ที่ด้านในเป็น Object Class Post
              final userPost = postSnapshot.data!.docs
                  .map((doc) => Post.fromFirestore(doc))
                  .toList();

              return ListView.builder(
                itemCount: userPost.length + 1,
                itemBuilder: (context, index) {
                  // ตัวแรกคือ newPost
                  if (index == 0) {
                    return Column(
                      children: [
                        newPost(context, userData),
                        const SizedBox(height: 10),
                      ],
                    );
                  }

                  final post = userPost[index - 1];
                  if (post.content.isNotEmpty || post.imageUrl.isNotEmpty) {
                    return Column(
                      children: [
                        CreatePosts(userPost: post),
                        const SizedBox(height: 10),
                      ],
                    );
                  }

                  return const SizedBox();
                },
              );
            },
          );
        },
      ),
    );
  }

  // Widget สำหรับให้ผู้ใช้กดแล้วไปยังหน้าสร้างโพสต์ใหม่

  Widget newPost(BuildContext context, var userData) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewPost(userData: userData)),
        );
      }, // เดี๋ยวทำ Navigator ไปยังหน้าสร้างโพสต์ใหม่
      child: Container(
        decoration: BoxDecoration(
          color: newPostBoxColor,
          boxShadow: [
            BoxShadow(color: widgetColors.boxShadowColor(), blurRadius: 5),
          ],
        ),
        child: ListTile(
          title: Row(
            children: [
              if (userData['user_photoUrl'].isNotEmpty)
                CircleAvatar(
                  backgroundImage: NetworkImage(userData['user_photoUrl']),
                ),
              if (userData['user_photoUrl'].isEmpty)
                CircleAvatar(
                  backgroundImage: AssetImage('assets/default_profile.png'),
                ),
              SizedBox(width: 15),
              Text('เพิ่มโพสต์'),
            ],
          ),
          trailing: IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewPost(userData: userData),
                ),
              );
            },
            icon: Icon(
              Icons.add_circle_outline,
              color: WidgetColors().iconColorMoreDark(),
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}
