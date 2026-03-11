import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:pedometer_application/models/workout/workout_category.dart';
import 'package:pedometer_application/models/workout/workouts.dart';
import 'package:pedometer_application/screen/workout/workout_preparation_page.dart';
import 'package:pedometer_application/services/firestore_service.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => WorkoutPageState();
}

class WorkoutPageState extends State<WorkoutPage> {
  final FirestoreService firestoreService = FirestoreService();
  String? selectedCategoryId;

  String searchQuery = "";
  late Stream<List<WorkoutCategory>> _categoriesStream;

  @override
  void initState() {
    super.initState();
    _categoriesStream = firestoreService.getCategories();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value.toLowerCase();
                });
              },
              decoration: InputDecoration(
                hintText: 'ค้นหาท่าออกกำลังกาย...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
          ),
        ),

        StreamBuilder<List<WorkoutCategory>>(
          stream: _categoriesStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              );
            }

            if (snapshot.hasError) {
              return SliverToBoxAdapter(
                child: Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}')),
              );
            }

            final categories = snapshot.data ?? [];

            return SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                delegate: SliverChildBuilderDelegate((context, index) {
                  final category = categories[index];
                  final isSelected = selectedCategoryId == category.id;

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedCategoryId = isSelected ? null : category.id;
                      });
                    },
                    child: categoryCard(category, isSelected),
                  );
                }, childCount: categories.length),
              ),
            );
          },
        ),

        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "ท่าออกกำลังกาย",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        StreamBuilder<List<Workout>>(
          stream: firestoreService.getWorkouts(categoryId: selectedCategoryId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return SliverToBoxAdapter(child: Text(snapshot.error.toString()));
            }

            final allWorkouts = snapshot.data!;
            final workouts = allWorkouts.where((workout) {
              return workout.workoutName.toLowerCase().contains(searchQuery);
            }).toList();

            if (workouts.isEmpty) {
              return const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      "ไม่พบท่าออกกำลังกาย",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
              );
            }

            return SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => workoutItemCard(workouts[index]),
                childCount: workouts.length,
              ),
            );
          },
        ),
      ],
    );
  }

  Widget categoryCard(WorkoutCategory category, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? Colors.blue : Colors.transparent,
          width: 2,
        ),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            category.imageUrl,
            height: 30,
            errorBuilder: (c, e, s) => const Icon(Icons.fitness_center),
          ),
          const SizedBox(height: 8),
          Text(
            category.categoriesName,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? Colors.blue : Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget workoutItemCard(Workout workout) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(15),
                ),
                child: Image.network(
                  workout.thumbnailUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Image.asset(
                    'assets/default_background.png',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      workout.workoutName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                WorkoutPreparationPage(workout: workout),
                          ),
                        );
                      },
                      icon: Icon(
                        Icons.play_circle_fill,
                        color: Colors.blue[400],
                        size: 30,
                      ),
                    ),
                  ],
                ),
                Text(
                  workout.description,
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(Icons.menu_book, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      "${workout.totalSteps} ท่า",
                      style: const TextStyle(fontSize: 12),
                    ),
                    const SizedBox(width: 16),
                    const Icon(
                      Icons.directions_run,
                      size: 16,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "~${workout.duration} นาที",
                      style: const TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
