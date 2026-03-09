import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pedometer_application/sceen/community/edit_profile.dart';
import 'package:pedometer_application/models/post.dart';
import 'package:pedometer_application/models/user.dart';
import 'package:pedometer_application/theme/font_color.dart';
import 'package:pedometer_application/theme/widget_colors.dart';
import 'package:pedometer_application/services/firestore_service.dart';
import 'package:pedometer_application/widget/community/create_posts.dart';
import 'package:pedometer_application/extension/number_format.dart';
import 'package:pedometer_application/widget/community/report_user_dialog.dart';

enum ImageType { profile, background }

class ProfilePage extends StatefulWidget {
  const ProfilePage({
    super.key,
    required this.UID,
    required this.currentUserRole,
  });
  final String UID;
  final String currentUserRole;

  @override
  State<ProfilePage> createState() => ProfilePageState();
}

class ProfilePageState extends State<ProfilePage> {
  final WidgetColors widgetColors = WidgetColors();
  final FontColor fontColor = FontColor();
  final FirestoreService firestoreService = FirestoreService();

  late Future<UserModel> _userDataFuture;
  late Future<List<Post>> _userPostsFuture;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    _userDataFuture = firestoreService.getUserDataByUID(widget.UID);
    _userPostsFuture = firestoreService.getPostByUID(widget.UID);
  }

  Future<void> _handleRefresh() async {
    firestoreService.clearUserCacheByUID(widget.UID);
    setState(() {
      _loadData();
    });

    await Future.wait([_userDataFuture, _userPostsFuture]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<UserModel>(
        future: _userDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("เกิดข้อผิดพลาดในการโหลดข้อมูล"));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text("ไม่พบข้อมูลผู้ใช้"));
          }

          final userData = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _handleRefresh,
            color: Colors.orange,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 111, 52, 234),
                    Color.fromARGB(255, 121, 78, 239),
                    Color.fromARGB(255, 255, 108, 4),
                    Color.fromARGB(255, 255, 201, 163),
                  ],
                ),
              ),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                children: [
                  Container(
                    height: 300,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: widgetColors.boxShadowColor(),
                          blurRadius: 5,
                          offset: const Offset(0, 0),
                        ),
                      ],
                      color: widgetColors.lightTheme(),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(15),
                        bottomRight: Radius.circular(15),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          children: [
                            GestureDetector(
                              onTap: () {
                                _showFullImage(
                                  userData.backgroundImage,
                                  ImageType.background,
                                );
                              },
                              child: ClipRRect(
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 150,
                                  child:
                                      (userData.backgroundImage.isNotEmpty &&
                                          userData.backgroundImage != '')
                                      ? Image.network(
                                          userData.backgroundImage,
                                          fit: BoxFit.cover,
                                        )
                                      : Image.asset(
                                          'assets/default_background.png',
                                          fit: BoxFit.cover,
                                        ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                  27,
                                  10,
                                  15,
                                  10,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child:
                                          widget.UID ==
                                              FirebaseAuth
                                                  .instance
                                                  .currentUser!
                                                  .uid
                                          ? ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                backgroundColor: widgetColors
                                                    .confirmButton(),
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        EditProfilePage(
                                                          user: userData,
                                                        ),
                                                  ),
                                                ).then((_) {
                                                  _handleRefresh();
                                                });
                                              },
                                              child: const Text(
                                                'แก้ไขโปรไฟล์',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                          : PopupMenuButton<String>(
                                              icon: Icon(
                                                Icons.more_horiz,
                                                color: fontColor.textDark(),
                                                size: 28,
                                              ),
                                              onSelected: (value) {
                                                if (value == 'report') {
                                                  showDialog(
                                                    context: context,
                                                    builder: (context) =>
                                                        ReportUserDialog(
                                                          reportedUID:
                                                              widget.UID,
                                                        ),
                                                  );
                                                }
                                              },
                                              itemBuilder: (context) => [
                                                PopupMenuItem(
                                                  value: 'report',
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        Icons.flag,
                                                        color: fontColor
                                                            .errorColor(),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        'รายงานผู้ใช้',
                                                        style: TextStyle(
                                                          color: fontColor
                                                              .errorColor(),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                    ),
                                    const SizedBox(height: 10),
                                    Expanded(
                                      child: Text(
                                        userData.name,
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        userData.bio,
                                        style: TextStyle(
                                          color: fontColor.textDark(),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 100,
                                            child: _buildDetails(
                                              'ผู้ติดตาม',
                                              userData.totalFollower,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 130,
                                            child: _buildDetails(
                                              'กำลังติดตาม',
                                              userData.totalFollowing,
                                            ),
                                          ),
                                          SizedBox(
                                            width: 100,
                                            child: _buildDetails(
                                              'โพสต์',
                                              userData.totalPost,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Positioned(
                          left: 25,
                          top: 90,
                          child: GestureDetector(
                            onTap: () {
                              _showFullImage(
                                userData.phoUrl,
                                ImageType.profile,
                              );
                            },
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 55,
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  197,
                                  197,
                                  197,
                                ),
                                backgroundImage: userData.phoUrl.isNotEmpty
                                    ? NetworkImage(userData.phoUrl)
                                    : const AssetImage(
                                            'assets/default_profile.png',
                                          )
                                          as ImageProvider,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStats(userData),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetails(String label, int value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: fontColor.profilePageSubTitleDarkColor(),
            fontWeight: FontWeight.w500,
            fontSize: 12,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          value.toString(),
          style: TextStyle(
            color: fontColor.profilePageSubTitleLightColor(),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildStats(UserModel userData) {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Column(
        children: [
          Container(
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [BoxShadow(color: widgetColors.boxShadowColor())],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBodyDetails('น้ำหนัก', userData.weight),
                _buildBodyDetails('ส่วนสูง', userData.height),
                _buildBodyDetails('อายุ', userData.age),
                _buildBodyDetails('BMI', userData.BMI),
              ],
            ),
          ),
          const SizedBox(height: 10),
          _buildStatGrid(userData),
          const SizedBox(height: 15),
          _buildPostSection(),
        ],
      ),
    );
  }

  Widget _buildStatGrid(UserModel userData) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.5,
      ),
      children: [
        _buildStatCard(
          Icons.directions_walk,
          'ก้าวทั้งหมด',
          userData.totalStep.toString(),
        ),
        _buildStatCard(
          Icons.local_fire_department,
          'แคลอรี่ทั้งหมด',
          userData.totalCalories.toString(),
        ),
        _buildStatCard(
          Icons.location_on,
          'ระยะทางทั้งหมด',
          userData.totalDistance.toString(),
        ),
        _buildStatCard(
          Icons.access_time,
          'ระยะเวลาทั้งหมด',
          userData.totalTime.timeHourFormatShort,
        ),
        _buildStatCard(
          Icons.menu_book,
          'จำนวนบทเรียน',
          userData.lessongComplete.toString(),
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String title, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: widgetColors.boxShadowColor(),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.orange, size: 22),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: fontColor.profilePageSubTitleLightColor(),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: fontColor.textDark(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            'โพสต์ทั้งหมด',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: fontColor.textDark(),
            ),
          ),
        ),
        const SizedBox(height: 10),
        _buildPosts(),
      ],
    );
  }

  Widget _buildPosts() {
    return FutureBuilder<List<Post>>(
      future: _userPostsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(child: Text('ยังไม่มีโพสต์')),
          );
        }

        final posts = snapshot.data!;

        return ListView.builder(
          itemCount: posts.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Column(
              children: [
                CreatePosts(
                  userPost: posts[index],
                  currentUserRole: widget.currentUserRole,
                ),
                const SizedBox(height: 10),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildBodyDetails(String label, var value) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontSize: 12,
            color: fontColor.profilePageSubTitleDarkColor(),
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: fontColor.profilePageSubTitleLightColor(),
          ),
        ),
      ],
    );
  }

  void _showFullImage(String imageUrl, ImageType type) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              InteractiveViewer(
                child: Center(
                  child: imageUrl.isNotEmpty
                      ? Image.network(imageUrl)
                      : Image.asset(
                          type == ImageType.profile
                              ? 'assets/default_profile.png'
                              : 'assets/default_background.png',
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
