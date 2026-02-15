import 'dart:async';
import 'package:geolocator/geolocator.dart';

class RuntimeTrackingService {
  double _totalDistance = 0.0;
  int _totalSeconds = 0;
  Timer? _timer;
  Position? lastPosition;
  StreamSubscription<Position>? _positionStream;

  Future<bool> checkPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return false;
    }

    return true;
  }

  void startTracking({
    required Function(double dist, int time, String pace) onUpdate,
  }) {
    _resetData();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _totalSeconds++;
      onUpdate(_totalDistance, _totalSeconds, _calculatePace());
    });

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          ),
        ).listen((Position position) {
          if (lastPosition != null) {
            double distanceBetween = Geolocator.distanceBetween(
              lastPosition!.latitude,
              lastPosition!.longitude,
              position.latitude,
              position.longitude,
            );

            _totalDistance += distanceBetween;
          }

          lastPosition = position;

          onUpdate(_totalDistance, _totalSeconds, _calculatePace());
        });
  }

  void stopTracking() {
    _timer?.cancel();
    _positionStream?.cancel();
    _timer = null;
    _positionStream = null;
    lastPosition = null;
  }

  String _calculatePace() {
    if (_totalDistance < 10) {
      return "0.00";
    }

    double distanceInKm = _totalDistance / 1000;
    double timeInMinutes = _totalSeconds / 60;
    double paceDemical = timeInMinutes / distanceInKm;

    int minutes = paceDemical.toInt();
    int seconds = ((paceDemical - minutes) * 60).toInt();

    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  void _resetData() {
    _totalDistance = 0.0;
    _totalSeconds = 0;
  }
}
