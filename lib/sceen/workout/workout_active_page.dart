import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pedometer_application/models/workout/workouts.dart';
import 'package:pedometer_application/models/workout/exercise_step.dart';
import 'package:pedometer_application/services/firestore_service.dart';
import 'package:video_player/video_player.dart';

class WorkoutActivePage extends StatefulWidget {
  final Workout workout;

  const WorkoutActivePage({super.key, required this.workout});

  @override
  State<WorkoutActivePage> createState() => _WorkoutActivePageState();
}

class _WorkoutActivePageState extends State<WorkoutActivePage> {
  final FirestoreService _firestoreService = FirestoreService();
  bool _videoFinishedHandled = false;
  VideoPlayerController? _videoController;
  bool _isChangingStep = false;

  List<ExerciseStep> steps = [];
  bool isLoading = true;
  bool isCompleted = false;

  int currentIndex = 0;
  int totalSecondsElapsed = 0;
  Timer? _timer;

  int currentStepRemainingSeconds = 0;

  @override
  void initState() {
    super.initState();
    _loadStepsAndStart();
  }

  Future<void> _initializeVideo(String url) async {
    await _videoController?.dispose();
    _videoController = null;
    _videoFinishedHandled = false;

    if (url.isEmpty) {
      if (mounted) setState(() {});
      return;
    }

    final controller = VideoPlayerController.networkUrl(
      Uri.parse(url),
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
    );

    try {
      await controller.initialize();
      controller.setLooping(false);
      controller.setVolume(0);

      controller.addListener(() {
        final position = controller.value.position;
        final duration = controller.value.duration;

        if (!_videoFinishedHandled &&
            duration.inMilliseconds > 0 &&
            position >= duration) {
          _videoFinishedHandled = true;
          _nextStep();
        }
      });

      if (!mounted) return;
      setState(() {
        _videoController = controller;
      });
      controller.play();
    } catch (e) {
      print("Video init error: $e");
    }
  }

  Future<void> _loadStepsAndStart() async {
    try {
      final fetchedSteps = await _firestoreService
          .getExerciseSteps(widget.workout.id)
          .first;
      if (!mounted) return;

      setState(() {
        steps = fetchedSteps;
        isLoading = false;
      });

      if (steps.isNotEmpty) {
        currentStepRemainingSeconds = steps[0].duration;
        await _initializeVideo(steps[0].videoUrl);
      }
      _startTimer();
    } catch (e) {
      print("Error loading steps: $e");
    }
  }

  Widget _buildVideoArea(ExerciseStep step) {
    if (step.videoUrl.isEmpty) {
      return Container(
        width: double.infinity,
        height: 300,
        color: Colors.grey[200],
        child: Center(child: Icon(Icons.timer, size: 80, color: Colors.grey)),
      );
    }

    if (_videoController == null || !_videoController!.value.isInitialized) {
      return Container(
        width: double.infinity,
        height: 300,
        color: Colors.black12,
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 300,
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _videoController!.value.size.width,
          height: _videoController!.value.size.height,
          child: VideoPlayer(_videoController!),
        ),
      ),
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted || isCompleted || _isChangingStep) return;

