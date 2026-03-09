import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pedometer_application/authentication/register_page.dart';
import 'package:pedometer_application/utils/show_snack_bar.dart';
import 'package:pedometer_application/widget/auth/auth_devider.dart';
import 'package:pedometer_application/widget/auth/auth_header.dart';
import 'package:pedometer_application/widget/auth/auth_switch_link.dart';
import 'package:pedometer_application/widget/auth/custom_text_field.dart';
import 'package:pedometer_application/widget/auth/google_signin_button.dart';
import 'package:pedometer_application/widget/auth/primary_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool isLoading = false;

  Future<void> _signIn() async {
    if (_emailController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      showGlobalSnackBar("กรุณากรอกอีเมลและรหัสผ่าน");
      return;
    }
    setState(() => isLoading = true);

    try {
      final userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final user = userCredential.user;

      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          final userData = userDoc.data() as Map<String, dynamic>;
          final isBanned = userData['is_banned'] ?? false;

          if (isBanned) {
            await FirebaseAuth.instance.signOut();

            if (mounted) {
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (context) => AlertDialog(
                  title: Row(
                    children: const [
                      Icon(Icons.block, color: Colors.red),
                      SizedBox(width: 10),
                      Text(
                        'บัญชีถูกระงับ',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  content: const Text(
                    'บัญชีของคุณถูกระงับการใช้งานเนื่องจากละเมิดกฎของชุมชน\n\nโปรดติดต่อสอบถามได้ที่อีเมล:\nsupport@pedometer.com',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'ตกลง',
                        style: TextStyle(color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              );
            }
            return;
          }
        }
      }

      showGlobalSnackBar("เข้าสู่ระบบสำเร็จ");

      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } on FirebaseAuthException catch (e) {
      showGlobalSnackBar(e.code);
    } catch (e) {
      showGlobalSnackBar("เกิดข้อผิดพลาด: $e");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        body: Stack(
          children: [
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/auth_background.png'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.6),
                    BlendMode.darken,
                  ),
                ),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(25),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Column(
                    spacing: 20,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const AuthHeader(
                        title: "Pedometer & ",
                        highlightTitle: "Workout",
                        subtitle: "ยินดีต้อนรับสู่แอพสุขภาพและการออกกำลังกาย",
                      ),
                      Column(
                        children: [
                          CustomTextField(
                            label: 'อีเมล',
                            controller: _emailController,
                          ),
                          CustomTextField(
                            label: 'รหัสผ่าน',
                            controller: _passwordController,
                            isObscure: true,
                          ),

                          const SizedBox(height: 10),

                          PrimaryButton(
                            text: "เข้าสู่ระบบ",
                            onTap: _signIn,
                            isLoading: isLoading,
                          ),
                        ],
                      ),

                      AuthSwitchLink(
                        text: 'ยังไม่เป็นสมาชิก?',
                        linkText: 'สมัครสมาชิก',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterPage(),
                          ),
                        ),
                      ),

                      AuthDivider(),

                      GoogleSigninButton(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
