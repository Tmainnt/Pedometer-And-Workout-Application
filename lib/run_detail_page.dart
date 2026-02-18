import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pedometer_application/widget/navbar/pedometer_app_bar.dart';

class RunDetailPage extends StatelessWidget {
  final Map<String, dynamic> runData;

  const RunDetailPage({super.key, required this.runData});

  double _getDistance(double lat1, double lon1, double lat2, double lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a =
        0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)) * 1000;
  }

  List<double> _calculatePaceFromRoute(List<dynamic> route) {
    if (route.length < 2) {
      return [0.0, 0.0];
    }

    List<double> paces = [];
    double totalDuration = (runData['duration'] ?? 1).toDouble();
    double timePerPoint = totalDuration / route.length;

    for (int i = 0; i < route.length - 1; i++) {
      var p1 = route[i];
      var p2 = route[i + 1];

      double distanceInMeters = _getDistance(
        p1['lat'],
        p1['lng'],
        p2['lat'],
        p2['lng'],
      );

      if (distanceInMeters > 0.5) {
        double paceRaw = (timePerPoint / distanceInMeters) * (1000 / 60);
        if (paceRaw > 12) {
          paceRaw = 12;
        }
        paces.add(paceRaw);
      } else {
        paces.add(paces.isNotEmpty ? paces.last : 12.0);
      }

      if (paces.isNotEmpty) {}
    }
    if (paces.isNotEmpty) {
      paces.add(paces.last);
    }

    return paces;
  }

  @override
  Widget build(BuildContext context) {
    final List<dynamic> routeData = runData['route'] ?? [];
    final List<LatLng> polylinePoints = routeData.map((point) {
      return LatLng(point['lat'] as double, point['lng'] as double);
    }).toList();

    final List<double> paceData = _calculatePaceFromRoute(routeData);

    final List<double> elevationData = (runData['elevations'] as List? ?? [])
        .map((e) => (e as num).toDouble())
        .toList();

    final double distance = (runData['distance'] ?? 0.0).toDouble();
    final double calories = (runData['calories'] ?? 0.0).toDouble();
    final int durationSeconds = (runData['duration'] ?? 0) as int;

    final int minutes = durationSeconds ~/ 60;
    final int seconds = durationSeconds % 60;
    final String timeStr =
        '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';

    String paceStr = runData['pace']?.toString() ?? "0:00";
    if (!paceStr.contains(':')) paceStr = "0:00";

    Set<Marker> markers = {};
    if (polylinePoints.isNotEmpty) {
      markers.add(
        Marker(
          markerId: const MarkerId('start'),
          position: polylinePoints.first,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
        ),
      );
      markers.add(
        Marker(
          markerId: const MarkerId('end'),
          position: polylinePoints.last,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        ),
      );
    }

    return Scaffold(
      appBar: PedometerAppBar(title: 'รายละเอียดการวิ่ง', subtitle: ""),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: 300,
              child: GoogleMap(
                padding: const EdgeInsets.only(bottom: 20),
                initialCameraPosition: CameraPosition(
                  target: polylinePoints.isNotEmpty
                      ? polylinePoints.first
                      : const LatLng(0, 0),
                  zoom: 16,
                ),
                markers: markers,
                polylines: {
                  Polyline(
                    polylineId: const PolylineId('detail_route'),
                    points: polylinePoints,
                    color: const Color(0xFF7E8CFD),
                    width: 5,
                  ),
                },
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
              ),
            ),

            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCard(distance, timeStr, calories, paceStr),
                      const SizedBox(height: 25),
                      const Text(
                        "สถิติเชิงลึก",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Row(
                        children: [
                          Expanded(
                            child: _buildChartItem(
                              "เพซการวิ่ง (min/km)",
                              Colors.blueAccent,
                              paceData,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildChartItem(
                              "ระดับความสูง (m)",
                              Colors.teal,
                              elevationData,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildBottomStat("เพซสูงสุด", "5:02", "/km"),
                          _buildBottomStat("ก้าวเดิน", "1,250", "ก้าว"),
                          _buildBottomStat("ความสูงที่เพิ่มขึ้น", "12", "m"),
                        ],
                      ),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    double distance,
    String time,
    double cal,
    String pace,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9F75FF), Color(0xFF7E8CFD)], // ไล่สีม่วง
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7E8CFD).withValues(alpha: 0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        spacing: 15,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "สรุปผลวันนี้",
            style: TextStyle(
              color: Colors.white70,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                "ระยะทาง",
                "${distance.toStringAsFixed(2)} km",
                isBig: true,
              ),
              _buildSummaryItem("เวลา", "$time นาที", isBig: true),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem("แคลอรี่", "${cal.toInt()} kcal", isBig: false),
              _buildSummaryItem("เพซเฉลี่ย", "$pace /km", isBig: false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, {required bool isBig}) {
    final parts = value.split(' ');
    final number = parts[0];
    final unit = parts.length > 1 ? parts[1] : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 14),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              number,
              style: TextStyle(
                color: Colors.white,
                fontSize: isBig ? 32 : 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unit,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildChartItem(String title, Color lineColor, List<double> data) {
    final List<double> displayData = data.isEmpty ? [0.0, 0.0] : data;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 110,
            width: double.infinity,
            child: CustomPaint(
              painter: SimpleLineChartPainter(
                color: lineColor,
                dataPoints: displayData,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomStat(String label, String value, String unit) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          "$value $unit",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class SimpleLineChartPainter extends CustomPainter {
  final Color color;
  final List<double> dataPoints;

  SimpleLineChartPainter({required this.color, required this.dataPoints});

  @override
  void paint(Canvas canvas, Size size) {
    if (dataPoints.isEmpty) {
      return;
    }

    const double leftMargin = 35.0;
    const double bottomMargin = 20.0;
    final double graphWidth = size.width - leftMargin;
    final double graphHeight = size.height - bottomMargin;

    int divisions = 5;
    double fixedMaxPace = 10.0;

     double getX(int index) =>
        leftMargin + (index * (graphWidth / (dataPoints.length - 1)));
    double getY(double value) => (value / fixedMaxPace) * graphHeight * 0.8;

    for (int i = 0; i <= divisions; i++) {
      double val = i * (fixedMaxPace / divisions);
      double y = getY(val);
      _drawAxisLabel(canvas, val.toStringAsFixed(1), Offset(5, y - 6));
      
      canvas.drawLine(
        Offset(leftMargin, y), 
        Offset(size.width, y), 
        Paint()..color = Colors.grey.withValues(alpha: 0.1)
      );
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final axisPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.5)
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(leftMargin, 0),
      Offset(leftMargin, graphHeight),
      axisPaint,
    );
    canvas.drawLine(
      Offset(leftMargin, graphHeight),
      Offset(size.width, graphHeight),
      axisPaint,
    );

 

    final path = Path();
    path.moveTo(0, getY(dataPoints[0]));

    for (int i = 1; i < dataPoints.length; i++) {
      path.lineTo(getX(i), getY(dataPoints[i]));
    }
    canvas.drawPath(path, paint);

    final bgPath = Path.from(path);
    bgPath.lineTo(getX(dataPoints.length - 1), graphHeight);
    bgPath.lineTo(leftMargin, graphHeight);
    bgPath.close();

    final bgPaint = Paint()
      ..shader = ui.Gradient.linear(Offset(0, 0), Offset(0, graphHeight), [
        color.withValues(alpha: 0.2),
        color.withValues(alpha: 0.01),
      ])
      ..style = PaintingStyle.fill;

    canvas.drawPath(bgPath, bgPaint);
  }

  void _drawAxisLabel(Canvas canvas, String text, Offset offset) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(color: Colors.grey[600], fontSize: 10),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant SimpleLineChartPainter oldDelegate) {
    return oldDelegate.dataPoints != dataPoints;
  }
}