      setState(() {
        totalSecondsElapsed++;

        if (steps[currentIndex].reps == 0 && currentStepRemainingSeconds > 0) {
          currentStepRemainingSeconds--;

          if (currentStepRemainingSeconds == 0) {
            _nextStep();
          }
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _videoController?.dispose();
    super.dispose();
  }

  String _formatTime(int seconds) {
    int m = seconds ~/ 60;
    int s = seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _nextStep() async {
    if (_isChangingStep || isCompleted) return;
    _isChangingStep = true;

    if (currentIndex < steps.length - 1) {
      int nextIdx = currentIndex + 1;

      setState(() {
        currentIndex = nextIdx;
        currentStepRemainingSeconds = steps[nextIdx].duration;
      });

      await _initializeVideo(steps[nextIdx].videoUrl);

      _isChangingStep = false;
    } else {
      _finishWorkout();
    }
  }

  void _previousStep() async {
    if (_isChangingStep || currentIndex <= 0) return;
    _isChangingStep = true;

    int prevIdx = currentIndex - 1;
    setState(() {
      currentIndex = prevIdx;
      currentStepRemainingSeconds = steps[prevIdx].duration;
    });

    await _initializeVideo(steps[prevIdx].videoUrl);
    _isChangingStep = false;
  }

  void _finishWorkout() {
    _timer?.cancel();
    setState(() {
      isCompleted = true;
    });
  }

  Future<void> _saveHistoryAndExit() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณาเข้าสู่ระบบก่อนบันทึกประวัติ')),
      );
      Navigator.pop(context);
      return;
    }

    try {
      double expectedSeconds = widget.workout.duration * 60.0;
      double progress = expectedSeconds > 0
          ? (totalSecondsElapsed / expectedSeconds)
          : 1.0;

      int burnedCalories = (widget.workout.workoutName.isNotEmpty)
          ? (widget.workout.calories * progress).round()
          : 0;

      if (burnedCalories > widget.workout.calories) {
        burnedCalories = widget.workout.calories;
      }

      final historyData = {
        'calories_burned': burnedCalories,
        'duration': totalSecondsElapsed,
        'complete_timestamp': FieldValue.serverTimestamp(),
        'workout_uid': widget.workout.id,
        'thumbnail_url': widget.workout.thumbnailUrl,
      };

      FirestoreService().saveWorkoutToUSerHistory(historyData, user);

      Navigator.popUntil(context, (route) => route.isFirst);
    } catch (e) {
      print("Error saving history: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('บันทึกผิดพลาด: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (steps.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text("ผิดพลาด")),
        body: const Center(child: Text("ไม่พบขั้นตอนการออกกำลังกาย")),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: isCompleted ? _buildSummaryUI() : _buildActiveUI(),
    );
  }

  Widget _buildActiveUI() {
    final step = steps[currentIndex];

    return Column(
      children: [
        Stack(
          children: [
            _buildVideoArea(step),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.8),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: _finishWorkout,
                  ),
                ),
              ),
            ),
          ],
        ),

        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "ท่าออกกำลังกายที่ ${currentIndex + 1}/${steps.length}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _formatTime(totalSecondsElapsed),
                style: TextStyle(fontSize: 16, color: Colors.grey[600]),
              ),
            ],
          ),
        ),

        Expanded(
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: Color(0xFF6B80FF),
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  step.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Text(
                  step.reps > 0
                      ? "X ${step.reps}"
                      : _formatTime(currentStepRemainingSeconds),
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 25,
                      child: IconButton(
                        icon: const Icon(
                          Icons.skip_previous,
                          color: Colors.black,
                        ),
                        onPressed: currentIndex > 0 ? _previousStep : null,
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: _nextStep,
                      child: const Text(
                        "เสร็จสิ้น",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 25,
                      child: IconButton(
                        icon: const Icon(Icons.skip_next, color: Colors.black),
                        onPressed: currentIndex < steps.length - 1
                            ? _nextStep
                            : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryUI() {
    return Column(
      children: [
        Stack(
          children: [
            Image.network(
              widget.workout.thumbnailUrl,
              width: double.infinity,
              height: 350,
              fit: BoxFit.cover,
              errorBuilder: (c, e, s) => Image.asset(
                'assets/default_background.png',
                width: double.infinity,
                height: 350,
                fit: BoxFit.cover,
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withOpacity(0.8),
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.black),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
            ),
          ],
        ),
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "ออกกำลังกายเสร็จสิ้น!",
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.workout.workoutName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCol("${steps.length}", "จำนวนท่า"),
                    Container(width: 1, height: 40, color: Colors.grey[300]),
                    _buildStatCol("${widget.workout.calories}", "แคลอรี่"),
                    Container(width: 1, height: 40, color: Colors.grey[300]),
                    _buildStatCol(_formatTime(totalSecondsElapsed), "ระยะเวลา"),
                  ],
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B80FF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    onPressed: _saveHistoryAndExit,
                    child: const Text(
                      "เสร็จสิ้น",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCol(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }
}
