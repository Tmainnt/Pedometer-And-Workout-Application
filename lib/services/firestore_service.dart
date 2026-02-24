import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pedometer_application/models/post.dart';

class FirestoreService {
  final CollectionReference usersCollection = FirebaseFirestore.instance
      .collection('users');

  final CollectionReference postCollection = FirebaseFirestore.instance
      .collection('posts');

  Stream<DocumentSnapshot> getUserData() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .snapshots();
  }

  final uid = FirebaseAuth.instance.currentUser!.uid;

  Stream<DocumentSnapshot> getUserDataByUID(String UID) {
    return FirebaseFirestore.instance.collection('users').doc(UID).snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getPostData() {
    return FirebaseFirestore.instance
        .collection('posts')
        .orderBy('create_timestamp', descending: true)
        .snapshots();
  }

  dynamic checkHasData(AsyncSnapshot snapshot) {
    if (snapshot.hasError) {
      return Center(child: Text("เกิดข้อผิดพลาดในการอ่านข้อมูล"));
    }

    if (snapshot.connectionState == ConnectionState.waiting) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!snapshot.hasData || snapshot.data == null) {
      return const Center(child: Text('No data.'));
    }

    return true;
  }

  Future<void> deletePost(Post post) {
    return postCollection.doc(post.postID).delete();
  }

  Future<void> updatePost(Post post) {
    return postCollection.doc(post.postID).update({
      'content': post.content,
      'feeling': post.feeling,
      'imageUrl': post.imageUrl,
      'postBy_UID': post.UID,
      'create_timestamp': post.timestamp,
      'update_timestamp': post.updateTimestamp,
    });
  }

  Stream<bool> hasUserLikedPost(String postID, String uid) {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(postID)
        .collection('postLiked')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists);
  }

  Future<void> likePost(String postID) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await postCollection.doc(postID).collection('postLiked').doc(uid).set({
      'liked_at': FieldValue.serverTimestamp(),
    });

    await postCollection.doc(postID).update({
      'total_like': FieldValue.increment(1),
    });
  }

  Future<void> unlikePost(String postID) async {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    await postCollection.doc(postID).collection('postLiked').doc(uid).delete();

    await postCollection.doc(postID).update({
      'total_like': FieldValue.increment(-1),
    });
  }

  Future<void> addComment(String postID, String content) async {
    await postCollection.doc(postID).collection('postComment').add({
      'UID': uid,
      'content': content,
    });

    await postCollection.doc(postID).update({
      'total_comment': FieldValue.increment(1),
    });
  }

  Future<void> newPost(Post post) async {
    await postCollection.add({
      'content': post.content,
      'create_timestamp': FieldValue.serverTimestamp(),
      'feeling': post.feeling,
      'imageUrl': post.imageUrl,
      'postBy_UID': post.UID,
      'total_comment': 0,
      'total_like': 0,
      'update_timestamp': FieldValue.serverTimestamp(),
    });
  }
}
