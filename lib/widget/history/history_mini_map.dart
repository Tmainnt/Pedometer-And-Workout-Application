import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HistoryMiniMap extends StatelessWidget {
  final List<LatLng> points;
  final String polylineId;

  const HistoryMiniMap({
    super.key,
    required this.points,
    required this.polylineId,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: const Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(15),
      ),
      child: points.isEmpty
          ? const Icon(Icons.location_off, color: Colors.grey)
          : ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: GoogleMap(
                // 💡 ใช้พิกัดแรกเป็นจุดศูนย์กลางของ Mini Map
                initialCameraPosition: CameraPosition(
                  target: points.first,
                  zoom: 14,
                ),
                // 💡 Lite Mode สำคัญมากสำหรับรายการที่ Scroll ได้ เพื่อประหยัด RAM
                liteModeEnabled: false,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                compassEnabled: false,
                mapToolbarEnabled: false,
                polylines: {
                  Polyline(
                    polylineId: PolylineId(polylineId),
                    points: points,
                    color: const Color(0xFF7E8CFD),
                    width: 3,
                  ),
                },
              ),
            ),
    );
  }
}
