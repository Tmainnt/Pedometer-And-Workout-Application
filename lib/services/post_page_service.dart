import 'package:pedometer_application/models/post.dart';

class PostPageService {
  final Post postData;
  PostPageService({required this.postData});

  String checkTimestamp() {
    Duration diff = DateTime.now().difference(postData.timestamp);
    int day = diff.inDays;
    int hour = diff.inHours % 24;
    int min = diff.inMinutes % 60;

    if (day >= 365) {
      return "${(day / 365).floor()} ปี";
    }
    if (day >= 30 || day >= 28) {
      return "${day >= 30 ? (day / 30).floor : (day / 28).floor} เดือน";
    } // เช็คเดือน โดยเช็ค 30 และ 31 ก่อนจึงเช็ค เดือนกุมพาพันธ์
    if (day > 0) {
      return "$day วัน";
    }
    if (hour > 0) {
      return "$hour ชั่วโมง";
    }
    if (min > 0) {
      return "$min นาที";
    } else {
      return "เมื่อสักครู่";
    }
  }
}
