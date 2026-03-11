import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:pedometer_application/models/community/feeling.dart';
import 'package:pedometer_application/models/community/notification.dart';
import 'package:pedometer_application/models/community/post.dart';
import 'package:pedometer_application/models/community/report.dart';
import 'package:pedometer_application/models/user.dart';
import 'package:pedometer_application/models/workout/exercise_step.dart';
import 'package:pedometer_application/models/workout/workout_category.dart';
import 'package:pedometer_application/models/workout/workouts.dart';

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

  Future<Post?> getOnePostById(String postId) async {
    final doc = await FirebaseFirestore.instance
        .collection("posts")
        .doc(postId)
        .get();

    if (!doc.exists) {
      return null;
    }

    return Post.fromFirestore(doc);
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
      return Center(child: Text('ผิดพลาดในการอ่านข้อมูล ${snapshot.error}'));
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
    if (postID.isEmpty) return;

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await postCollection.doc(postID).collection('postLiked').doc(uid).delete();

    await postCollection.doc(postID).update({
      'total_like': FieldValue.increment(-1),
    });
  }

  Future<void> addComment({
    required String postId,
    required String postOwnerUid,
    required String currentUID,
    required String content,
    File? image,
    String? replyingToCommentId,
    String? replyingToName,
    String? replyingToUid,
  }) async {
    String imageUrl = '';

    if (image != null) {
      final ref = FirebaseStorage.instance
          .ref()
          .child('comment_images')
          .child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(image);
      imageUrl = await ref.getDownloadURL();
    }

    final batch = FirebaseFirestore.instance.batch();

    final commentRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comment')
        .doc();

    batch.set(commentRef, {
      'UID': currentUID,
      'content': content,
      'imageUrl': imageUrl,
      'totalLike': 0,
      'parentCommentId': replyingToCommentId,
      'replyToName': replyingToName,
      'replyToUid': replyingToUid,
      'create_timestamp': FieldValue.serverTimestamp(),
      'update_timestamp': FieldValue.serverTimestamp(),
    });

    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    batch.update(postRef, {'total_comment': FieldValue.increment(1)});

    if (replyingToUid != null) {
      if (replyingToUid != currentUID) {
        final notifRef = FirebaseFirestore.instance
            .collection('users')
            .doc(replyingToUid)
            .collection('notifications')
            .doc();

        batch.set(notifRef, {
          'type': 'reply_comment',
          'senderUID': currentUID,
          'postID': postId,
          'commentID': commentRef.id,
          'message': content,
          'isRead': false,
          'create_timestamp': FieldValue.serverTimestamp(),
        });
      }
    } else {
      if (postOwnerUid != currentUID) {
        final notifRef = FirebaseFirestore.instance
            .collection('users')
            .doc(postOwnerUid)
            .collection('notifications')
            .doc();

        batch.set(notifRef, {
          'type': 'comment_post',
          'senderUID': currentUID,
          'postID': postId,
          'commentID': commentRef.id,
          'message': 'ได้แสดงความคิดเห็นในโพสต์ของคุณ',
          'isRead': false,
          'create_timestamp': FieldValue.serverTimestamp(),
        });
      }
    }

    await batch.commit();
  }

  Future<void> deleteComment(
    String postId,
    String commentId, {
    String? reason,
  }) async {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final batch = FirebaseFirestore.instance.batch();

    final commentRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comment')
        .doc(commentId);

    final commentDoc = await commentRef.get();

    if (commentDoc.exists) {
      final commentData = commentDoc.data() as Map<String, dynamic>;
      final commentOwnerId = commentData['UID'] as String?;
      final commentText = commentData['content'] as String? ?? 'ไม่มีข้อความ';

      if (commentOwnerId != null && commentOwnerId != currentUid) {
        final notifRef = FirebaseFirestore.instance
            .collection('users')
            .doc(commentOwnerId)
            .collection('notifications')
            .doc();

        batch.set(notifRef, {
          'type': 'comment_deleted',
          'reason': reason ?? 'ละเมิดกฎของชุมชน',
          'detail': 'คอมเมนต์ของคุณถูกลบ: "$commentText"',
          'isRead': false,
          'create_timestamp': FieldValue.serverTimestamp(),
          'postId': postId,
        });
      }
    }

    batch.delete(commentRef);

    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    batch.update(postRef, {'total_comment': FieldValue.increment(-1)});

    await batch.commit();
  }

  Future<void> updateComment({
    required String postId,
    required String commentId,
    required String content,
    required String imageUrl,
  }) async {
    await FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comment')
        .doc(commentId)
        .update({'content': content, 'imageUrl': imageUrl});
  }

  Stream<QuerySnapshot> getCommentsStream(String postId) {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comment')
        .orderBy('create_timestamp', descending: false)
        .snapshots();
  }

  Stream<bool> hasUserLikedComment(
    String postId,
    String commentId,
    String currentUid,
  ) {
    return FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comment')
        .doc(commentId)
        .collection('commentLiked')
        .doc(currentUid)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  Future<void> likeComment(
    String postId,
    String commentId,
    String currentUid,
  ) async {
    final batch = FirebaseFirestore.instance.batch();

    final likeRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comment')
        .doc(commentId)
        .collection('commentLiked')
        .doc(currentUid);

    final commentRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comment')
        .doc(commentId);

    batch.set(likeRef, {'create_timestamp': FieldValue.serverTimestamp()});
    batch.update(commentRef, {'total_like': FieldValue.increment(1)});

    await batch.commit();
  }

  Future<void> unlikeComment(
    String postId,
    String commentId,
    String currentUid,
  ) async {
    final batch = FirebaseFirestore.instance.batch();

    final likeRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comment')
        .doc(commentId)
        .collection('commentLiked')
        .doc(currentUid);

    final commentRef = FirebaseFirestore.instance
        .collection('posts')
        .doc(postId)
        .collection('comment')
        .doc(commentId);

    batch.delete(likeRef);
    batch.update(commentRef, {'totalLike': FieldValue.increment(-1)});

    await batch.commit();
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

    await usersCollection.doc(post.UID).update({
      'user_total_post': FieldValue.increment(1),
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

  Future<void> deletePostByAdmin(
    Post post,
    String reason,
    String detail,
  ) async {
    final adminUID = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance
        .collection('posts')
        .doc(post.postID)
        .delete();

    await FirebaseFirestore.instance
        .collection('users')
        .doc(post.UID)
        .collection('notifications')
        .add({
          'type': 'post_deleted',
          'postId': post.postID,
          'reason': reason,
          'detail': detail,
          'deletedBy': adminUID,
          'create_timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        });

    final docRef = FirebaseFirestore.instance.collection('sanctions').doc();
    await docRef.set({
      'type': 'post_deleted',
      'user_UID': post.UID,
      'reason': reason,
      'admin_UID': adminUID,
      'create_timestamp': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<ReportModel>> getReportsStream() {
    return FirebaseFirestore.instance
        .collection('reports')
        .where('status', isEqualTo: 'pending')
        .orderBy('create_timestamp', descending: true)
        .limit(20)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) => ReportModel.fromDoc(doc)).toList();
        });
  }

  void clearUserCache() {
    _userCache.clear();
  }

  void clearUserCacheByUID(String uid) {
    if (_userCache.containsKey(uid)) {
      _userCache.remove(uid);
    }
  }

  Stream<List<NotificationModel>> getNotificationStream() {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .orderBy('create_timestamp', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromFirestore(doc))
              .toList(),
        );
  }

  Future<void> deleteNotification(String notificationId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  Future<void> reportUserAndComment({
    required String reportedUid,
    required String reportedName,
    required String reporterUid,
    required String reporterName,
    required String postId,
    required String commentId,
    required String commentText,
    required String reason,
    required String detail,
  }) async {
    //final reporterUid = FirebaseAuth.instance.currentUser?.uid;
    //if (reporterUid == null) return;

    await FirebaseFirestore.instance.collection('reports').add({
      'type': 'comment_report',
      'reported_uid': reportedUid,
      'reported_name': reportedName,
      'reporter_uid': reporterUid,
      'reportrt_name': reporterName,
      'postId': postId,
      'commentId': commentId,
      'commentText': commentText,
      'reason': reason,
      'detail': detail,
      'status': 'pending',
      'create_timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> banUser({
    required String targetUid,
    required String? reportId,
    required String? reporterId,
    required String? reporterName,
    required String reason,
    required String detail,
    required String adminUid,
  }) async {
    final adminUid = FirebaseAuth.instance.currentUser?.uid;
    if (adminUid == null) return;

    final batch = FirebaseFirestore.instance.batch();

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(targetUid);
    batch.update(userRef, {'is_banned': true});

    final sanctionRef = FirebaseFirestore.instance
        .collection('sanctions')
        .doc();
    batch.set(sanctionRef, {
      'user_UID': targetUid,
      'admin_UID': adminUid,
      'reportBy_UID': reporterId ?? '',
      'reportBy_name': reporterName ?? '',
      'report_id': reportId ?? '',
      'reason': reason,
      'detail': detail,
      'type': 'ban',
      'adminUid': adminUid,
      'create_timestamp': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> unbanUser(String targetUid) async {
    final adminUid = FirebaseAuth.instance.currentUser?.uid;
    if (adminUid == null) return;

    final batch = FirebaseFirestore.instance.batch();

    final userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(targetUid);
    batch.update(userRef, {'is_banned': false});

    final sanctionRef = FirebaseFirestore.instance
        .collection('sanctions')
        .doc();
    batch.set(sanctionRef, {
      'user_UID': targetUid,
      'admin_UID': adminUid,
      'type': 'unban',
      'create_timestamp': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Stream<bool> hasUserFollowed(String targetUid, String currentUid) {
    return FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid)
        .collection('following')
        .doc(targetUid)
        .snapshots()
        .map((snapshot) => snapshot.exists);
  }

  Future<void> followUser(String targetUid, String currentUid) async {
    final batch = FirebaseFirestore.instance.batch();

    final followingRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid)
        .collection('following')
        .doc(targetUid);
    final followerRef = FirebaseFirestore.instance
        .collection('users')
        .doc(targetUid)
        .collection('follower')
        .doc(currentUid);

    final currentUserRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid);
    final targetUserRef = FirebaseFirestore.instance
        .collection('users')
        .doc(targetUid);

    batch.set(followingRef, {'create_timestamp': FieldValue.serverTimestamp()});
    batch.set(followerRef, {'create_timestamp': FieldValue.serverTimestamp()});

    batch.update(currentUserRef, {
      'user_total_following': FieldValue.increment(1),
    });
    batch.update(targetUserRef, {
      'user_total_follower': FieldValue.increment(1),
    });

    await batch.commit();
  }

  Future<void> unfollowUser(String targetUid, String currentUid) async {
    final batch = FirebaseFirestore.instance.batch();

    final followingRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid)
        .collection('following')
        .doc(targetUid);
    final followerRef = FirebaseFirestore.instance
        .collection('users')
        .doc(targetUid)
        .collection('follower')
        .doc(currentUid);
    final currentUserRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid);
    final targetUserRef = FirebaseFirestore.instance
        .collection('users')
        .doc(targetUid);

    batch.delete(followingRef);
    batch.delete(followerRef);

    batch.update(currentUserRef, {
      'user_total_following': FieldValue.increment(-1),
    });
    batch.update(targetUserRef, {
      'user_total_follower': FieldValue.increment(-1),
    });

    await batch.commit();
  }

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<WorkoutCategory>> getCategories() {
    return _db
        .collection('workout_categories')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => WorkoutCategory.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<Workout>> getWorkouts({String? categoryId}) {
    Query query = _db.collection('workouts');
    if (categoryId != null) {
      query = query.where('category_id', isEqualTo: categoryId);
    }
    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map(
            (doc) => Workout.fromFirestore(
              doc.data() as Map<String, dynamic>,
              doc.id,
            ),
          )
          .toList(),
    );
  }

  Stream<List<ExerciseStep>> getExerciseSteps(String workoutId) {
    return _db
        .collection('workouts')
        .doc(workoutId)
        .collection('exercise_steps')
        .orderBy('order')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => ExerciseStep.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }

  Future<void> saveWorkoutToUSerHistory(
    Map<String, dynamic> historyData,
    User user,
  ) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('workout_history')
        .add(historyData);
  }
}
