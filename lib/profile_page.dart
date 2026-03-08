import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pedometer_application/edit_profile.dart';
import 'package:pedometer_application/models/post.dart';
import 'package:pedometer_application/models/user.dart';
import 'package:pedometer_application/theme/font_color.dart';
import 'package:pedometer_application/theme/widget_colors.dart';
import 'package:pedometer_application/services/firestore_service.dart';
import 'package:pedometer_application/widget/community/create_posts.dart';

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

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: firestoreService.getUserDataByUID(widget.UID),
      builder: (context, snapshot) {
        final check = firestoreService.checkHasData(snapshot);
        if (check != true) return check;

        final userData = snapshot.data!;

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

                Text(
                  '& Workout',
                  style: const TextStyle(
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
              icon: Icon(
                Icons.cancel,
                color: Colors.white,
                size: 40,
                shadows: [
                  Shadow(
                    color: widgetColors.boxShadowColor(),
                    blurRadius: 3,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(
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
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: widgetColors.boxShadowColor(),
                        blurRadius: 5,
                        offset: Offset(0, 0),
                      ),
                    ],
                    color: widgetColors.lightTheme(),
                    borderRadius: BorderRadius.only(
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
                            }, // จะให้แสดง ShowDialog และแสดงรูปภาพแบบเต็มๆ
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
                                        'assets/testBackgroundImage.png',
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            ),
                          ),

                          Expanded(
                            child: Container(
                              padding: EdgeInsets.fromLTRB(27, 10, 15, 10),
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
                                              );
                                            },
                                            child: Text(
                                              'แก้ไขโปรไฟล์',
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          )
                                        : const SizedBox(height: 50),
                                  ),
                                  SizedBox(height: 10),
                                  Expanded(
                                    child: Text(
                                      userData.name,
                                      style: TextStyle(fontSize: 15),
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
                            _showFullImage(userData.phoUrl, ImageType.profile);
                          }, // จะให้แสดง ShowDialog และแสดงรูปภาพแบบเต็มๆ
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
                                  : AssetImage('assets/testProfile.jpg'),
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
    );
  }

  // ใช้แสดง ผู้ติดตาม กำลังติดตาม และจำนวนโพสต์
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

  // แสดงค่าสถิติต่างๆ ของผู้ใช้ เช่น น้ำหนัก ส่วนสูง อายุ BMI และอื่นๆ
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

  // สร้าง Grid สำหรับแสดงสถิติต่างๆ ของผู้ใช้ เช่น ก้าวทั้งหมด แคลอรี่ทั้งหมด ระยะทางทั้งหมด และอื่นๆ
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
        _buildStatCard(Icons.directions_walk, 'ก้าวทั้งหมด', '571,573'),
        _buildStatCard(
          Icons.local_fire_department,
          'แคลอรี่ทั้งหมด',
          '147,239',
        ),
        _buildStatCard(Icons.location_on, 'ระยะทางทั้งหมด', '1,571 กม.'),
        _buildStatCard(Icons.access_time, 'ระยะเวลาทั้งหมด', '112 ชม.'),
        _buildStatCard(Icons.menu_book, 'จำนวนบทเรียน', '21'),
      ],
    );
  }

  // สร้าง Card สำหรับแสดงสถิติต่างๆ ของผู้ใช้
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

  // ส่วนของการแสดงโพสต์ทั้งหมดของผู้ใช้ โดยจะดึงข้อมูลจาก Method _buildPosts()
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

  // ดึงข้อมูลโพสต์ทั้งหมดของผู้ใช้จาก Firestore และ return ListView กลับไป
  Widget _buildPosts() {
    return FutureBuilder<List<Post>>(
      future: firestoreService.getPostByUID(widget.UID),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
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
                SizedBox(height: 10),
              ],
            );
          },
        );
      },
    );
  }

  // สร้าง Column สำหรับไปแสดงใน _buildStats()
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
                              ? 'assets/testProfile.jpg'
                              : 'assets/testBackgroundImage.png',
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
