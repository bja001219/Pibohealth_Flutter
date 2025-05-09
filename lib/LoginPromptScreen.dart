import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'HomeScreen.dart';

class LoginPromptScreen extends StatefulWidget {
  const LoginPromptScreen({super.key});

  @override
  State<LoginPromptScreen> createState() => _LoginPromptScreenState();
}

class _LoginPromptScreenState extends State<LoginPromptScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();

  void _signUp() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("회원가입", style: TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField(_nameController, "이름"),
              const SizedBox(height: 10),
              _buildTextField(_emailController, "이메일"),
              const SizedBox(height: 10),
              _buildTextField(_passwordController, "비밀번호", obscureText: true),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final email = _emailController.text.trim();
              final password = _passwordController.text.trim();
              final name = _nameController.text.trim();

              try {
                final userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
                final userId = userCredential.user?.uid;
                if (userId != null) {
                  await _firestore.collection('users').doc(userId).set({
                    'email': email,
                    'name': name,
                    'exp': 0,
                    'level': 1,
                    'total_score': 0,
                  });
                }
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("회원가입 성공!")));
              } on FirebaseAuthException catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("에러: ${e.message}")));
              }
            },
            child: const Text("가입하기"),
          ),
        ],
      ),
    );
  }

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("로그인 실패: ${e.message}")));
    }
  }

  Widget _buildTextField(TextEditingController controller, String hint, {bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '반가워요!\n서비스 사용을 위해\n로그인 또는 회원가입을 해주세요.',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, height: 1.4),
                ),
                const SizedBox(height: 40),
                _buildTextField(_emailController, "이메일"),
                const SizedBox(height: 12),
                _buildTextField(_passwordController, "비밀번호", obscureText: true),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _login,
                  child: const SizedBox(
                    width: double.infinity,
                    child: Center(child: Text('로그인')),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _signUp,
                  child: const SizedBox(
                    width: double.infinity,
                    child: Center(child: Text('회원가입하기')),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
