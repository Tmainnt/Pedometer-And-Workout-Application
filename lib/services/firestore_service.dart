import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pedometer_application/models/feeling.dart';
import 'package:pedometer_application/models/post.dart';

class FirestoreService {
  final CollectionReference usersCollection = FirebaseFirestore.instance
      .collection('users');

  final CollectionReference postCollection = FirebaseFirestore.instance
      .collection('posts');

  Future<DocumentSnapshot> getUserData() {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();
  }

  Future<DocumentSnapshot> getUserDataByUID(String UID) {
    return FirebaseFirestore.instance.collection('users').doc(UID).get();
  }

  Future<QuerySnapshot<Map<String, dynamic>>> getPostData() {
    return FirebaseFirestore.instance
        .collection('posts')
        .orderBy('create_timestamp', descending: true)
        .get();
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

  Future<void> deletePost(Post post) async {
    try {
      if (post.imageUrl != null && post.imageUrl!.isNotEmpty) {
        await FirebaseStorage.instance.refFromURL(post.imageUrl!).delete();
      }
    } catch (e) {
      // ถ้ารูปไม่มีใน storage แล้วก็ข้ามไป
    }
    return postCollection.doc(post.postID).delete();
  }

  Future<void> deleteImage(String imageUrl) async {
    if (imageUrl.isEmpty) return;

    final ref = FirebaseStorage.instance.refFromURL(imageUrl);
    await ref.delete();
  }

  Future<void> updatePost(
    String postID,
    String content,
    Feeling? feeling,
    File? image,
    String? networkImage,
    String? oldImageUrl,
  ) async {
    final String UID = FirebaseAuth.instance.currentUser!.uid;

    String updateImageUrl = networkImage ?? '';

    if (image != null) {
      if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
        await deleteImage(oldImageUrl);
      }

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('post_image')
          .child('${UID}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(image);
      updateImageUrl = await storageRef.getDownloadURL();
    } else if ((networkImage == null || networkImage.isEmpty) &&
        oldImageUrl != null &&
        oldImageUrl.isNotEmpty) {
      await deleteImage(oldImageUrl);
    }

    await postCollection.doc(postID).update({
      'content': content,
      'feeling': feeling?.label,
      'emotionUrl': feeling?.imagePath,
      'imageUrl': updateImageUrl,
      'postBy_UID': UID,
      'update_timestamp': FieldValue.serverTimestamp(),
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
      'UID': FirebaseAuth.instance.currentUser!.uid,
      'content': content,
    });

    await postCollection.doc(postID).update({
      'total_comment': FieldValue.increment(1),
    });
  }

  Future<void> newPost(Post post, File? imageFile) async {
    String imageUrl = post.imageUrl ?? '';

    if (imageFile != null) {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('post_image')
          .child('${post.UID}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(imageFile);
      imageUrl = await storageRef.getDownloadURL();
    }

    await postCollection.doc(post.postID).set({
      'content': post.content,
      'create_timestamp': FieldValue.serverTimestamp(),
      'feeling': post.feeling,
      'emotionUrl': post.emotionUrl,
      'imageUrl': imageUrl,
      'postBy_UID': post.UID,
      'total_comment': 0,
      'total_like': 0,
      'update_timestamp': FieldValue.serverTimestamp(),
    });
  }
}
