import 'package:flutter/material.dart';
import 'package:pedometer_application/widget/home/list_heath_stat_item.dart';
import 'package:pedometer_application/widget/home/pedometer_app_bar.dart';
import 'package:pedometer_application/widget/home/running_map_card.dart';
import 'package:pedometer_application/widget/home/workout_header.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<StatefulWidget> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool _isTracking = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const PedometerAppBar(),
      body: SingleChildScrollView(
        child: Column(
          children: [_buildMainTrackingCard(), _buildHealthStatsCard()],
        ),
      ),
    );
  }

  Widget _buildMainTrackingCard() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [const Color(0xFF7E8CFD), const Color(0xFFB599FF)],
          ),
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: const Color(0xFF7E8CFD).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          spacing: 20,
          children: [
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color.fromARGB(255, 178, 186, 250),
                    const Color.fromARGB(255, 197, 179, 248),
                  ],
                ),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Column(
                spacing: 20,
                children: [
                  WorkoutStatsHeader(distance: 6.15, pace: 5.51, kcal: 300, totalSeconds: 1500),
                  const RunningMapCard(),
                ],
              ),
            ),

            _buildActionButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton() {
    return ElevatedButton.icon(
      onPressed: () {
        setState(() {
          _isTracking = !_isTracking;
        });
      },
      icon: Icon(_isTracking ? Icons.pause : Icons.play_arrow, size: 40),
      label: Text(_isTracking ? "หยุดชั่วคราว" : "เริ่มวิ่ง"),
    );
  }

  Widget _buildHealthStatsCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [const Color(0xFF7E8CFD), const Color(0xFFB599FF)],
        ),
        borderRadius: BorderRadius.circular(25),
      ),
      child: const Column(
        children: [
          ListHealthStatItem(
            icon: Icons.trending_up,
            label: "Elevation Gain",
            value: "+00",
          ),
          Divider(color: Colors.white54, height: 30),
          ListHealthStatItem(
            icon: Icons.favorite_outlined,
            label: "Heart Rate",
            value: "--",
          ),
        ],
      ),
    );
  }
}






