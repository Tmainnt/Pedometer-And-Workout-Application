import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pedometer_application/authentication/register_page.dart';
import 'package:pedometer_application/utils/show_snack_bar.dart';
import 'package:pedometer_application/widget/auth_devider.dart';
import 'package:pedometer_application/widget/auth_header.dart';
import 'package:pedometer_application/widget/auth_switch_link.dart';
import 'package:pedometer_application/widget/custom_text_field.dart';
import 'package:pedometer_application/widget/google_signin_button.dart';
import 'package:pedometer_application/widget/primary_button.dart';

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
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      showGlobalSnackBar("login successfully");

    } on FirebaseAuthException catch (e) {
      showGlobalSnackBar(e.code);

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
