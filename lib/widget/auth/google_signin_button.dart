import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pedometer_application/utils/show_snack_bar.dart';

class GoogleSigninButton extends StatelessWidget {
  const GoogleSigninButton({super.key});

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

      await FirebaseAuth.instance.signInWithCredential(credential);

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
