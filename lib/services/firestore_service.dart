import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirestoreService {
  /*final CollectionReference user = FirebaseFirestore.instance.collection(
    'users',
  );*/

  Stream<DocumentSnapshot> getUserData() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .snapshots();
  }

  Stream<DocumentSnapshot> getUserDataByUID(String UID) {
    return FirebaseFirestore.instance.collection('users').doc(UID).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getPostData() {
    return FirebaseFirestore.instance.collection('posts').snapshots();
  }

  dynamic checkHasData(AsyncSnapshot snapshot) {
    if (snapshot.hasError) {
      return Center(child: Text("เกิดข้อผิดพลาดในการอ่านข้อมูล"));
    }
    if (snapshot.connectionState == ConnectionState.waiting) {
      return CircularProgressIndicator(
        color: const Color.fromARGB(0, 255, 203, 114),
      );
    }
    return true;
  }
}
