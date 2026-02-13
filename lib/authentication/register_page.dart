import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

  Future<void> _signUp() async {
    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar("Password is not same");
      return;
    }

    try {
      final userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      await userCredential.user?.updateDisplayName(_nameController.text.trim());

      print("register successfully");
    } on FirebaseAuthException catch (e) {
      _showSnackBar(e.message ?? "Error happenning");
    }
  }

  Future<void> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      print("Google login successfully");
    } catch (e) {
      print("Error during Google Sign-In: $e");
    _showSnackBar("Error happen: ${e.toString()}");
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "สมัคร",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            "สมาชิก",
                            style: TextStyle(
                              color: Colors.orange,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "สมัครสมาชิกเพื่อเริ่มดูแลสุขภาพ",
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 25),
                      _buildTextField('ชื่อผู้ใช้', _nameController),
                      _buildTextField('อีเมล', _emailController),
                      _buildTextField('รหัสผ่าน', _passwordController, isObscure: true),
                      _buildTextField('ยืนยันรหัสผ่าน', _confirmPasswordController, isObscure: true),

      
                      const SizedBox(height: 25),
      
                      GestureDetector(
                        onTap: _signUp,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 126, 140, 253),
                                Color(0xFFB599FF),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              "สมัครสมาชิก",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                          ),
                        ),
                      ),
      
                      const SizedBox(height: 20),
      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("เป็นสมาชิกแล้ว?"),
                          InkWell(
                            child: const Text(
                              "เข้าสู่ระบบ",
                              style: TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20,),
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(thickness: 1, color: Colors.grey,), 
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Text('or', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.bold),),
                          ),
                          const Expanded(
                            child: Divider(thickness: 1, color: Colors.grey,), 
                          ),
                        ],
                      ),
                      const SizedBox(height: 20,),
                      OutlinedButton(
                        onPressed: _signInWithGoogle, 
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade300),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: Colors.white,
                        ),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                'assets/google_logo.png',
                                height: 24,
                              ),
                              const SizedBox(width: 12,),
                              const Text("ดำเนินการต่อโดยใช้ Google", style: TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                ),)
                            ],
                        ))
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

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isObscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color.fromARGB(255, 138, 137, 137),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isObscure,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 12,
              ),

              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Colors.black, width: 1.2),
              ),

              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  color: const Color.fromARGB(255, 138, 138, 138),
                ),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}
