import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:pedometer/pedometer.dart';

class RuntimeTrackingService {
  double _totalDistance = 0.0;
  int _totalSeconds = 0;
  double _totalElevationGain = 0.0;
  int _totalSteps = 0;
  int _lastSteps = 0;
  int _isFirstStep = 0;
  StreamSubscription<StepCount>? _stepCountStream;
  Timer? _timer;
  Position? lastPosition;
  StreamSubscription<Position>? _positionStream;
  List<Map<String, double>> _routePath = [];

  Function(
    double dist,
    int time,
    String pace,
    List<Map<String, double>> route,
    double elevationGain,
    int steps,
  )?
  _onUpdateCallback;

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
    required Function(
      double dist,
      int time,
      String pace,
      List<Map<String, double>> route,
      double elevationGain,
      int steps,
    )
    onUpdate,
  }) {
    _resetData();
    _onUpdateCallback = onUpdate;
    _startTimerAndStream();
  }

  void _startTimerAndStream() {
    _isFirstStep = 1;

    // 1. จัดการ Stream ก้าวเดิน
    _stepCountStream = Pedometer.stepCountStream.listen((StepCount event) {
      if (_isFirstStep == 1) {
        _lastSteps = event.steps;
        _isFirstStep = 0;
      } else {
        int delta = event.steps - _lastSteps;
        if (delta > 0) {
          _totalSteps += delta;
          _lastSteps = event.steps;
        }
      }
      _sendUpdate();
    }, onError: (error) => print("Pedometer Error: $error"));

    // 2. จัดการตัวจับเวลา 
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _totalSeconds++;
      _sendUpdate();
    });

    // 3. จัดการ GPS
    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          ),
        ).listen((Position position) {
          if (lastPosition != null) {
            _totalDistance += Geolocator.distanceBetween(
              lastPosition!.latitude,
              lastPosition!.longitude,
              position.latitude,
              position.longitude,
            );
            double altDiff = position.altitude - lastPosition!.altitude;
            if (altDiff > 0) _totalElevationGain += altDiff;
          }
          _routePath.add({
            'lat': position.latitude,
            'lng': position.longitude,
            'alt': position.altitude,
          });
          lastPosition = position;
          _sendUpdate();
        });
  }

  List<Map<String, double>> get currentRoute => _routePath;

  void pauseTracking() {
    _timer?.cancel();
    _positionStream?.cancel();

    lastPosition = null;
  }

  void resumeTracking() {
    if (_onUpdateCallback != null) {
      _startTimerAndStream();
    }
  }

  void stopTracking() {
    _timer?.cancel();
    _positionStream?.cancel();
    _timer = null;
    _positionStream = null;
    lastPosition = null;
    _onUpdateCallback = null;
  }

  void _sendUpdate() {
    if (_onUpdateCallback != null) {
      _onUpdateCallback!(
        _totalDistance,
        _totalSeconds,
        _calculatePace(),
        _routePath,
        _totalElevationGain,
        _totalSteps, 
      );
    }
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
    _routePath = [];
    _totalDistance = 0.0;
    _totalSeconds = 0;
    _totalElevationGain = 0.0;
  }
}
