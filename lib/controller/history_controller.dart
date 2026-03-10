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

  HistoryController() {
    fetchTrueCountAndStart();
  }

  // 🟢 Logic 1: ดึงจำนวนของจริงตอนเปิดหน้า
  Future<void> fetchTrueCountAndStart() async {
    if (user == null) return;
    
    int realCount = await _repo.getTotalRunsCount(user!.uid);
    trueRunsCount = realCount;
    notifyListeners(); // แจ้ง UI ให้ขยับ
    
    await goToPage(1);
  }

  // 🟢 Logic 2: เปลี่ยนหน้าและดึงข้อมูล
  Future<void> goToPage(int page) async {
    if (user == null) return;

    int requiredCount = page * limit;
    isLoading = true;
    notifyListeners(); // แจ้ง UI ว่ากำลังโหลด

    try {
      while (allFetchedDocs.length < requiredCount && hasMore) {
        DocumentSnapshot? lastDoc = allFetchedDocs.isNotEmpty ? allFetchedDocs.last : null;

        final snapshot = await _repo.getPaginatedUserRuns(
          user!.uid,
          lastDocument: lastDoc,
          limit: limit,
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
      notifyListeners(); // แจ้ง UI ว่าโหลดเสร็จแล้ว
    }
  }

  // 🟢 Helper: คำนวณหน้าทั้งหมดให้เสร็จสรรพ (UI จะได้ไม่ต้องคิดเลขเอง)
  int get totalPages {
    int pages = (trueRunsCount / limit).ceil();
    return pages == 0 ? 1 : pages;
  }

  // 🟢 Helper: หั่นเฉพาะข้อมูลของหน้าปัจจุบันส่งไปให้ UI
  List<DocumentSnapshot> get currentPageDocs {
    int startIndex = (currentPage - 1) * limit;
    int endIndex = startIndex + limit;
    if (endIndex > allFetchedDocs.length) endIndex = allFetchedDocs.length;

    if (startIndex < allFetchedDocs.length) {
      return allFetchedDocs.sublist(startIndex, endIndex);
    }
    return [];
  }
}