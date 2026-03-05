import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pedometer_application/models/post.dart';
import 'package:pedometer_application/profile_page.dart';
import 'package:pedometer_application/services/firestore_service.dart';
import 'package:pedometer_application/theme/font_color.dart';
import 'package:pedometer_application/theme/widget_colors.dart';
import 'package:pedometer_application/services/post_page_service.dart';
import 'package:pedometer_application/extension/number_format.dart';
import 'package:pedometer_application/widget/community/new_post.dart';

class CreatePosts extends StatefulWidget {
  final Post userPost;

  const CreatePosts({super.key, required this.userPost});

  @override
  State<CreatePosts> createState() => _CreatePostsState();
}

class _CreatePostsState extends State<CreatePosts> {
  final FirestoreService firestoreService = FirestoreService();
  final WidgetColors widgetColors = WidgetColors();

  bool isFavorite = false;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firestoreService.getUserDataByUID(widget.userPost.UID),
      builder: (context, snapshot) {
        final check = firestoreService.checkHasData(snapshot);
        if (check != true) return check;

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final postPageService = PostPageService(postData: widget.userPost);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(15, 15, 15, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: widgetColors.boxShadowColor(), blurRadius: 10),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ProfilePage(UID: widget.userPost.UID),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      backgroundImage:
                          userData['user_photoUrl'] != null &&
                              userData['user_photoUrl'].isNotEmpty
                          ? NetworkImage(userData['user_photoUrl'])
                          : const AssetImage('assets/default_profile.png')
                                as ImageProvider,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ProfilePage(UID: widget.userPost.UID),
                                    ),
                                  );
                                },
                                child: Text(
                                  userData['user_name'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),

                            if (widget.userPost.feeling != '') ...[
                              const SizedBox(width: 6),
                              Text(
                                '- ${widget.userPost.feeling}',
                                style: const TextStyle(fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(width: 4),
                              Image.asset(
                                widget.userPost.emotionUrl!,
                                width: 14,
                                height: 14,
                              ),
                            ],
                          ],
                        ),

                        const SizedBox(height: 2),

                        Text(
                          postPageService.checkTimestamp(),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: () {
                      final currentUID = FirebaseAuth.instance.currentUser!.uid;

                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          if (widget.userPost.UID == currentUID) {
                            return SafeArea(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ListTile(
                                    leading: const Icon(Icons.edit),
                                    title: const Text('แก้ไขโพสต์'),
                                    onTap: () {
                                      Navigator.pop(context);

                                      final currentUID = FirebaseAuth
                                          .instance
                                          .currentUser!
                                          .uid;

                                      if (widget.userPost.UID == currentUID) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => NewPost(
                                              userData: userData,
                                              post: widget
                                                  .userPost, // ส่ง post ไป
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                  ListTile(
                                    leading: Icon(
                                      Icons.delete,
                                      color: FontColor().errorColor(),
                                    ),
                                    title: Text(
                                      'ลบโพสต์',
                                      style: TextStyle(
                                        color: FontColor().errorColor(),
                                      ),
                                    ),
                                    onTap: () {
                                      firestoreService.deletePost(
                                        widget.userPost,
                                      );
                                      Navigator.pop(context);
                                    },
                                  ),
                                ],
                              ),
                            );
                          } else {
                            return SafeArea(
                              child: ListTile(
                                leading: Icon(
                                  Icons.error_outline,
                                  color: FontColor().errorColor(),
                                ),
                                title: Text(
                                  'รายงาน',
                                  style: TextStyle(
                                    color: FontColor().errorColor(),
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                },
                              ),
                            );
                          }
                        },
                      );
                    },
                    icon: Icon(
                      Icons.more_horiz,
                      size: 28,
                      color: widgetColors.iconColorMoreDark(),
                    ),
                  ),
                ],
              ),
              if (widget.userPost.content.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(widget.userPost.content),
                ),
              if (widget.userPost.imageUrl!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Image.network(
                    widget.userPost.imageUrl!,
                  ), // ดึงรูปจาก firebase storage มาแสดง
                ),
              Row(
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        StreamBuilder<bool>(
                          stream: firestoreService.hasUserLikedPost(
                            widget.userPost.postID ?? '',
                            FirebaseAuth.instance.currentUser!.uid,
                          ),
                          builder: (context, snapshot) {
                            final liked = snapshot.data ?? false;

                            return IconButton(
                              onPressed: () async {
                                if (liked) {
                                  await firestoreService.unlikePost(
                                    widget.userPost.postID ?? '',
                                  );
                                } else {
                                  await firestoreService.likePost(
                                    widget.userPost.postID ?? '',
                                  );
                                }
                              },
                              icon: Icon(
                                Icons.favorite_outline,
                                color: liked
                                    ? widgetColors.favoriteIcon()
                                    : widgetColors.iconColorMoreDark(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(width: 6),
                        Text(widget.userPost.totalLike.formatCount),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          onPressed:
                              () {}, // ไปยัง Page ที่แสดง comment ใน Post นั้น
                          icon: Icon(
                            CupertinoIcons.conversation_bubble,
                            size: 25,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(widget.userPost.totalComment.formatCount),
                      ],
                    ),
                  ),
                  /*Expanded(
                    child: Center(
                      child: IconButton(
                        onPressed: () {}, // เดี๋ยวมาเพิ่มการแชร์
                        icon: Icon(
                          Icons.share,
                          size: 25,
                          color: widgetColors.iconColorMoreDark(),
                        ),
                      ),
                    ),
                  ),*/
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
