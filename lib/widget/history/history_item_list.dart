import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:pedometer_application/widget/history/history_mini_map.dart';
import '../../page/run_detail_page.dart';

class HistoryListItem extends StatelessWidget {
  final Map<String, dynamic> data;

  const HistoryListItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    DateTime date = (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now();
    final dateStr = DateFormat('dd/MM, HH:mm').format(date);

    final distance = (data['distance'] ?? 0.0) as double;
    final cal = (data['calories'] ?? 0.0) as double;
    final durationSecond = (data['duration'] ?? 0) as int;
    final minute = (durationSecond / 60).floor();
    final second = durationSecond % 60;

    final List<dynamic> routeData = data['route'] ?? [];
    final List<LatLng> polylinePoints = routeData
        .map((point) => LatLng(point['lat'] as double, point['lng'] as double))
        .toList();

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => RunDetailPage(runData: data)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.1),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
           HistoryMiniMap(
              points: polylinePoints,
              polylineId: data['timestamp']?.toString() ?? DateTime.now().toString(),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateStr, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                  const SizedBox(height: 4),
                  Text(
                    "${distance.toStringAsFixed(2)} km | $minute:$second นาที | ${cal.toInt()} kcal",
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

}