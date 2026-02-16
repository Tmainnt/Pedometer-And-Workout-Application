import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pedometer_application/services/run_repository.dart';
import 'package:pedometer_application/widget/navbar/pedometer_app_bar.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final repo = RunRepository();

    if (user == null) {
      return const Scaffold(body: Center(child: Text("กรุณาเข้าสู่ระบบ")));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: PedometerAppBar(title: 'ประวัติการสิ่ง', subtitle: ''),
      body: StreamBuilder<QuerySnapshot>(
        stream: repo.getUserRuns(user.uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("ยังไม่มีประวัติการวิ่ง"));
          }

          final docs = snapshot.data!.docs;

          double totalDistance = 0;
          int totalDuration = 0;
          double totalCal = 0;

          for (var doc in docs) {
            final data = doc.data() as Map<String, dynamic>;

            totalDistance += (data['distance'] ?? 0.0) as double;
            totalDuration += (data['duration'] ?? 0) as int;
            totalCal += (data['calories'] ?? 0.0) as double;
          }

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildWeeklySummaryCard(
                        totalDistance,
                        totalDuration,
                        totalCal,
                        docs.length,
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        "กิจกรรมล่าสุด",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final data = docs[index].data() as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: _buildHistoryItem(data),
                  );
                }, childCount: docs.length),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildWeeklySummaryCard(
    double distance,
    int seconds,
    double cal,
    int count,
  ) {
    final duration = Duration(seconds: seconds);
    final hours = duration.inHours;
    final minutes = duration.inMinutes;
    final timeString = hours > 0 ? "${hours}h ${minutes}m" : "${minutes}m";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF7E8CFD), Color(0xFFB599FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7E8CFD).withValues(alpha: 0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        spacing: 20,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "สรุปสัปดาห์นี้",
            style: TextStyle(
              color: Colors.white,
              fontSize: 25,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildStatColumn(
                  "ระยะทางรวม",
                  "${distance.toStringAsFixed(1)} km",
                ),
              ),
              Expanded(child: _buildStatColumn("เวลารวม", timeString)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: _buildStatColumn("แคลอรี่รวม", "${cal.toInt()} kcal"),
              ),
              Expanded(child: _buildStatColumn("จำนวนกิจกรรม", "$count ครั้ง")),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 18),
        ),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem(Map<String, dynamic> data) {
    DateTime date = DateTime.now();

    if (data['timestamp'] != null) {
      date = (data['timestamp'] as Timestamp).toDate();
    }

    final dateStr = DateFormat('วันนี้, HH:mm').format(date);

    final distance = (data['distance'] ?? 0.0) as double;
    final cal = (data['calories'] ?? 0.0) as double;
    final durationSecond = (data['duration'] ?? 0) as int;
    final minute = (durationSecond / 60).floor();
    final second = durationSecond % 60;

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(15),
              image: const DecorationImage(
                image: NetworkImage("https://via.placeholder.com/150"),
                fit: BoxFit.cover,
              ),
            ),
            child: const Icon(Icons.map, color: Colors.grey),
          ),
          const SizedBox(width: 15),

          Expanded(
            child: Column(
              spacing: 8,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                  ),
                ),
                Text(
                  "${distance.toStringAsFixed(2)} km | $minute:$second นาที | ${cal.toInt()} kcal",
                  style: TextStyle(color: Colors.grey[600], fontSize: 18),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
        ],
      ),
    );
  }
}
