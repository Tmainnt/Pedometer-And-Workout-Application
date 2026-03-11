import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RunningMapCard extends StatefulWidget {
  final Set<Polyline> polylines;
  final LatLng? currentPosition;
  final bool isFullScreen;

  const RunningMapCard({
    super.key,
    required this.polylines,
    this.currentPosition,
    this.isFullScreen = false, // ค่าเริ่มต้นคือไม่เต็มจอ (โหมดการ์ดปกติ)
  });

  @override
  State<StatefulWidget> createState() => _RunningMapCardState();
}

class _RunningMapCardState extends State<RunningMapCard> {
  GoogleMapController? _mapController;
  bool _autoFollow = true;

  @override
  void didUpdateWidget(covariant RunningMapCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (_mapController != null &&
        widget.currentPosition != null &&
        _autoFollow) {
      if (oldWidget.currentPosition != widget.currentPosition) {
        _mapController!.animateCamera(
          CameraUpdate.newLatLng(widget.currentPosition!),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // 🟢 1. จัดการความสูง: ถ้าเต็มจอให้ขยายสุด (double.infinity) ถ้าโหมดปกติให้สูง 220
      height: widget.isFullScreen ? double.infinity : 220,
      decoration: BoxDecoration(
        // 🟢 2. จัดการขอบโค้งกรอบนอก: ถ้าเต็มจอให้เป็นกรอบเหลี่ยม (zero)
        borderRadius: widget.isFullScreen 
            ? BorderRadius.zero 
            : BorderRadius.circular(25),
        // 🟢 3. จัดการเงา: ถ้าเต็มจอไม่ต้องมีเงา (ปล่อย list ว่าง)
        boxShadow: widget.isFullScreen 
            ? [] 
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
      ),
      child: ClipRRect(
        // 🟢 4. จัดการขอบโค้งของตัว ClipRRect ด้านในให้ล้อไปกับกรอบนอก
        borderRadius: widget.isFullScreen 
            ? BorderRadius.zero 
            : BorderRadius.circular(15),
        child: GoogleMap(
          // เพิ่ม gestureRecognizers เพื่อแก้ปัญหา Gesture Conflict กับ ScrollView
          gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          },
          initialCameraPosition: CameraPosition(
            target: widget.currentPosition ?? const LatLng(13.7563, 100.5018),
            zoom: 15,
          ),
          onCameraMoveStarted: () => _autoFollow = false,
          onMapCreated: (controller) {
            _mapController = controller;
          },
          polylines: widget.polylines,
          zoomControlsEnabled: false,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          onTap: (_) {
            setState(() {
              _autoFollow = true;
            });
          },
        ),
      ),
    );
  }
}