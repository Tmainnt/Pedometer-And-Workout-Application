class ExerciseStep {
  final String id;
  final int order;
  final int reps;
  final int duration;
  final String title;
  final String videoUrl;
  final String thumbnailUrl;

  ExerciseStep({
    required this.id,
    required this.order,
    required this.reps,
    required this.duration,
    required this.title,
    required this.videoUrl,
    required this.thumbnailUrl,
  });

  factory ExerciseStep.fromFirestore(Map<String, dynamic> data, String id) {
    return ExerciseStep(
      id: id,
      order: (data['order'] ?? 0).toInt(),
      reps: (data['reps'] ?? 0).toInt(),
      duration: (data['duration'] ?? 0).toInt(),
      title: data['title']?.toString() ?? '',
      videoUrl: data['videoUrl']?.toString() ?? '',
      thumbnailUrl: data['thumbnailUrl']?.toString() ?? '',
    );
  }
}
