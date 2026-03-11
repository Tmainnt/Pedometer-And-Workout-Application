class WorkoutCategory {
  final String id;
  final String categoriesName;
  final String imageUrl;

  WorkoutCategory({
    required this.id,
    required this.categoriesName,
    required this.imageUrl,
  });

  factory WorkoutCategory.fromFirestore(Map<String, dynamic> data, String id) {
    return WorkoutCategory(
      id: id,
      categoriesName: data['categories_name'] ?? '',
      imageUrl: data['image_url'] ?? '',
    );
  }
}
