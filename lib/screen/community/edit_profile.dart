import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pedometer_application/models/user.dart';
import 'package:pedometer_application/theme/font_color.dart';
import 'package:pedometer_application/theme/widget_colors.dart';
import '../../../services/firestore_service.dart';

class EditProfilePage extends StatefulWidget {
  final UserModel user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  final FirestoreService _firestoreService = FirestoreService();
  final WidgetColors widgetColors = WidgetColors();
  final FontColor fontColor = FontColor();
  File? _profileImage;
  File? _backgroundImage;

  String? profileUrl;
  String? backgroundUrl;

  @override
  void initState() {
    super.initState();

    _nameController.text = widget.user.name;
    _bioController.text = widget.user.bio;
    _ageController.text = widget.user.age.toString();
    _heightController.text = widget.user.height.toString();
    _weightController.text = widget.user.weight.toString();

    profileUrl = widget.user.phoUrl;
    backgroundUrl = widget.user.backgroundImage;
  }

  bool hasChanges() {
    return _nameController.text.isNotEmpty ||
        _bioController.text.isNotEmpty ||
        _ageController.text.isNotEmpty ||
        _heightController.text.isNotEmpty ||
        _weightController.text.isNotEmpty ||
        _profileImage != null ||
        _backgroundImage != null;
  }

  Future<void> pickImage(bool isProfile) async {
    final picker = ImagePicker();

    final picked = await picker.pickImage(source: ImageSource.gallery);

    if (picked != null) {
      setState(() {
        if (isProfile) {
          _profileImage = File(picked.path);
        } else {
          _backgroundImage = File(picked.path);
        }
      });
    }
  }

  void showCancelDialog() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'ยกเลิกการเปลี่ยนแปลงหรือไม่',
          style: TextStyle(fontSize: 20),
        ),
        content: Text(
          'หากกดยืนยัน การเปลี่ยนแปลงทั้งหมดจะสูญหาย',
          style: TextStyle(color: fontColor.generalTextBrightTheme()),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              Navigator.pop(context);
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
  }

  Future<void> saveProfile() async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    String name = _nameController.text;
    String bio = _bioController.text;

    int age = int.tryParse(_ageController.text) ?? 0;
    int height = int.tryParse(_heightController.text) ?? 0;
    int weight = int.tryParse(_weightController.text) ?? 0;

    await _firestoreService.updateUserProfile(
      uid: uid,
      name: name,
      bio: bio,
      age: age,
      height: height,
      weight: weight,
      profileImage: _profileImage,
      backgroundImage: _backgroundImage,
      networkProfileImage: profileUrl,
      networkBackgroundImage: backgroundUrl,
      oldProfileUrl: widget.user.phoUrl,
      oldBackgroundUrl: widget.user.backgroundImage,
    );

    Navigator.pop(context);
  }

  Widget buildTextField(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: type,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'แก้ไขโปรไฟล์',
          style: TextStyle(color: fontColor.generalTextDarkTheme()),
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
            if (hasChanges()) {
              showCancelDialog();
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
                color: widgetColors.boxShadowColor(),
                blurRadius: 3,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildProfileHeader(),

            const SizedBox(height: 60),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  buildTextField("ชื่อผู้ใช้", _nameController),

                  buildTextField("Bio", _bioController),

                  buildTextField(
                    "อายุ",
                    _ageController,
                    type: TextInputType.number,
                  ),

                  buildTextField(
                    "ส่วนสูง (cm)",
                    _heightController,
                    type: TextInputType.number,
                  ),

                  buildTextField(
                    "น้ำหนัก (kg)",
                    _weightController,
                    type: TextInputType.number,
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: widgetColors.confirmButton(),
                    ),
                    onPressed: saveProfile,
                    child: Text(
                      "บันทึก",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildProfileHeader() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        /// Background
        GestureDetector(
          onTap: () => pickImage(false),
          child: Container(
            height: 180,
            width: double.infinity,
            decoration: BoxDecoration(
              image: _backgroundImage != null
                  ? DecorationImage(
                      image: FileImage(_backgroundImage!),
                      fit: BoxFit.cover,
                    )
                  : backgroundUrl != null && backgroundUrl!.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(backgroundUrl!),
                      fit: BoxFit.cover,
                    )
                  : const DecorationImage(
                      image: AssetImage("assets/default_background.png"),
                      fit: BoxFit.cover,
                    ),
            ),
          ),
        ),

        /// Camera icon background
        Positioned(
          right: 10,
          top: 140,
          child: CircleAvatar(
            backgroundColor: Colors.black54,
            child: Icon(Icons.camera_alt, color: Colors.white),
          ),
        ),

        /// Profile image
        Positioned(
          bottom: -50,
          left: MediaQuery.of(context).size.width / 2 - 50,
          child: GestureDetector(
            onTap: () => pickImage(true),
            child: CircleAvatar(
              radius: 50,
              backgroundImage: _profileImage != null
                  ? FileImage(_profileImage!)
                  : profileUrl != null && profileUrl!.isNotEmpty
                  ? NetworkImage(profileUrl!)
                  : const AssetImage("assets/default_profile.png")
                        as ImageProvider,
            ),
          ),
        ),

        Positioned(
          bottom: -50,
          left: MediaQuery.of(context).size.width / 2 + 20,
          child: CircleAvatar(
            radius: 16,
            backgroundColor: Colors.black54,
            child: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
          ),
        ),
      ],
    );
  }
}
