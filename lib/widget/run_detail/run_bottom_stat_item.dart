// widgets/run_detail/run_bottom_stat_item.dart
import 'package:flutter/material.dart';

class RunBottomStatItem extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const RunBottomStatItem({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
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