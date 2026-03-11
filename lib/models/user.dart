import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String _UID;
  final String _name;
  final String? _PhotoUrl;
  final String? _backgroundImage;
  final String? _bio;
  final String _role;
  final int _age;
  final int _height;
  final int _weight;
  final int _totalDistance;
  final int _totalCalories;
  final int _totalStep;
  final int _lessonsComplete;
  final int _totalFollower;
  final int _totalFollowing;
  final int _totalPost;
  final int _totalTime;
  final double _BMI;

  UserModel({
    required String? UID,
    required String? name,
    required String? phUrl,
    required String? bgImage,
    required String? bio,
    required String? role,
    required int? age,
    required int? height,
    required int? weight,
    required dynamic tDistance,
    required dynamic tCalories,
    required int? tStep,
    required int? lsComplete,
    required int? tFollower,
    required int? tFollowing,
    required int? tPost,
    required int? tTime,
    required double? bmi,
  }) : _UID = UID ?? '',
       _name = name ?? '',
       _PhotoUrl = phUrl ?? '',
       _backgroundImage = bgImage ?? '',
       _bio = bio ?? '',
       _role = role ?? '',
       _age = age ?? 0,
       _height = height ?? 0,
       _weight = weight ?? 0,
       _totalDistance = tDistance,
       _totalCalories = tCalories,
       _totalStep = tStep ?? 0,
       _lessonsComplete = lsComplete ?? 0,
       _totalFollower = tFollower ?? 0,
       _totalFollowing = tFollowing ?? 0,
       _totalPost = tPost ?? 0,
       _totalTime = tTime ?? 0,
       _BMI = bmi ?? 0;

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();

    return UserModel(
      UID: doc.id,
      name: data?['user_name'],
      phUrl: data?['user_photoUrl'],
      bgImage: data?['user_background_ImageUrl'],
      bio: data?['user_bio'],
      role: data?['role'],
      age: data?['user_age'],
      height: data?['user_height'],
      weight: data?['user_weight'],
      tDistance: safeInt(data?['user_total_distance']),
      tCalories: safeInt(data?['user_total_calories']),
      tStep: data?['user_total_step'],
      lsComplete: data?['user_lessons_completed'],
      tFollower: data?['user_total_follower'],
      tFollowing: data?['user_total_following'],
      tPost: data?['user_total_post'],
      tTime: data?['user_total_time'],
      bmi: data?['user_BMI'],
    );
  }

  String get UID => _UID;
  String get name => _name;
  String get phoUrl => _PhotoUrl ?? '';
  String get backgroundImage => _backgroundImage ?? '';
  String get bio => _bio ?? '';
  String get role => _role;
  int get age => _age;
  int get height => _height;
  int get weight => _weight;
  int get totalDistance => _totalDistance;
  int get totalCalories => _totalCalories;
  int get totalStep => _totalStep;
  int get lessongComplete => _lessonsComplete;
  int get totalFollower => _totalFollower;
  int get totalFollowing => _totalFollowing;
  int get totalPost => _totalPost;
  int get totalTime => _totalTime;
  double get BMI => _BMI;
}

int safeInt(dynamic value) {
  if (value == null) return 0;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
