import 'package:cloud_firestore/cloud_firestore.dart';

extension NumberFormatter on int {
  String get formatCount {
    if (this >= 1000000000000) {
      double value = this / 1000000000000;
      value = (value * 10).truncateToDouble() / 10;
      String formatted = value.toStringAsFixed(1);
      formatted = formatted.replaceFirst(RegExp(r'\.0$'), '');

      return '${formatted}T';
    }

    if (this >= 1000000000) {
      double value = this / 1000000000;
      value = (value * 10).truncateToDouble() / 10;
      String formatted = value.toStringAsFixed(1);
      formatted = formatted.replaceFirst(RegExp(r'\.0$'), '');

      return '${formatted}B';
    }

    if (this >= 1000000) {
      double value = this / 1000000;
      value = (value * 10).truncateToDouble() / 10;
      if ((value * 10) % 10 == 0) return '${value}M';
      String formatted = value.toStringAsFixed(1);
      formatted = formatted.replaceFirst(RegExp(r'\.0$'), '');

      return '${formatted}M';
    }

    if (this >= 1000) {
      double value = this / 1000;
      value = (value * 10).truncateToDouble() / 10;
      String formatted = value.toStringAsFixed(1);
      formatted = formatted.replaceFirst(RegExp(r'\.0$'), '');

      return '${formatted}K';
    }

    return toString();
  }

  String get timeHourFormatShort {
    if (this >= 60) {
      double hours = this / 60;
      String formatted = hours
          .toStringAsFixed(1)
          .replaceFirst(RegExp(r'\.0$'), '');

      return '$formatted ชม.';
    }

    return '$this นาที';
  }
}

extension TimestampTimeAgo on Timestamp {
  String get toTimeAgo {
    final diff = DateTime.now().difference(toDate());

    if (diff.inDays > 0) {
      return '${diff.inDays} วัน';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} ชม.';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} นาที';
    } else {
      return 'เมื่อสักครู่';
    }
  }
}
