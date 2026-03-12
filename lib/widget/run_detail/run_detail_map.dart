import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RunDetailMap extends StatelessWidget {
  final List<LatLng> points;

  const RunDetailMap({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    // 1. สร้าง Marker สำหรับจุดเริ่มต้น (สีเขียว) และจุดสิ้นสุด (สีน้ำเงิน)
    Set<Marker> markers = {};
    if (points.isNotEmpty) {
      markers.add(
        Marker(
          markerId: const MarkerId('start'),
          position: points.first,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueGreen,
          ),
          infoWindow: const InfoWindow(title: 'จุดเริ่มต้น'),
        ),
      );
      markers.add(
        Marker(
          markerId: const MarkerId('end'),
          position: points.last,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
          infoWindow: const InfoWindow(title: 'จุดสิ้นสุด'),
        ),
      );
    }

    return SizedBox(
      height: 300,
      child: GoogleMap(
        // 2. ใช้ EagerGestureRecognizer เพื่อให้เลื่อนแผนที่ใน SingleChildScrollView ได้ลื่นขึ้น
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
        },
        padding: const EdgeInsets.only(bottom: 20),
        initialCameraPosition: CameraPosition(
          target: points.isNotEmpty ? points.first : const LatLng(0, 0),
          zoom: 16,
        ),
        markers: markers,
        polylines: {
          Polyline(
            polylineId: const PolylineId('detail_route'),
            points: points,
            color: const Color(0xFF7E8CFD), // สีม่วงอ่อนตามธีมของคุณ
            width: 5,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        },
        myLocationEnabled: true,
        zoomControlsEnabled: false,
        mapToolbarEnabled: false,
        myLocationButtonEnabled: false,
      ),
    );
  }
}
