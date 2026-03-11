import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pedometer_application/models/community/post.dart';
import 'package:pedometer_application/models/user.dart';
import 'package:pedometer_application/screen/community/profile_page.dart';
import 'package:pedometer_application/services/firestore_service.dart';
import 'package:pedometer_application/services/post_page_service.dart';
import 'package:pedometer_application/theme/font_color.dart';
import 'package:pedometer_application/theme/widget_colors.dart';
import 'package:pedometer_application/widget/community/commentSection/comment_tile.dart';

class CommentPage extends StatefulWidget {
  const CommentPage({
    super.key,
    required this.userPost,
    required this.userData,
    this.currentUserRole = '',
  });

  final Post userPost;
  final UserModel userData;
  final String currentUserRole;

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final WidgetColors widgetColors = WidgetColors();
  final FontColor fontColor = FontColor();
  final FirestoreService firestoreService = FirestoreService();
  final String currentUID = FirebaseAuth.instance.currentUser!.uid;

  File? _image;
  String? _networkImage;
  final ImagePicker _picker = ImagePicker();
  bool _isSubmitting = false;

  String? _replyingToCommentId;
  String? _replyingToName;
  String? _replyingToUid;

  String? _editingCommentId;

  @override
  void dispose() {
    _commentController.dispose();
    _commentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1024,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        _networkImage = null;
      });
    }
  }

  void _showImageSourceActionSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text('เลือกจาก Gallery'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('ถ่ายภาพ'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty &&
        _image == null &&
        _networkImage == null)
      return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      String finalImageUrl = _networkImage ?? '';

      if (_image != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('comment_images')
            .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
        await ref.putFile(_image!);
        finalImageUrl = await ref.getDownloadURL();
      }

      if (_editingCommentId != null) {
        await firestoreService.updateComment(
          postId: widget.userPost.postID!,
          commentId: _editingCommentId!,
          content: _commentController.text.trim(),
          imageUrl: finalImageUrl,
        );
      } else {
        await firestoreService.addComment(
          postId: widget.userPost.postID!,
          postOwnerUid: widget.userPost.UID,
          currentUID: currentUID,
          content: _commentController.text.trim(),
          image: _image,
          replyingToCommentId: _replyingToCommentId,
          replyingToName: _replyingToName,
          replyingToUid: _replyingToUid,
        );
      }

      if (mounted) {
        setState(() {
          _commentController.clear();
          _image = null;
          _networkImage = null;
          _replyingToCommentId = null;
          _replyingToName = null;
          _replyingToUid = null;
          _editingCommentId = null;
        });
        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      print("Error submit/edit comment: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _goToProfile(String uid) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
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
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ),
          body: ProfilePage(UID: uid, currentUserRole: widget.currentUserRole),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('posts')
                    .doc(widget.userPost.postID!)
                    .collection('comment')
                    .orderBy('create_timestamp', descending: false)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError)
                    return const Center(child: Text("เกิดข้อผิดพลาด"));
                  if (snapshot.connectionState == ConnectionState.waiting)
                    return const Center(child: CircularProgressIndicator());

                  final allDocs = snapshot.data?.docs ?? [];
                  if (allDocs.isEmpty) {
                    return Center(
                      child: Text(
                        "ยังไม่มีความคิดเห็น เป็นคนแรกที่แสดงความคิดเห็นสิ!",
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    );
                  }

                  final parentDocs = allDocs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return data['parentCommentId'] == null;
                  }).toList();

                  final List<Map<String, dynamic>> displayList = [];
                  for (var parent in parentDocs) {
                    displayList.add({
                      'doc': parent,
                      'isReply': false,
                      'rootCommentId': parent.id,
                    });

                    final replies = allDocs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      return data['parentCommentId'] == parent.id;
                    }).toList();

                    for (var reply in replies) {
                      displayList.add({
                        'doc': reply,
                        'isReply': true,
                        'rootCommentId': parent.id,
                      });
                    }
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 20,
                    ),
                    itemCount: displayList.length,
                    itemBuilder: (context, index) {
                      final item = displayList[index];
                      final doc = item['doc'] as QueryDocumentSnapshot;
                      final commentData = doc.data() as Map<String, dynamic>;
                      final isReply = item['isReply'] as bool;
                      final rootCommentId = item['rootCommentId'] as String;

                      return CommentTile(
                        commentData: commentData,
                        currentUID: currentUID,
                        postId: widget.userPost.postID ?? '',
                        commentId: doc.id,
                        currentUserName: widget.userData.name,
                        isReply: isReply,
                        onProfileTap: () => _goToProfile(commentData['UID']),
                        onReplyTap: (userName, targetUid) {
                          setState(() {
                            _replyingToCommentId = rootCommentId;
                            _replyingToName = userName;
                            _replyingToUid = targetUid;
                            _editingCommentId = null;
                          });
                          _commentFocusNode.requestFocus();
                        },
                        onEditTap: (commentId, text, imageUrl) {
                          setState(() {
                            _editingCommentId = commentId;
                            _commentController.text = text;
                            _networkImage = imageUrl.isNotEmpty
                                ? imageUrl
                                : null;
                            _image = null;

                            _replyingToCommentId = null;
                            _replyingToName = null;
                            _replyingToUid = null;
                          });
                          _commentFocusNode.requestFocus();
                        },
                      );
                    },
                  );
                },
              ),
            ),
            _buildBottomInput(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final postPageService = PostPageService(postData: widget.userPost);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: widgetColors.applicationMainTheme(),
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => _goToProfile(widget.userPost.UID),
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
              backgroundImage: widget.userData.phoUrl.isNotEmpty
                  ? NetworkImage(widget.userData.phoUrl)
                  : const AssetImage('assets/default_profile.png')
                        as ImageProvider,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _goToProfile(widget.userPost.UID),
                  child: Text(
                    widget.userData.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  postPageService.checkTimestamp(),
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          if (currentUID != widget.userPost.UID)
            StreamBuilder<bool>(
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
                          : Colors.white,
                      foregroundColor: isFollowing
                          ? Colors.black87
                          : Colors.blueAccent,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 15,
                        vertical: 0,
                      ),
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
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildBottomInput() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.only(
          left: 15,
          right: 15,
          top: 10,
          bottom: 15,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              offset: const Offset(0, -2),
              blurRadius: 10,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // แถบสถานะ: ตอบกลับ หรือ แก้ไข
            if (_replyingToName != null)
              _buildStatusBadge(
                Icons.reply,
                'กำลังตอบกลับ $_replyingToName',
                () {
                  setState(() {
                    _replyingToCommentId = null;
                    _replyingToName = null;
                    _replyingToUid = null;
                  });
                },
              ),

            if (_editingCommentId != null)
              _buildStatusBadge(Icons.edit, 'กำลังแก้ไขความคิดเห็น...', () {
                setState(() {
                  _editingCommentId = null;
                  _commentController.clear();
                  _image = null;
                  _networkImage = null;
                });
              }),

            // พรีวิวรูปภาพ (ดักได้ทั้งรูปล่าสุดที่เลือกจากเครื่อง และรูปเก่าจากเน็ต)
            if (_image != null || _networkImage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _image != null
                          ? Image.file(
                              _image!,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              _networkImage!,
                              height: 100,
                              width: 100,
                              fit: BoxFit.cover,
                            ),
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: GestureDetector(
                        onTap: () => setState(() {
                          _image = null;
                          _networkImage = null;
                        }),
                        child: const CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.black54,
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  onPressed: _showImageSourceActionSheet,
                  icon: Icon(
                    Icons.add_photo_alternate_outlined,
                    color: widgetColors.iconColorMoreDark(),
                    size: 28,
                  ),
                ),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _commentController,
                            focusNode: _commentFocusNode,
                            minLines: 1,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              hintText: 'เขียนแสดงความคิดเห็น...',
                              hintStyle: TextStyle(color: Colors.grey),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 12,
                              ),
                            ),
                          ),
                        ),
                        // ปุ่มส่ง (ใช้ ValueListenableBuilder ทำให้ไม่หน่วง)
                        ValueListenableBuilder<TextEditingValue>(
                          valueListenable: _commentController,
                          builder: (context, value, child) {
                            final hasContent =
                                value.text.trim().isNotEmpty ||
                                _image != null ||
                                _networkImage != null;
                            if (_isSubmitting) {
                              return const Padding(
                                padding: EdgeInsets.all(10.0),
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              );
                            }
                            return IconButton(
                              onPressed: hasContent ? _submitComment : null,
                              icon: Icon(
                                Icons.send,
                                color: hasContent
                                    ? widgetColors.confirmButton()
                                    : Colors.grey,
                              ),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // วิดเจ็ตย่อยสำหรับสร้างแถบ "กำลังตอบกลับ..." และ "กำลังแก้ไข..."
  Widget _buildStatusBadge(IconData icon, String text, VoidCallback onClose) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.black54),
          const SizedBox(width: 5),
          Text(
            text,
            style: const TextStyle(color: Colors.black87, fontSize: 12),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: onClose,
            child: const Icon(Icons.close, size: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
