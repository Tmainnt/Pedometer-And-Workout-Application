import 'package:pedometer_application/widget/community/new_post.dart';
import 'package:pedometer_application/models/user.dart';
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

  late Future<UserModel> _userDataFuture;
  final ScrollController _scrollController = ScrollController();

  int _limit = 5;

  bool _isRequesting = false;
  List<Post> _cachedPosts = [];

  @override
  void initState() {
    super.initState();
    _userDataFuture = firestoreService.getUserData();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        if (!_isRequesting) {
          setState(() {
            _isRequesting = true;
            _limit += 5;
          });

          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) {
              setState(() {
                _isRequesting = false;
              });
            }
          });
        }
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PedometerAppBar(),
      body: FutureBuilder<UserModel>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          final checkSnapshot = firestoreService.checkHasData(snapshot);
          if (checkSnapshot != true) return checkSnapshot;

          final userData = snapshot.data!;

          return StreamBuilder<List<Post>>(
            stream: firestoreService.getPostStream(_limit),
            builder: (context, postSnapshot) {
              if (postSnapshot.hasData) {
                _cachedPosts = postSnapshot.data!;
              }

              if (_cachedPosts.isEmpty &&
                  postSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              return ListView.builder(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                itemCount: _cachedPosts.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Column(
                      children: [
                        newPost(context, userData),
                        const SizedBox(height: 10),
                      ],
                    );
                  }

                  final post = _cachedPosts[index - 1];

                  if (post.content.isNotEmpty || post.imageUrl!.isNotEmpty) {
                    return Column(
                      key: ValueKey(post.postID),
                      children: [
                        CreatePosts(
                          userPost: post,
                          currentUserRole: userData.role,
                        ),
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

  Widget newPost(BuildContext context, UserModel userData) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => NewPost(userData: userData)),
        );
      },
      child: Container(
        padding: EdgeInsets.fromLTRB(15, 0, 14, 0),
        decoration: BoxDecoration(
          color: newPostBoxColor,
          boxShadow: [
            BoxShadow(color: widgetColors.boxShadowColor(), blurRadius: 5),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                if (userData.phoUrl.isNotEmpty && userData.phoUrl != '')
                  CircleAvatar(backgroundImage: NetworkImage(userData.phoUrl)),

                if (userData.phoUrl.isEmpty && userData.phoUrl == '')
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/default_profile.png'),
                  ),

                SizedBox(width: 15),
                Text('เพิ่มโพสต์'),
              ],
            ),
            IconButton(
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
          ],
        ),
      ),
    );
  }
}
