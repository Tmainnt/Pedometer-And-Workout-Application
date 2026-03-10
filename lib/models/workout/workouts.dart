class Workout {
  final String id;
  final String workoutName;
  final int calories;
  final String categoryId;
  final String description;
  final String difficultyLevel;
  final int duration;
  final String thumbnailUrl;
  final int totalSteps;
  final List<Map<String, int>> equipment;

  Workout({
    required this.id,
    required this.workoutName,
    required this.calories,
    required this.categoryId,
    required this.description,
    required this.difficultyLevel,
    required this.duration,
    required this.thumbnailUrl,
    required this.totalSteps,
    required this.equipment,
  });

  factory Workout.fromFirestore(Map<String, dynamic> data, String id) {
    return Workout(
      id: id,
      workoutName: data['workout_name'] ?? '',
      calories: data['calories'] ?? 0,
      categoryId: data['category_id'] ?? '',
      description: data['description'] ?? '',
      difficultyLevel: data['difficult_level'] ?? '',
      duration: data['duration'] ?? 0,
      thumbnailUrl: data['thumnailUrl'] ?? '',
      totalSteps: data['total_steps'] ?? 0,
      equipment: List<Map<String, int>>.from(data['equipment'] ?? []),
    );
  }
}
