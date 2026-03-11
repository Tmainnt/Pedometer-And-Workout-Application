import 'package:flutter/material.dart';
import 'package:pedometer_application/models/workout/exercise_step.dart';
import 'package:pedometer_application/models/workout/workouts.dart';
import 'package:pedometer_application/sceen/workout/workout_active_page.dart';
import 'package:pedometer_application/services/firestore_service.dart';
import 'package:pedometer_application/theme/font_color.dart';

class WorkoutPreparationPage extends StatefulWidget {
  final Workout workout;

  const WorkoutPreparationPage({super.key, required this.workout});

  @override
  State<WorkoutPreparationPage> createState() => _WorkoutPreparationPageState();
}

class _WorkoutPreparationPageState extends State<WorkoutPreparationPage> {
  final FirestoreService firestoreService = FirestoreService();
  final FontColor fontColor = FontColor();

  String _formatDuration(int seconds) {
    final int minutes = seconds ~/ 60;
    final int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B80FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        WorkoutActivePage(workout: widget.workout),
                  ),
                );
              },
              child: const Text(
                "เริ่ม",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            pinned: true,
            backgroundColor: Colors.white,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(0.8),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                widget.workout.thumbnailUrl,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) {
                  print(s);
                  return Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.image, size: 50),
                  );
                },
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.workout.workoutName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildInfoCol(widget.workout.difficultyLevel, "ระดับ"),
                      Container(width: 1, height: 30, color: Colors.grey[300]),
                      _buildInfoCol(
                        "${widget.workout.duration} นาที",
                        "ระยะเวลา",
                      ),
                      Container(width: 1, height: 30, color: Colors.grey[300]),
                      _buildInfoCol(
                        "${widget.workout.calories} Kcal",
                        "แคลอรี่",
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Text(
                    widget.workout.description,
                    style: TextStyle(color: Colors.grey[600], height: 1.5),
                  ),
                  const SizedBox(height: 24),

                  const Text(
                    "อุปกรณ์",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.workout.equipment.map((eq) {
                      return Chip(
                        avatar: Text('x${eq['quantity']}'),
                        label: Text(eq['name']?.toString() ?? 'ไม่ระบุ'),
                        backgroundColor: Colors.grey[200],
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    "ท่าออกกำลังกาย (${widget.workout.totalSteps})",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),

          StreamBuilder<List<ExerciseStep>>(
            stream: firestoreService.getExerciseSteps(widget.workout.id),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverToBoxAdapter(
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(child: Text('Error: ${snapshot.error}')),
                );
              }

              final steps = snapshot.data ?? [];

              if (steps.isEmpty) {
                return const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Center(
                      child: Text(
                        "ยังไม่มีข้อมูลขั้นตอนการออกกำลังกาย",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                );
              }

              return SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final step = steps[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 8,
                    ),
                    leading: Image.network(
                      step.thumbnailUrl,
                      width: 70,
                      height: 70,
                      errorBuilder: (c, e, s) => Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.fitness_center,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    title: Text(
                      step.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      step.reps > 0
                          ? "x${step.reps} ครั้ง"
                          : _formatDuration(step.duration),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  );
                }, childCount: steps.length),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCol(String topText, String bottomText) {
    return Column(
      children: [
        Text(
          topText,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: fontColor.generalTextBrightTheme(),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          bottomText,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
      ],
    );
  }
}
