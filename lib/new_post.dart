import 'package:flutter/material.dart';
import 'package:pedometer_application/theme/widget_colors.dart';

class NewPost extends StatefulWidget {
  final Map<String, dynamic> userData;
  const NewPost({super.key, required this.userData});

  @override
  State<NewPost> createState() => NewPostState();
}

class NewPostState extends State<NewPost> {
  final TextEditingController _textEditingController = TextEditingController();

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
        leading: /*Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: WidgetColors().boxShadowColor(),
                offset: Offset(0, 3),
                blurRadius: 4,
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            padding: EdgeInsets.zero,
            constraints: BoxConstraints(minWidth: 36, minHeight: 36),
            icon: Icon(Icons.close, color: WidgetColors().iconColorMoreDark()),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shape: CircleBorder(),
            ),
          ),
        ),*/ IconButton(
          onPressed: () => Navigator.pop(context),
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
            height: 100,
            padding: EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [],
            ),
          ),
          Divider(height: 3, color: WidgetColors().iconColor(), thickness: 1),
          Expanded(
            child: ListView(
              children: [
                TextField(
                  controller: _textEditingController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.fromLTRB(10, 25, 0, 0),
                    hintText: 'วันนี้คุณเป็นยังไงบ้าง ระบายให้ฟังได้นะ...',
                  ),
                ),
                /*Image(
                  image: image,
                ),*/
                // แสดงรูปจากการที่ผู้ใช้เลือกรูปภาพมา เดี๋ยวมาทำต่อนะจ๊ะ
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: BottomAppBar(
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
                  Container(
                    decoration: BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: WidgetColors().boxShadowColor(),
                          offset: Offset(0, 0),
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Row(children: [

                    ],
                  ),
                  ),
                  SizedBox(width: 10),
                  Container(),
                ],
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadiusGeometry.circular(10),
                  ),
                  backgroundColor: WidgetColors().confirmButton(),
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'บันทึก',
                  style: TextStyle(fontSize: 11, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
