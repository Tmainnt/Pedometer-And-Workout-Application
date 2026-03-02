import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pedometer_application/community_page.dart';
import 'package:pedometer_application/feeling_selected.dart';
import 'package:pedometer_application/theme/font_color.dart';
import 'package:pedometer_application/theme/widget_colors.dart';
import 'dart:io';

class NewPost extends StatefulWidget {
  final Map<String, dynamic> userData;
  const NewPost({super.key, required this.userData});

  @override
  State<NewPost> createState() => NewPostState();
}

class NewPostState extends State<NewPost> {
  final TextEditingController _textEditingController = TextEditingController();
  final WidgetColors widgetColors = WidgetColors();
  final FontColor fontColors = FontColor();
  String? _feeling;
  // Image Picker section
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1024,
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'สร้างโพสต์ใหม่',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: WidgetColors().applicationMainTheme(),
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
        leading: IconButton(
          onPressed: () {
            if ((_textEditingController.text).isNotEmpty ||
                _image != null ||
                _feeling != null) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    'ยกเลิกการเปลี่ยนแปลงหรือไม่',
                    style: TextStyle(fontSize: 20),
                  ),
                  content: Text(
                    'หากกดยืนยันการเปลี่ยนแปลงทั้งหมดจะสูญหายไป ท่านตัดสินใจจะกดยกเลิกหรือไม่',
                    style: TextStyle(color: fontColors.textDark()),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        _textEditingController.clear();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CommunityPage(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('ยืนยัน'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('ยกเลิก'),
                    ),
                  ],
                ),
              );
            } else {
              Navigator.pop(context);
            }
          },
          icon: Icon(
            Icons.cancel,
            color: Colors.white,
            size: 40,
            shadows: [
              Shadow(
                color: WidgetColors().boxShadowColor(),
                blurRadius: 3,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 90,
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                if (widget.userData['user_photoUrl'].isNotEmpty)
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      widget.userData['user_photoUrl'],
                    ),
                  ),
                if (widget.userData['user_photoUrl'].isEmpty)
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/default_profile.png'),
                  ),
                SizedBox(width: 20),
                if (_feeling == null)
                  Text(
                    widget.userData['user_name'],
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  )
                else
                  Column(
                    children: [
                      Text(widget.userData['user_name']),
                      Row(
                        children: [
                          Text('ตอนนี้กำลังรู้สึก'),
                          Image.asset('assets/emotion/$_feeling'),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
          Divider(height: 3, color: WidgetColors().iconColor(), thickness: 1),
          Expanded(
            child: ListView(
              children: [
                TextField(
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.fromLTRB(10, 25, 0, 0),
                    hintText: 'วันนี้คุณเป็นยังไงบ้าง ระบายให้ฟังได้นะ...',
                  ),
                  keyboardType: TextInputType.multiline,
                  minLines: 1,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                ),
                SizedBox(height: 15),
                if (_image != null) Image.file(_image!),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 110,
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: WidgetColors().boxShadowColor(),
                offset: Offset(0, 0),
                blurRadius: 5,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () {
                      _showImageSourceActionSheet();
                    },
                    child: Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: WidgetColors().boxShadowColor(),
                            offset: Offset(0, 0),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Icon(
                              Icons.add_photo_alternate_outlined,
                              color: widgetColors.iconColorMoreDark(),
                              size: 40,
                            ),
                          ),
                          Text(
                            'เพิ่มรูปภาพ',
                            style: TextStyle(
                              color: fontColors.textWithIcon(),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      _goToFeelingPage();
                    },
                    child: Container(
                      padding: EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: [
                          BoxShadow(
                            color: WidgetColors().boxShadowColor(),
                            offset: Offset(0, 0),
                            blurRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Expanded(
                            child: Icon(
                              Icons.emoji_emotions_outlined,
                              color: widgetColors.iconColorMoreDark(),
                              size: 40,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'ความรู้สึก',
                            style: TextStyle(
                              color: fontColors.textWithIcon(),
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(15),
                  ),
                  backgroundColor: WidgetColors().confirmButton(),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'บันทึก',
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToFeelingPage() async {
    final feeling = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FeelingSelected()),
    );

    if (feeling != null) {
      _feeling = feeling;
    }
  }
}
