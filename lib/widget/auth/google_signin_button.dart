import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pedometer_application/services/user_repository.dart';
import 'package:pedometer_application/utils/show_snack_bar.dart';

class GoogleSigninButton extends StatelessWidget {
  GoogleSigninButton({super.key});

  final UserRepository _userRepository = UserRepository();

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCrefential = await FirebaseAuth.instance
          .signInWithCredential(credential);
      final User? user = userCrefential.user;

      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          await _userRepository.saveUser(
            uid: user.uid,
            username: user.displayName ?? "User_${user.uid.substring(0, 5)}",
            email: user.email ?? "",
          );
          print("บันทึกข้อมูลผู้ใช้ Google รายใหม่สำเร็จ");
        }
      }

      print("Google login successfully");
    } catch (e) {
      print("Error during Google Sign-In: $e");
      showGlobalSnackBar("Error happen: ${e.toString()}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: _signInWithGoogle,
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Colors.grey.shade300),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/google_logo.png', height: 24),
          const SizedBox(width: 12),
          const Text(
            "ดำเนินการต่อโดยใช้ Google",
            style: TextStyle(
              color: Colors.black87,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
