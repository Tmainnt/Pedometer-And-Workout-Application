import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pedometer_application/models/feeling.dart';
import 'package:pedometer_application/models/post.dart';
import 'package:pedometer_application/models/user.dart';

class FirestoreService {
  static final Map<String, UserModel> _userCache = {};
  final CollectionReference usersCollection = FirebaseFirestore.instance
      .collection('users');

  final CollectionReference postCollection = FirebaseFirestore.instance
      .collection('posts');

  Future<UserModel> getUserData() async {
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser?.uid)
        .get();
    return UserModel.fromFirestore(doc);
  }

  Future<UserModel> getUserDataByUID(String UID) async {
    if (_userCache.containsKey(UID)) {
      return _userCache[UID]!;
    }

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(UID)
        .get();

    final userModel = UserModel.fromFirestore(doc);

    _userCache[UID] = userModel;

    return userModel;
  }

  UserModel? getCachedUser(String UID) {
    return _userCache[UID];
  }

  Future<List<Post>> getPostByUID(String uid) async {
    final QuerySnapshot<Map<String, dynamic>> query = await FirebaseFirestore
        .instance
        .collection('posts')
        .where('postBy_UID', isEqualTo: uid)
        .orderBy('create_timestamp', descending: true)
        .get();

    return query.docs.map((doc) => Post.fromFirestore(doc)).toList();
  }

  Future<List<Post>> getPostsPaginated({DocumentSnapshot? lastDocument}) async {
    Query query = FirebaseFirestore.instance
        .collection('posts')
        .orderBy('create_timestamp', descending: true)
        .limit(5);

    if (lastDocument != null) {
      query = query.startAfterDocument(lastDocument);
    }

    final querySnapshot = await query.get();

    return querySnapshot.docs
        .map(
          (doc) => Post.fromFirestore(
            doc as QueryDocumentSnapshot<Map<String, dynamic>>,
          ),
        )
        .toList();
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

  Stream<List<Post>> getPostStream(int limit) {
    return FirebaseFirestore.instance
        .collection('posts')
        .orderBy('create_timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Post.fromFirestore(doc)).toList(),
        );
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
    if (postID.isEmpty) {
      print('Error: postID is empty');
      return;
    }

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await postCollection.doc(postID).collection('postLiked').doc(uid).set({
      'liked_at': FieldValue.serverTimestamp(),
    });

    await postCollection.doc(postID).update({
      'total_like': FieldValue.increment(1),
    });
  }

  Future<void> unlikePost(String postID) async {
    if (postID.isEmpty) return; // ดักไว้เหมือนกัน

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

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

  Future<void> updateUserProfile({
    required String uid,
    required String name,
    required String bio,
    required int age,
    required int height,
    required int weight,
    File? profileImage,
    File? backgroundImage,
    String? networkProfileImage,
    String? networkBackgroundImage,
    String? oldProfileUrl,
    String? oldBackgroundUrl,
  }) async {
    double bmi = 0;

    if (height > 0) {
      double heightMeter = height / 100;
      bmi = weight / (heightMeter * heightMeter);

      bmi = double.parse(bmi.toStringAsFixed(1));
    }

    String updateProfileUrl = networkProfileImage ?? '';
    String updateBackgroundUrl = networkBackgroundImage ?? '';

    /// ---------------- PROFILE IMAGE ----------------

    if (profileImage != null) {
      if (oldProfileUrl != null && oldProfileUrl.isNotEmpty) {
        await deleteImage(oldProfileUrl);
      }

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_image')
          .child('${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(profileImage);

      updateProfileUrl = await storageRef.getDownloadURL();
    } else if ((networkProfileImage == null || networkProfileImage.isEmpty) &&
        oldProfileUrl != null &&
        oldProfileUrl.isNotEmpty) {
      await deleteImage(oldProfileUrl);
    }

    /// ---------------- BACKGROUND IMAGE ----------------

    if (backgroundImage != null) {
      if (oldBackgroundUrl != null && oldBackgroundUrl.isNotEmpty) {
        await deleteImage(oldBackgroundUrl);
      }

      final storageRef = FirebaseStorage.instance
          .ref()
          .child('background_image')
          .child('${uid}_${DateTime.now().millisecondsSinceEpoch}.jpg');

      await storageRef.putFile(backgroundImage);

      updateBackgroundUrl = await storageRef.getDownloadURL();
    } else if ((networkBackgroundImage == null ||
            networkBackgroundImage.isEmpty) &&
        oldBackgroundUrl != null &&
        oldBackgroundUrl.isNotEmpty) {
      await deleteImage(oldBackgroundUrl);
    }

    /// ---------------- UPDATE FIRESTORE ----------------

    await FirebaseFirestore.instance.collection('users').doc(uid).update({
      'user_name': name,
      'user_bio': bio,
      'user_age': age,
      'user_height': height,
      'user_weight': weight,
      'user_BMI': bmi,
      'user_photoUrl': updateProfileUrl,
      'user_background_ImageUrl': updateBackgroundUrl,
    });
  }
}
