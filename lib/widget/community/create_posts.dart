import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pedometer_application/models/post.dart';
import 'package:pedometer_application/services/firestore_service.dart';
import 'package:pedometer_application/theme/font_color.dart';
import 'package:pedometer_application/theme/widget_colors.dart';
import 'package:pedometer_application/services/post_page_service.dart';
import 'package:pedometer_application/extension/number_format.dart';

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
    return StreamBuilder(
      stream: firestoreService.getUserDataByUID(widget.userPost.UID),
      builder: (context, snapshot) {
        final check = firestoreService.checkHasData(snapshot);
        if (check != true) return check;

        final userData = snapshot.data!.data() as Map<String, dynamic>;
        final postPageService = PostPageService(postData: widget.userPost);

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(color: widgetColors.boxShadowColor(), blurRadius: 10),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap:
                        () {}, // เดี๋ยวเพิ่ม Navigator ไปที่หน้า Profile ของคนโพสต์
                    child: CircleAvatar(
                      backgroundImage:
                          userData['user_photoUrl'] != null &&
                              userData['user_photoUrl'].isNotEmpty
                          ? NetworkImage(userData['user_photoUrl'])
                          : AssetImage('assets/default_profile.png')
                                as ImageProvider,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: GestureDetector(
                        onTap:
                            () {}, // เดี๋ยวเพิ่ม Navigator ไปที่หน้า Profile ของคนโพสต์
                        child: Text(userData['user_name']),
                      ),
                      subtitle: Text(postPageService.checkTimestamp()),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 60,
                            child:
                                widget.userPost.UID ==
                                    FirebaseAuth.instance.currentUser!.uid
                                ? GestureDetector(
                                    onTap:
                                        () {}, // เดี๋ยวเพิ่มการเปลี่ยนแปลงหลังกด แล้วอัปเดตรายชื่อลง database ด้วย
                                    child: Text(
                                      'ติดตาม',
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 46, 77, 252),
                                        fontSize: 15,
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                          ),
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (_) => AlertDialog(
                                  content: Row(
                                    children: [
                                      const SizedBox(
                                        width: 23,
                                        height: 23,
                                        child: Icon(
                                          Icons.error_outline,
                                          color: Color.fromARGB(
                                            255,
                                            255,
                                            22,
                                            22,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'รายงาน',
                                        style: TextStyle(
                                          color: FontColor().errorColor(),
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                            icon: Icon(
                              Icons.more_horiz,
                              size: 32,
                              color: widgetColors.iconColorMoreDark(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (widget.userPost.content.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(widget.userPost.content),
                ),
              if (widget.userPost.imageUrl.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Image.network(widget.userPost.imageUrl),
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
                                Icons.favorite,
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
                  Expanded(
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
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
