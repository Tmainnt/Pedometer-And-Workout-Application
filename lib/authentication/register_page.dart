import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pedometer_application/authentication/login_page.dart';
import 'package:pedometer_application/services/user_repository.dart';
import 'package:pedometer_application/utils/show_snack_bar.dart';
import 'package:pedometer_application/widget/auth/auth_devider.dart';
import 'package:pedometer_application/widget/auth/auth_header.dart';
import 'package:pedometer_application/widget/auth/auth_switch_link.dart';
import 'package:pedometer_application/widget/auth/custom_text_field.dart';
import 'package:pedometer_application/widget/auth/google_signin_button.dart';
import 'package:pedometer_application/widget/auth/primary_button.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<StatefulWidget> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final UserRepository _userRepository = UserRepository();

  bool isLoading = false;

  Future<void> _signUp() async {
    setState(() => isLoading = true);

    if (_passwordController.text != _confirmPasswordController.text) {
      showGlobalSnackBar("Password is not same");
      return;
    }

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );
      final user = userCredential.user;

      if (user != null) {
        await _userRepository.saveUser(
          uid: user.uid,
          username: _nameController.text.trim(),
          email: _emailController.text.trim(),
        );

        await userCredential.user?.updateDisplayName(
          _nameController.text.trim(),
        );

        showGlobalSnackBar("register successfully");

        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }

        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
      }
    } on FirebaseAuthException catch (e) {
      showGlobalSnackBar(e.message ?? "Error happenning");
    } finally {
      setState(() => isLoading = false);
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
                        title: "สมัคร",
                        highlightTitle: "สมาชิก",
                        subtitle: "สมัครสมาชิกเพื่อเริ่มดูแลสุขภาพ",
                      ),
                      Column(
                        children: [
                          CustomTextField(
                            label: 'ชื่อผู้ใช้',
                            controller: _nameController,
                          ),
                          CustomTextField(
                            label: 'อีเมล',
                            controller: _emailController,
                          ),
                          CustomTextField(
                            label: 'รหัสผ่าน',
                            controller: _passwordController,
                            isObscure: true,
                          ),
                          CustomTextField(
                            label: 'ยืนยันรหัสผ่าน',
                            controller: _confirmPasswordController,
                            isObscure: true,
                          ),

                          const SizedBox(height: 10),

                          PrimaryButton(
                            text: "สมัครสมาชิก",
                            onTap: _signUp,
                            isLoading: isLoading,
                          ),
                        ],
                      ),

                      AuthSwitchLink(
                        text: 'เป็นสมาชิกอยู่แล้ว?',
                        linkText: 'เข้าสู่ระบบ',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginPage(),
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
