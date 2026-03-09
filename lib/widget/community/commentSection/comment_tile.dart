import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pedometer_application/extension/number_format.dart';
import 'package:pedometer_application/models/user.dart';
import 'package:pedometer_application/services/firestore_service.dart';
import 'package:pedometer_application/widget/community/commentSection/reply_line_painter.dart';
import 'package:pedometer_application/widget/community/report_user_dialog.dart';

class CommentTile extends StatefulWidget {
  final Map<String, dynamic> commentData;
  final String currentUID;
  final String postId;
  final String commentId;
  final bool isReply;
  final VoidCallback onProfileTap;
  final Function(String, String) onReplyTap;
  final Function(String, String, String) onEditTap;

  const CommentTile({
    super.key,
    required this.commentData,
    required this.currentUID,
    required this.postId,
    required this.commentId,
    required this.isReply,
    required this.onProfileTap,
    required this.onReplyTap,
    required this.onEditTap,
  });

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final commentUID = widget.commentData['UID'] ?? '';
    final content = widget.commentData['content'] ?? '';
    final imageUrl = widget.commentData['imageUrl'] ?? '';
    final int totalLike = widget.commentData['totalLike'] ?? 0;
    final replyToName = widget.commentData['replyToName'] as String?;
    final timestamp = widget.commentData['create_timestamp'] as Timestamp?;

    final timeStr = timestamp?.toTimeAgo ?? '';

    return FutureBuilder<UserModel>(
      future: FirestoreService().getUserDataByUID(commentUID),
      builder: (context, snapshot) {
        String name = 'กำลังโหลด...';
        String avatar = '';

        if (snapshot.hasData) {
          name = snapshot.data!.name;
          avatar = snapshot.data!.phoUrl;
        }

        return Padding(
          padding: EdgeInsets.only(
            left: widget.isReply ? 45.0 : 0.0,
            bottom: 15.0,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.isReply)
                CustomPaint(
                  size: const Size(20, 50),
                  painter: ReplyLinePainter(),
                ),
              GestureDetector(
                onTap: widget.onProfileTap,
                child: CircleAvatar(
                  radius: widget.isReply ? 16 : 20,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: avatar.isNotEmpty
                      ? NetworkImage(avatar)
                      : const AssetImage('assets/default_profile.png')
                            as ImageProvider,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: widget.onProfileTap,
                                    child: Text(
                                      name,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  if (commentUID == widget.currentUID)
                                    GestureDetector(
                                      onTap: () {
                                        showModalBottomSheet(
                                          context: context,
                                          builder: (bottomSheetContext) =>
                                              SafeArea(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    ListTile(
                                                      leading: const Icon(
                                                        Icons.edit,
                                                      ),
                                                      title: const Text(
                                                        'แก้ไขคอมเมนต์',
                                                      ),
                                                      onTap: () {
                                                        Navigator.pop(
                                                          bottomSheetContext,
                                                        );
                                                        widget.onEditTap(
                                                          widget.commentId,
                                                          content,
                                                          imageUrl,
                                                        );
                                                      },
                                                    ),
                                                    ListTile(
                                                      leading: const Icon(
                                                        Icons.delete,
                                                        color: Colors.redAccent,
                                                      ),
                                                      title: const Text(
                                                        'ลบคอมเมนต์',
                                                        style: TextStyle(
                                                          color:
                                                              Colors.redAccent,
                                                        ),
                                                      ),
                                                      onTap: () {
                                                        Navigator.pop(
                                                          bottomSheetContext,
                                                        );
                                                        FirestoreService()
                                                            .deleteComment(
                                                              widget.postId,
                                                              widget.commentId,
                                                            );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                              ),
                                        );
                                      },
                                      child: const Icon(
                                        Icons.more_horiz,
                                        size: 18,
                                        color: Colors.grey,
                                      ),
                                    )
                                  else
                                    GestureDetector(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => ReportUserDialog(
                                            reportedUID: commentUID,
                                            reportedName: name,
                                            postId: widget.postId,
                                            commentId: widget.commentId,
                                            commentText: content,
                                          ),
                                        );
                                      },
                                      child: const Icon(
                                        Icons.more_horiz,
                                        size: 18,
                                        color: Colors.grey,
                                      ),
                                    ),
                                ],
                              ),

                              if (content.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                LayoutBuilder(
                                  builder: (context, constraints) {
                                    final textSpan = TextSpan(
                                      children: [
                                        if (replyToName != null &&
                                            replyToName.isNotEmpty)
                                          TextSpan(
                                            text: '@$replyToName ',
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: Colors.blueAccent,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        TextSpan(
                                          text: content,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ],
                                    );

                                    final tp = TextPainter(
                                      text: textSpan,
                                      maxLines: 5,
                                      textDirection: TextDirection.ltr,
                                    );
                                    tp.layout(maxWidth: constraints.maxWidth);

                                    if (tp.didExceedMaxLines) {
                                      return Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          RichText(
                                            text: textSpan,
                                            maxLines: isExpanded ? null : 5,
                                            overflow: isExpanded
                                                ? TextOverflow.visible
                                                : TextOverflow.ellipsis,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                isExpanded = !isExpanded;
                                              });
                                            },
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                top: 4.0,
                                              ),
                                              child: Text(
                                                isExpanded
                                                    ? 'ย่อลง'
                                                    : 'เพิ่มเติม...',
                                                style: const TextStyle(
                                                  color: Colors.blueAccent,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    } else {
                                      return RichText(text: textSpan);
                                    }
                                  },
                                ),
                              ],

                              if (imageUrl.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    imageUrl,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.broken_image),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (totalLike > 0)
                          Positioned(
                            bottom: -10,
                            right: 5,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.thumb_up,
                                    size: 12,
                                    color: Colors.blueAccent,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    totalLike.formatCount,
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 12, top: 4),
                      child: Row(
                        children: [
                          Text(
                            timeStr,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 15),
                          StreamBuilder<bool>(
                            stream: FirestoreService().hasUserLikedComment(
                              widget.postId,
                              widget.commentId,
                              widget.currentUID,
                            ),
                            builder: (context, likeSnapshot) {
                              final isLiked = likeSnapshot.data ?? false;
                              return GestureDetector(
                                onTap: () {
                                  if (isLiked) {
                                    FirestoreService().unlikeComment(
                                      widget.postId,
                                      widget.commentId,
                                      widget.currentUID,
                                    );
                                  } else {
                                    FirestoreService().likeComment(
                                      widget.postId,
                                      widget.commentId,
                                      widget.currentUID,
                                    );
                                  }
                                },
                                child: Text(
                                  'ถูกใจ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: isLiked
                                        ? Colors.blueAccent
                                        : Colors.grey[700],
                                    fontWeight: isLiked
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(width: 15),
                          GestureDetector(
                            onTap: () => widget.onReplyTap(name, commentUID),
                            child: Text(
                              'ตอบกลับ',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
