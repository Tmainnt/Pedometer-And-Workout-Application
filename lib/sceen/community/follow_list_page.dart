import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pedometer_application/models/user.dart';
import 'package:pedometer_application/sceen/community/profile_page.dart';
import 'package:pedometer_application/services/firestore_service.dart';
import 'package:pedometer_application/theme/widget_colors.dart';
import 'package:pedometer_application/widget/community/report_user_dialog.dart';

class FollowListPage extends StatefulWidget {
  final String profileOwnerUID;
  final String currentUID;
  final bool isFollowersMode;
  final String currentRole;

  const FollowListPage({
    super.key,
    required this.profileOwnerUID,
    required this.currentUID,
    required this.isFollowersMode,
    required this.currentRole,
  });

  @override
  State<FollowListPage> createState() => _FollowListPageState();
}

class _FollowListPageState extends State<FollowListPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final WidgetColors widgetColors = WidgetColors();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.close, color: Colors.white),
        ),
        title: Text(
          widget.isFollowersMode ? "ผู้ติดตาม" : "กำลังติดตาม",
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: WidgetColors().applicationMainTheme(),
            ),
          ),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(widget.profileOwnerUID)
            .collection(widget.isFollowersMode ? 'follower' : 'following')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text(
                widget.isFollowersMode
                    ? "ยังไม่มีผู้ติดตาม"
                    : "ยังไม่ได้ติดตามใคร",
              ),
            );
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              String targetUID = snapshot.data!.docs[index].id;

              return FutureBuilder<UserModel>(
                future: _firestoreService.getUserDataByUID(targetUID),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) return const SizedBox.shrink();

                  final user = userSnapshot.data!;

                  return GestureDetector(
                    onTap: () {
                      _goToProfile(targetUID);
                    },
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: user.phoUrl.isNotEmpty
                            ? NetworkImage(user.phoUrl)
                            : const AssetImage('assets/default_profile.png')
                                  as ImageProvider,
                      ),
                      title: Text(
                        user.name,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (targetUID != widget.currentUID)
                            _buildFollowButton(targetUID),

                          IconButton(
                            icon: const Icon(Icons.more_horiz),
                            onPressed: () => _showMoreOptions(context, user),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildFollowButton(String targetUID) {
    return StreamBuilder<bool>(
      stream: _firestoreService.hasUserFollowed(targetUID, widget.currentUID),
      builder: (context, snapshot) {
        final isFollowing = snapshot.data ?? false;
        return TextButton(
          onPressed: () {
            if (isFollowing) {
              _firestoreService.unfollowUser(widget.currentUID, targetUID);
            } else {
              _firestoreService.followUser(widget.currentUID, targetUID);
            }
          },
          child: Text(
            isFollowing ? "เลิกติดตาม" : "ติดตาม",
            style: TextStyle(
              color: isFollowing ? Colors.grey : Colors.blueAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
    );
  }

  void _showMoreOptions(BuildContext context, UserModel user) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.report, color: Colors.red),
              title: const Text("รายงานผู้ใช้"),
              onTap: () {
                Navigator.pop(context);
                showDialog(
                  context: context,
                  builder: (_) => ReportUserDialog(
                    reportedUID: user.UID,
                    reportedName: user.name,
                    postId: '',
                    label: 'report_user',
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _goToProfile(String targetUID) {
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
          body: ProfilePage(
            UID: targetUID,
            currentUserRole: widget.currentRole,
          ),
        ),
      ),
    );
  }
}
