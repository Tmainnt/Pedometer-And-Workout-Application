import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:pedometer_application/screen/community/admin/admin_delete_page.dart';
import 'package:pedometer_application/models/community/post.dart';
import 'package:pedometer_application/models/user.dart';
import 'package:pedometer_application/screen/community/comment_page.dart';
import 'package:pedometer_application/screen/community/profile_page.dart';
import 'package:pedometer_application/services/firestore_service.dart';
import 'package:pedometer_application/theme/font_color.dart';
import 'package:pedometer_application/theme/widget_colors.dart';
import 'package:pedometer_application/services/post_page_service.dart';
import 'package:pedometer_application/extension/number_format.dart';
import 'package:pedometer_application/widget/community/new_post.dart';
import 'package:pedometer_application/widget/community/report_dialog.dart';

class CreatePosts extends StatefulWidget {
  final Post userPost;
  final String currentUserRole;

  const CreatePosts({
    super.key,
    required this.userPost,
    required this.currentUserRole,
  });

  @override
  State<CreatePosts> createState() => _CreatePostsState();
}

class _CreatePostsState extends State<CreatePosts> {
  final FirestoreService firestoreService = FirestoreService();
  final WidgetColors widgetColors = WidgetColors();

  UserModel? postOwnerData;
  bool isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final cachedUser = firestoreService.getCachedUser(widget.userPost.UID);

      if (cachedUser != null) {
        postOwnerData = cachedUser;
      } else {
        final data = await firestoreService.getUserDataByUID(
          widget.userPost.UID,
        );
        if (mounted) {
          setState(() {
            postOwnerData = data;
          });
        }
      }
    } catch (e, stackTrace) {
      print("ข้อความ Error: $e");
      print("รายละเอียดบรรทัดที่พัง: $stackTrace");
    }
  }

  @override
  Widget build(BuildContext context) {
    if (postOwnerData == null) {
      return Container(
        height: 120,
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: widgetColors.boxShadowColor(), blurRadius: 10),
          ],
        ),
        child: const Center(child: Text('ไม่สามารถโหลดข้อมูลได้')),
      );
    }

    final userData = postOwnerData!;
    final postPageService = PostPageService(postData: widget.userPost);
    final currentUID = FirebaseAuth.instance.currentUser!.uid;

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
                    MaterialPageRoute(builder: (context) => goToProfilePage()),
                  );
                },
                child: CircleAvatar(
                  backgroundImage:
                      userData.phoUrl != '' && userData.phoUrl.isNotEmpty
                      ? NetworkImage(userData.phoUrl)
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
                                  builder: (context) => goToProfilePage(),
                                ),
                              );
                            },
                            child: Text(
                              userData.name,
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
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              if (currentUID != widget.userPost.UID)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0, top: 4.0),
                  child: StreamBuilder<bool>(
                    stream: firestoreService.hasUserFollowed(
                      widget.userPost.UID,
                      currentUID,
                    ),
                    builder: (context, snapshot) {
                      final isFollowing = snapshot.data ?? false;
                      return SizedBox(
                        height: 30,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isFollowing
                                ? Colors.grey[200]
                                : widgetColors.followButton(),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () async {
                            if (isFollowing) {
                              await firestoreService.unfollowUser(
                                widget.userPost.UID,
                                currentUID,
                              );
                            } else {
                              await firestoreService.followUser(
                                widget.userPost.UID,
                                currentUID,
                              );
                            }
                          },
                          child: Text(
                            isFollowing ? 'กำลังติดตาม' : 'ติดตาม',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: isFollowing
                                  ? Colors.black87
                                  : Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              IconButton(
                onPressed: () {
                  final currentUID = FirebaseAuth.instance.currentUser!.uid;

                  showModalBottomSheet(
                    context: context,
                    builder: (context) {
                      final isOwner = widget.userPost.UID == currentUID;
                      final isAdmin = widget.currentUserRole == 'admin';

                      if (isOwner) {
                        return SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.edit),
                                title: const Text('แก้ไขโพสต์'),
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => NewPost(
                                        userData: userData,
                                        post: widget.userPost,
                                      ),
                                    ),
                                  );
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
                                  firestoreService.deletePost(widget.userPost);
                                  Navigator.pop(context);
                                },
                              ),
                            ],
                          ),
                        );
                      } else if (isAdmin) {
                        return SafeArea(
                          child: ListTile(
                            leading: Icon(
                              Icons.delete,
                              color: FontColor().errorColor(),
                            ),
                            title: Text(
                              'ลบโพสต์ (Admin)',
                              style: TextStyle(color: FontColor().errorColor()),
                            ),
                            onTap: () {
                              Navigator.pop(context);

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => AdminDeleteReasonPage(
                                    post: widget.userPost,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      } else {
                        return SafeArea(
                          child: ListTile(
                            leading: Icon(
                              Icons.flag,
                              color: FontColor().errorColor(),
                            ),
                            title: Text(
                              'รายงาน',
                              style: TextStyle(color: FontColor().errorColor()),
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              showDialog(
                                context: context,
                                builder: (_) => ReportDialog(
                                  postId: widget.userPost.postID ?? '',
                                  postOwnerId: widget.userPost.UID,
                                ),
                              );
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // สร้าง TextPainter เพื่อจำลองการวาดข้อความว่ามันเกิน 5 บรรทัดไหม
                  final span = TextSpan(
                    text: widget.userPost.content,
                    style: DefaultTextStyle.of(context).style,
                  );
                  final tp = TextPainter(
                    text: span,
                    maxLines: 5,
                    textDirection: TextDirection.ltr,
                  );
                  tp.layout(maxWidth: constraints.maxWidth);

                  // ถ้าข้อความยาวเกิน 5 บรรทัดจริงๆ ค่อยโชว์ปุ่มเพิ่มเติม
                  if (tp.didExceedMaxLines) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.userPost.content,
                          maxLines: isExpanded ? null : 5, // กำหนดบรรทัดสูงสุด
                          overflow: isExpanded
                              ? TextOverflow.visible
                              : TextOverflow.ellipsis,
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              isExpanded = !isExpanded; // สลับสถานะ ย่อ/ขยาย
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              isExpanded ? 'ย่อลง' : 'เพิ่มเติม...',
                              style: TextStyle(
                                color: Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    return Text(widget.userPost.content);
                  }
                },
              ),
            ),
          if (widget.userPost.imageUrl!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => Dialog(
                      child: InteractiveViewer(
                        clipBehavior: Clip.none,
                        maxScale: 4.0,
                        minScale: 0.5,
                        child: CachedNetworkImage(
                          imageUrl: widget.userPost.imageUrl!,
                        ),
                      ),
                    ),
                  );
                },
                child: CachedNetworkImage(
                  imageUrl: widget.userPost.imageUrl!,
                  placeholder: (context, url) => Container(
                    height: 200,
                    color: Colors.grey[200],
                    child: const Center(child: CupertinoActivityIndicator()),
                  ),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                  fit: BoxFit.cover,
                ),
              ),
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
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommentPage(
                              userPost: widget.userPost,
                              userData: userData,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(
                        CupertinoIcons.conversation_bubble,
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(widget.userPost.totalComment.formatCount),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Scaffold goToProfilePage() {
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
            const Text(
              '& Workout',
              style: TextStyle(
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
              colors: widgetColors.applicationMainTheme(),
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.close, color: Colors.white),
        ),
      ),
      body: ProfilePage(
        UID: widget.userPost.UID,
        currentUserRole: widget.currentUserRole,
      ),
    );
  }
}
