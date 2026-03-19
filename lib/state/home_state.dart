import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pedometer_application/utils/run_status.dart';

class HomeState {
  final bool isSaving;
  final RunStatus runStatus;

  final double currentDistanceKm;
  final int currentSeconds;
  final String currentPace;
  final double currentElevationGain;
  final int currentSteps;

  final List<Map<String, double>> currentRoute;
  final Set<Polyline> polylines;
  final LatLng? currentLatLng;

  final double dailyDistanceKm;
  final int dailySteps;
  final double dailyKcal;
  final int dailySeconds;

  HomeState({
    this.isSaving = false,
    this.runStatus = RunStatus.notStart,
    this.currentDistanceKm = 0.0,
    this.currentSeconds = 0,
    this.currentPace = "0:00",
    this.currentElevationGain = 0.0,
    this.currentSteps = 0,
    this.currentRoute = const [],
    this.polylines = const {},
    this.currentLatLng,
    this.dailyDistanceKm = 0.0,
    this.dailySteps = 0,
    this.dailyKcal = 0.0,
    this.dailySeconds = 0,
  });

  HomeState copyWith({
    bool? isSaving,
    RunStatus? runStatus,
    double? currentDistanceKm,
    int? currentSeconds,
    String? currentPace,
    double? currentElevationGain,
    int? currentSteps,
    List<Map<String, double>>? currentRoute,
    Set<Polyline>? polylines,
    LatLng? currentLatLng,
    double? dailyDistanceKm,
    int? dailySteps,
    double? dailyKcal,
    int? dailySeconds,
  }) {
    return HomeState(
      isSaving: isSaving ?? this.isSaving,
      runStatus: runStatus ?? this.runStatus,
      currentDistanceKm: currentDistanceKm ?? this.currentDistanceKm,
      currentSeconds: currentSeconds ?? this.currentSeconds,
      currentPace: currentPace ?? this.currentPace,
      currentElevationGain: currentElevationGain ?? this.currentElevationGain,
      currentSteps: currentSteps ?? this.currentSteps,
      currentRoute: currentRoute ?? this.currentRoute,
      polylines: polylines ?? this.polylines,
      currentLatLng: currentLatLng ?? this.currentLatLng,
      dailyDistanceKm: dailyDistanceKm ?? this.dailyDistanceKm,
      dailySteps: dailySteps ?? this.dailySteps,
      dailyKcal: dailyKcal ?? this.dailyKcal,
      dailySeconds: dailySeconds ?? this.dailySeconds,
    );
  }
}