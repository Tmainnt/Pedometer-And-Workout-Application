import 'package:flutter/material.dart';
import 'package:pedometer_application/models/community/feeling.dart';
import 'package:pedometer_application/theme/font_color.dart';
import 'package:pedometer_application/theme/widget_colors.dart';

class FeelingSelected extends StatefulWidget {
  final Feeling? _feeling;
  const FeelingSelected({super.key, required feeling}) : _feeling = feeling;

  @override
  State<FeelingSelected> createState() => FeelingSelectedState();
}

class FeelingSelectedState extends State<FeelingSelected> {
  List<Feeling> fl = [
    Feeling(imagePath: 'assets/emotion/happy.png', label: 'มีความสุข'),
    Feeling(imagePath: 'assets/emotion/good.png', label: 'รู้สึกดี'),
    Feeling(imagePath: 'assets/emotion/thinking.png', label: 'ครุ่นคิด'),
    Feeling(imagePath: 'assets/emotion/omg.png', label: 'รู้สึกตกใจ'),
    Feeling(imagePath: 'assets/emotion/sleep.png', label: 'ง่วงนอน'),
    Feeling(imagePath: 'assets/emotion/shy.png', label: 'เขินอาย'),
    Feeling(imagePath: 'assets/emotion/flushed.png', label: 'เขินมาก'),
    Feeling(imagePath: 'assets/emotion/sick.png', label: 'รู้สึกป่วย'),
    Feeling(imagePath: 'assets/emotion/cry.png', label: 'รู้สึกเศร้า'),
    Feeling(imagePath: 'assets/emotion/angry.png', label: 'รู้สึกโกรธ'),
  ];

  final FontColor fontColor = FontColor();
  final WidgetColors widgetColors = WidgetColors();
  final TextEditingController _textEditingController = TextEditingController();
  Color? currentColor;
  Feeling? _currentSelected;
  Feeling? _initialFeeling;
  List<Feeling> filteredFl = [];

  @override
  void initState() {
    super.initState();
    _currentSelected = widget._feeling;
    _initialFeeling = widget._feeling;
    filteredFl = fl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'ความรู้สึก',
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
            if (_hasChanged) {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(
                    'ข้อมูลมีการเปลี่ยนแปลง จะบันทึกหรือไม่?',
                    style: TextStyle(fontSize: 20),
                  ),

                  actions: [
                    TextButton(
                      onPressed: () {
                        _textEditingController.clear();
                        Navigator.pop(context);
                        Navigator.pop(context, _currentSelected);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: fontColor.confirmText(),
                      ),
                      child: const Text('ยืนยัน'),
                    ),
                    TextButton(
                      onPressed: () {
                        _textEditingController.clear();
                        if (_hasChanged) {
                          Navigator.pop(context);
                          Navigator.pop(context, _initialFeeling);
                        } else {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        }
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: fontColor.discardText(),
                      ),
                      child: const Text('ละทิ้ง'),
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
          icon: Icon(Icons.close, color: Colors.white),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          children: [
            Container(
              height: 40,
              padding: EdgeInsets.fromLTRB(7, 3, 7, 3),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(5),
                color: Colors.white,
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
                  Expanded(
                    child: TextField(
                      controller: _textEditingController,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'ค้นหาความรู้สึกภายในของคุณ...',
                        suffixIcon: _textEditingController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  setState(() {
                                    _textEditingController.clear();
                                    filteredFl = fl;
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: (value) {
                        setState(() {
                          filteredFl = fl.where((f) {
                            return f.label.contains(value);
                          }).toList();
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _currentSelected != null
                    ? Row(
                        children: [
                          Text(
                            'จิตใจของคุณ...กำลัง${_currentSelected!.label}',
                            style: TextStyle(
                              color: fontColor.textDark(),
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 15),
                          Image.asset(
                            _currentSelected!.imagePath,
                            width: 17,
                            height: 17,
                          ),
                        ],
                      )
                    : Text(
                        'จิตใจของคุณยังคงไร้ความรู้สึก...',
                        style: TextStyle(
                          color: fontColor.textDark(),
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                if (_currentSelected != null)
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _currentSelected = null;
                      });
                    },
                    icon: Icon(
                      Icons.cancel,
                      color: widgetColors.iconColorMoreDark(),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 15),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.9,
                ),
                itemCount: filteredFl.length,
                physics: BouncingScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemBuilder: (context, index) {
                  return feelingCard(filteredFl[index]);
                },
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: _hasChanged
          ? Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: widgetColors.confirmButton(),
                ),
                onPressed: () {
                  Navigator.pop(context, _currentSelected);
                },
                child: Text(
                  'บันทึก',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget feelingCard(Feeling f) {
    final bool isSelected = _currentSelected?.label == f.label;
    return GestureDetector(
      onTap: () {
        setState(() {
          _currentSelected = f;
        });
      },
      child: Card(
        elevation: 3,
        shadowColor: isSelected
            ? widgetColors.selectedShadowColor()
            : widgetColors.boxShadowColor(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
          side: BorderSide(
            color: isSelected
                ? widgetColors.selectedShadowColor()
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 15),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                f.imagePath,
                width: 55,
                height: 55,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 10),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 5),
                child: Text(
                  f.label,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: fontColor.textDark()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _hasChanged {
    return _currentSelected?.label != _initialFeeling?.label;
  }
}
