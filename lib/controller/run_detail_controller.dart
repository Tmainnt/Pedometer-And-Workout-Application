import 'dart:math';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RunDetailController {
  final Map<String, dynamic> runData;

  RunDetailController(this.runData);

  // --- Private Logic ---

  double _getDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)) * 1000;
  }

  // --- Public Getters (ข้อมูลที่ UI จะเรียกใช้) ---

  List<LatLng> get polylinePoints {
    final List<dynamic> routeData = runData['route'] ?? [];
    return routeData.map((point) {
      return LatLng(point['lat'] as double, point['lng'] as double);
    }).toList();
  }

  List<double> get paceData {
    final List<dynamic> route = runData['route'] ?? [];
    if (route.length < 2) return [0.0, 0.0];

    List<double> paces = [];
    double totalDuration = (runData['duration'] ?? 1).toDouble();
    double timePerPoint = totalDuration / route.length;

    for (int i = 0; i < route.length - 1; i++) {
      double dist = _getDistance(
        route[i]['lat'], route[i]['lng'],
        route[i + 1]['lat'], route[i + 1]['lng']
      );

      if (dist > 0.5) {
        double paceRaw = (timePerPoint / dist) * (1000 / 60);
        paces.add(paceRaw > 12 ? 12 : paceRaw);
      } else {
        paces.add(paces.isNotEmpty ? paces.last : 12.0);
      }
    }
    if (paces.isNotEmpty) paces.add(paces.last);
    return paces;
  }

  String get maxPaceStr {
    final validPaces = paceData.where((p) => p > 0).toList();
    if (validPaces.isEmpty) return '0:00';

    double minPaceValue = validPaces.reduce((a, b) => a < b ? a : b);
    int pMin = minPaceValue.floor();
    int pSec = ((minPaceValue - pMin) * 60).round();
    return "$pMin:${pSec.toString().padLeft(2, '0')}";
  }

  String get timeStr {
    final int durationSeconds = (runData['duration'] ?? 0) as int;
    final int minutes = durationSeconds ~/ 60;
    final int seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // ข้อมูลสถิติอื่นๆ
  double get distance => (runData['distance'] ?? 0.0).toDouble();
  double get calories => (runData['calories'] ?? 0.0).toDouble();
  String get averagePace => runData['pace']?.toString() ?? "0:00";
  int get steps => (runData['steps'] ?? 0) as int;
  double get elevationGain => (runData['elevation_gain'] ?? 0.0).toDouble();
  List<double> get elevationSeries => (runData['elevations'] as List? ?? []).cast<double>();

  List<String> generateTimeLabels(int totalSeconds, int count) {
  double interval = totalSeconds / (count - 1);
  return List.generate(count, (i) {
    int currentSec = (i * interval).toInt();
    int min = currentSec ~/ 60;
    int sec = currentSec % 60;
    return "$min:${sec.toString().padLeft(2, '0')}";
  });
}
}