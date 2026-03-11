import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/run_repository.dart';

class HistoryController extends ChangeNotifier {
  final RunRepository _repo = RunRepository();
  final User? user = FirebaseAuth.instance.currentUser;

  final List<DocumentSnapshot> allFetchedDocs = [];
  bool isLoading = false;
  bool hasMore = true;
  int currentPage = 1;
  final int limit = 10;
  int trueRunsCount = 0;

  DateTime? startDate;
  DateTime? endDate;

  String sortBy = 'timestamp';
  String distanceFilter = 'all';

  // 🟢 เพิ่มตัวแปรเก็บยอดสรุป
  double filteredDistance = 0;
  int filteredDuration = 0;
  double filteredCalories = 0;

  HistoryController() {
    fetchTrueCountAndStart();
  }

  // 🟢 1. ฟังก์ชันคำนวณยอดสรุปจาก Server (ใช้ Aggregate sum)
  Future<void> _fetchSummary() async {
    if (user == null) return;

    filteredDistance = 0;
    filteredDuration = 0;
    filteredCalories = 0;

    try {
      var query = FirebaseFirestore.instance
          .collection('runs')
          .where('userId', isEqualTo: user!.uid);

      if (distanceFilter == 'light') {
        query = query.where('distance', isLessThan: 5);
      } else if (distanceFilter == 'medium') {
        query = query.where('distance', isGreaterThanOrEqualTo: 5).where('distance', isLessThanOrEqualTo: 10);
      } else if (distanceFilter == 'long') {
        query = query.where('distance', isGreaterThan: 10);
      }

      if (startDate != null && endDate != null) {
        Timestamp startTs = Timestamp.fromDate(DateTime(startDate!.year, startDate!.month, startDate!.day, 0, 0, 0));
        Timestamp endTs = Timestamp.fromDate(DateTime(endDate!.year, endDate!.month, endDate!.day, 23, 59, 59));
        query = query.where('timestamp', isGreaterThanOrEqualTo: startTs).where('timestamp', isLessThanOrEqualTo: endTs);
      }

      final aggregateSnapshot = await query
          .aggregate(sum('distance'), sum('duration'), sum('calories'))
          .get();

      filteredDistance = (aggregateSnapshot.getSum('distance') ?? 0).toDouble();
      filteredDuration = (aggregateSnapshot.getSum('duration') ?? 0).toInt();
      filteredCalories = (aggregateSnapshot.getSum('calories') ?? 0).toDouble();
      
      notifyListeners();
    } catch (e) {
      print("Error fetching summary: $e");
    }
  }

  void _resetAndFetch() {
    allFetchedDocs.clear();
    hasMore = true;
    currentPage = 1;
    trueRunsCount = 0;
    _fetchSummary();
    notifyListeners();
    fetchTrueCountAndStart();
  }

  void setFilterDate(DateTime? start, DateTime? end) {
    startDate = start;
    endDate = end;
    if (start != null) {
      sortBy = 'timestamp';
      distanceFilter = 'all';
    }
    _resetAndFetch();
  }

  void setSortBy(String value) {
    sortBy = value;
    if (value != 'distance') distanceFilter = 'all';
    _resetAndFetch();
  }

  void setDistanceFilter(String value) {
    distanceFilter = value;
    if (value != 'all') {
      sortBy = 'distance';
    
    } else {
      sortBy = 'timestamp';
    }
    _resetAndFetch();
  }

  // 🟢 2. อัปเดตฟังก์ชันนี้ให้เรียกใช้ _fetchSummary()
  Future<void> fetchTrueCountAndStart() async {
    if (user == null) return;

    // ดึงจำนวน (Count) และ ยอดรวม (Sum) พร้อมกัน
    await Future.wait([
      _repo.getTotalRunsCount(
        user!.uid,
        startDate: startDate,
        endDate: endDate,
        distanceFilter: distanceFilter,
      ).then((value) => trueRunsCount = value),
      _fetchSummary(), // 👈 ดึงยอดสรุปตาม Filter ปัจจุบัน
    ]);

    notifyListeners();
    await goToPage(1);
  }

  Future<void> goToPage(int page) async {
    if (user == null) return;
    int requiredCount = page * limit;
    isLoading = true;
    notifyListeners();

    try {
      while (allFetchedDocs.length < requiredCount && hasMore) {
        DocumentSnapshot? lastDoc = allFetchedDocs.isNotEmpty ? allFetchedDocs.last : null;
        final snapshot = await _repo.getPaginatedUserRuns(
          user!.uid,
          lastDocument: lastDoc,
          limit: limit,
          startDate: startDate,
          endDate: endDate,
          sortBy: sortBy,
          distanceFilter: distanceFilter,
        );

        if (snapshot.docs.isEmpty) {
          hasMore = false;
        } else {
          allFetchedDocs.addAll(snapshot.docs);
          if (snapshot.docs.length < limit) hasMore = false;
        }
      }
      currentPage = page;
    } catch (e) {
      print("Error changing page: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  int get totalPages {
    int pages = (trueRunsCount / limit).ceil();
    return pages == 0 ? 1 : pages;
  }

  List<DocumentSnapshot> get currentPageDocs {
    int startIndex = (currentPage - 1) * limit;
    int endIndex = startIndex + limit;
    if (endIndex > allFetchedDocs.length) endIndex = allFetchedDocs.length;
    return (startIndex < allFetchedDocs.length) ? allFetchedDocs.sublist(startIndex, endIndex) : [];
  }
}