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
  final List<Map<String, dynamic>> equipment;

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
    List<Map<String, dynamic>> parseEquipment(dynamic equipmentData) {
      if (equipmentData == null) return [];

      if (equipmentData is List) {
        return equipmentData
            .where((item) => item is Map)
            .map((item) => Map<String, dynamic>.from(item as Map))
            .toList();
      } else if (equipmentData is Map) {
        return [Map<String, dynamic>.from(equipmentData)];
      }

      return [];
    }

    return Workout(
      id: id,
      workoutName: data['workout_name'] ?? '',
      calories: (data['calories'] ?? 0).toInt(),
      categoryId: data['category_id'] ?? '',
      description: data['description'] ?? '',
      difficultyLevel: data['difficult_level'] ?? '',
      duration: (data['duration'] ?? 0).toInt(),
      thumbnailUrl: data['thumbnailUrl'] ?? '',
      totalSteps: (data['total_steps'] ?? 0).toInt(),

      equipment: parseEquipment(data['equipment']),
    );
  }
}
