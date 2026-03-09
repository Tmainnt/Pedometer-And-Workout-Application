import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class RunningMapCard extends StatelessWidget {
  const RunningMapCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15),
        child: const GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(13.7563, 100.5018),
            zoom: 15,
          ),
          zoomControlsEnabled: false,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
        ),
      ),
    );
  }
}
