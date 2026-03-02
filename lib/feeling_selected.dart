import 'package:flutter/material.dart';
import 'package:pedometer_application/models/feeling.dart';
import 'package:pedometer_application/theme/font_color.dart';
import 'package:pedometer_application/theme/widget_colors.dart';

// ทำ Line 48 ต่อด้วย

class FeelingSelected extends StatefulWidget {
  const FeelingSelected({super.key});

  @override
  State<FeelingSelected> createState() => FeelingSelectedState();
}

class FeelingSelectedState extends State<FeelingSelected> {
  List<Feeling> fl = [
    Feeling(imagePath: 'assets/happy.png', label: 'มีความสุข'),
  ];

  final FontColor fontColor = FontColor();
  final WidgetColors widgetColors = WidgetColors();
  Color? currentColor;
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(3),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: widgetColors.boxShadowColor(),
                    offset: Offset(0, 0),
                    blurRadius: 5,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: widgetColors.iconColor()),
                  SizedBox(width: 10),
                  TextField(controller: TextEditingController()), // ตรงนี้จ้า
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget feelingCard(Feeling f) {
    return Card(
      child: Column(
        children: [
          Image.asset(f.imagePath, width: 100, height: 100),
          Text(f.label, style: TextStyle(color: fontColor.textDark())),
        ],
      ),
    );
  }
}
