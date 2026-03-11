import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pedometer_application/screen/community/community_page.dart';
import 'package:pedometer_application/models/community/feeling.dart';
import 'package:pedometer_application/models/community/post.dart';
import 'package:pedometer_application/models/user.dart';
import 'package:pedometer_application/services/firestore_service.dart';
import 'package:pedometer_application/widget/community/feeling_selected.dart';
import 'package:pedometer_application/theme/font_color.dart';
import 'package:pedometer_application/theme/widget_colors.dart';
import 'dart:io';

class NewPost extends StatefulWidget {
  final UserModel userData;
  final Post? post;
  const NewPost({super.key, required this.userData, this.post});

  @override
  State<NewPost> createState() => NewPostState();
}

class NewPostState extends State<NewPost> {
  final TextEditingController _textEditingController = TextEditingController();
  final WidgetColors widgetColors = WidgetColors();
  final FontColor fontColors = FontColor();
  Feeling? _selectedFeeling;
  String? _networkImage;

  File? _image;
  final ImagePicker _picker = ImagePicker();
  String? oldImageUrl;

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

  @override
  void initState() {
    super.initState();

    if (widget.post != null) {
      _textEditingController.text = widget.post!.content;
      oldImageUrl = widget.post!.imageUrl;

      if (widget.post!.feeling!.isNotEmpty) {
        _selectedFeeling = Feeling(
          label: widget.post!.feeling!,
          imagePath: widget.post!.emotionUrl!,
        );
      }
    }

    if (widget.post?.imageUrl != null && widget.post!.imageUrl!.isNotEmpty) {
      _networkImage = widget.post!.imageUrl;
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
                _selectedFeeling != null) {
              showDialog(
                context: context,
                builder: (dialogContext) => AlertDialog(
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
                        Navigator.of(dialogContext).pop();
                        _textEditingController.clear();
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => CommunityPage()),
                        );
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('ยืนยัน'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
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
          icon: Icon(Icons.close, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: 90,
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                if (widget.userData.phoUrl.isNotEmpty &&
                    widget.userData.phoUrl != '')
                  CircleAvatar(
                    backgroundImage: NetworkImage(widget.userData.phoUrl),
                  ),
                if (widget.userData.phoUrl.isEmpty &&
                    widget.userData.phoUrl == '')
                  CircleAvatar(
                    backgroundImage: AssetImage('assets/default_profile.png'),
                  ),
                SizedBox(width: 20),
                if (_selectedFeeling == null)
                  Text(
                    widget.userData.name,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )
                else
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.userData.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Text('- ${_selectedFeeling!.label}'),
                          SizedBox(width: 10),
                          Image.asset(
                            _selectedFeeling!.imagePath,
                            width: 15,
                            height: 15,
                          ),
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
                  onChanged: (value) {
                    setState(() {});
                  },
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
                if (_image != null || _networkImage != null)
                  Stack(
                    children: [
                      if (_image != null)
                        Image.file(_image!)
                      else
                        Image.network(_networkImage!),

                      Positioned(
                        right: 12,
                        top: 12,
                        child: GestureDetector(
                          onTap: () async {
                            setState(() {
                              _image = null;
                              _networkImage = null;
                            });
                          },
                          child: CircleAvatar(
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
                children: [
                  GestureDetector(
                    onTap: () {
                      _showImageSourceActionSheet();
                    },
                    child: Container(
                      height: 70,
                      width: 70,
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            color: widgetColors.iconColorMoreDark(),
                            size: 40,
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
                      height: 70,
                      width: 70,
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
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(
                            Icons.emoji_emotions_outlined,
                            color: widgetColors.iconColorMoreDark(),
                            size: 40,
                          ),
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
                  elevation: 5,
                  shadowColor: WidgetColors().boxShadowColor(),
                  padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  backgroundColor:
                      (_textEditingController.text.isEmpty &&
                          _image == null &&
                          _networkImage == null)
                      ? widgetColors.waitButton()
                      : widgetColors.confirmButton(),
                ),
                onPressed: () {
                  if (_textEditingController.text.isNotEmpty ||
                      _image != null ||
                      _networkImage != null) {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                        title: Center(
                          child: Text(
                            'บันทึกข้อมูลหรือไม่?',
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            child: Text(
                              'ยกเลิก',
                              style: TextStyle(color: fontColors.discardText()),
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              Navigator.of(dialogContext).pop();
                              if (widget.post == null) {
                                final docRef = FirebaseFirestore.instance
                                    .collection('posts')
                                    .doc();

                                Post newPost = Post(
                                  postID: docRef.id,
                                  UID: FirebaseAuth.instance.currentUser!.uid,
                                  content: _textEditingController.text,
                                  feeling: _selectedFeeling?.label,
                                  emotionUrl: _selectedFeeling?.imagePath,
                                  imageUrl: '',
                                  totalLike: 0,
                                  totalComment: 0,
                                  timestamp: DateTime.now(),
                                  updateTimestamp: DateTime.now(),
                                );

                                await FirestoreService().newPost(
                                  newPost,
                                  _image,
                                );
                              } else {
                                await FirestoreService().updatePost(
                                  widget.post!.postID!,
                                  _textEditingController.text,
                                  _selectedFeeling,
                                  _image,
                                  _networkImage,
                                  oldImageUrl,
                                );
                              }
                              if (!mounted) return;
                              _textEditingController.clear();
                              Navigator.of(context).pop();
                            },
                            child: const Text('ยืนยัน'),
                          ),
                        ],
                      ),
                    );
                  }
                },
                child: Text(
                  'บันทึก',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _goToFeelingPage() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FeelingSelected(feeling: _selectedFeeling),
      ),
    );

    if (result != null) {
      setState(() {
        _selectedFeeling = result;
      });
    }
  }
}
