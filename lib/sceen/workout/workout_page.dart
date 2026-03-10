import 'package:flutter/material.dart';
import 'package:pedometer_application/models/workout/workout_category.dart';
import 'package:pedometer_application/models/workout/workouts.dart';
import 'package:pedometer_application/services/firestore_service.dart';

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => WorkoutPageState();
}

class WorkoutPageState extends State<WorkoutPage> {
  // 1. เพิ่มตัวแปรเก็บสถานะว่าเลือกหมวดหมู่ไหนอยู่ (ถ้า null คือแสดงทั้งหมด)
  String? selectedCategoryId;

  @override
  Widget build(BuildContext context) {
    final FirestoreService firestoreService = FirestoreService();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 10),
            child: TextField(
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
          stream: firestoreService.getCategories(),
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
                  // เช็คว่า Category นี้ตรงกับที่เลือกไว้หรือไม่
                  final isSelected = selectedCategoryId == category.id;

                  // 2. หุ้มด้วย GestureDetector เพื่อจับ Event การกด
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        // ถ้ากดซ้ำอันเดิม ให้ยกเลิกการเลือก (โชว์ทั้งหมด)
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
              "ท่าออกกำลังกายแนะนำ",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        // 4. Workouts List
        StreamBuilder<List<Workout>>(
          // 3. ส่ง selectedCategoryId ไปให้ FirestoreService เพื่อ Filter
          stream: firestoreService.getWorkouts(categoryId: selectedCategoryId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const SliverToBoxAdapter(child: SizedBox());
            }
            final workouts = snapshot.data!;

            // กรณีไม่มีข้อมูลในหมวดนั้น
            if (workouts.isEmpty) {
              return const SliverToBoxAdapter(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text(
                      "ไม่พบท่าออกกำลังกายในหมวดนี้",
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

  // 4. ปรับ UI Card ให้รับค่า isSelected และเปลี่ยนสี
  Widget categoryCard(WorkoutCategory category, bool isSelected) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        // เปลี่ยนสีขอบเป็นสีน้ำเงินถ้าถูกเลือก
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
          Image.network(
            category.imageUrl,
            height: 40,
            errorBuilder: (c, e, s) => const Icon(Icons.fitness_center),
          ),
          const SizedBox(height: 8),
          Text(
            category.categoriesName,
            style: TextStyle(
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected
                  ? Colors.blue
                  : Colors.black, // เปลี่ยนสีตัวหนังสือด้วยให้เข้ากัน
            ),
          ),
        ],
      ),
    );
  }

  Widget workoutItemCard(Workout workout) {
    // ใช้โค้ดเดิมของคุณได้เลยครับ
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
                  errorBuilder: (c, e, s) => Container(
                    height: 180,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image),
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
                        /* TODO: ไปหน้าเตรียมตัว */
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
