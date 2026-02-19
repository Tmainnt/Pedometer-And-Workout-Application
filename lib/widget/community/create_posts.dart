import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pedometer_application/models/post.dart';
import 'package:pedometer_application/services/firestore_service.dart';
import 'package:pedometer_application/theme/font_color.dart';
import 'package:pedometer_application/theme/widget_colors.dart';
import 'package:pedometer_application/services/post_page_service.dart';
import 'package:firebase_storage/firebase_storage.dart';

/* TODO: 
    1. ดักขนนาดของของรูปภาพที่ถูกเพิ่มเข้าไป
    2. เปลี่ยนการ fixed ขนาดของ Container
    3. เช็ครายละเอียดที่เหลือ ตรวจสอบความเรียบร้อย
*/

class CreatePosts extends StatelessWidget {
  final Post userPost;
  final FirestoreService firestoreService = FirestoreService();
  //final TextEditingController _reportButtonController = TextEditingController();
  final storageRef = FirebaseStorage.instance.ref();

  bool hasData = false;

  CreatePosts({super.key, required this.userPost});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: firestoreService.getUserDataByUID(userPost.UID),
      builder: (context, snapshot) {
        dynamic checkSnapshot = firestoreService.checkHasData(snapshot);
        if (checkSnapshot != true) {
          return checkSnapshot;
        } else {
          hasData = true;
        }

        if (hasData) {
          var userData = snapshot.data!.data() as Map<String, dynamic>;
          PostPageService postPageService = PostPageService(postData: userPost);
          return Container(
            height: 324,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: WidgetColors().boxShadowColor(),
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: EdgeInsets.all(5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        backgroundImage: NetworkImage(userData['imageUrl']),
                      ),
                      ListTile(
                        title: userData['user_name'],
                        subtitle: Text(postPageService.checkTimestamp()),
                        trailing: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            if (userPost.UID ==
                                FirebaseAuth.instance.currentUser!.uid)
                              ElevatedButton(
                                onPressed: () {},
                                child: Text('ติดตาม'),
                              ),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    content: GestureDetector(
                                      child: Container(
                                        padding: EdgeInsets.all(4),
                                        alignment: Alignment.center,
                                        height: 38,
                                        child: Row(
                                          children: [
                                            SizedBox(
                                              width: 23,
                                              height: 23,
                                              child: Icon(
                                                Icons.error_outline,
                                                color: Color.fromARGB(
                                                  0,
                                                  255,
                                                  22,
                                                  22,
                                                ),
                                              ),
                                            ),
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
                                    ),
                                  ),
                                );
                              },
                              icon: Icon(Icons.more_horiz),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Text(userPost.content),
                if ((userPost.imageUrl).isNotEmpty)
                  Image.network(userPost.imageUrl),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.favorite_outline,
                            color: WidgetColors().iconColor(),
                          ),
                          Text(
                            userPost.totalLike.toString(),
                            style: TextStyle(color: FontColor().postText()),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(
                            CupertinoIcons.conversation_bubble,
                            color: WidgetColors().iconColor(),
                          ),
                          Text(
                            userPost.totalComment.toString(),
                            style: TextStyle(color: FontColor().postText()),
                          ),
                        ],
                      ),
                      Icon(Icons.share, color: WidgetColors().iconColor()),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return Center(child: Text('ไม่พบข้อมูล'));
        }
      },
    );
  }
}
