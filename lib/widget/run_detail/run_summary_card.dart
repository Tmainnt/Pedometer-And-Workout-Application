import 'package:flutter/material.dart';

class RunSummaryCard extends StatelessWidget {
  final double distance;
  final String time;
  final double cal;
  final String pace;

  const RunSummaryCard({
    super.key,
    required this.distance,
    required this.time,
    required this.cal,
    required this.pace,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9F75FF), Color(0xFF7E8CFD)],
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
        children: [
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "สรุปผลวันนี้",
              style: TextStyle(color: Colors.white70, fontSize: 25, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SummaryItem(label: "ระยะทาง", value: "${distance.toStringAsFixed(2)} km", isBig: true),
              _SummaryItem(label: "เวลา", value: "$time นาที", isBig: true),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _SummaryItem(label: "แคลอรี่", value: "${cal.toInt()} kcal", isBig: false),
              _SummaryItem(label: "เพซเฉลี่ย", value: "$pace /km", isBig: false),
            ],
          ),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final bool isBig;

  const _SummaryItem({required this.label, required this.value, required this.isBig});

  @override
  Widget build(BuildContext context) {
    final parts = value.split(' ');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(parts[0], style: TextStyle(color: Colors.white, fontSize: isBig ? 32 : 24, fontWeight: FontWeight.bold)),
            const SizedBox(width: 4),
            if (parts.length > 1) Text(parts[1], style: const TextStyle(color: Colors.white, fontSize: 14)),
          ],
        ),
      ],
    );
  }
}