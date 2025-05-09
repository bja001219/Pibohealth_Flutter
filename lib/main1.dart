import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDN0AfvkJk0hsjoabaMwGiak9U_gSvkhN0",
      authDomain: "ent-pibo.firebaseapp.com",
      projectId: "ent-pibo",
      storageBucket: "ent-pibo.firebasestorage.app",
      messagingSenderId: "932388220155",
      appId: "1:932388220155:web:f2663af1503d4333bcd45e",
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Login Test',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const LoginTestPage(),
    );
  }
}

class LoginTestPage extends StatefulWidget {
  const LoginTestPage({super.key});
  @override
  State<LoginTestPage> createState() => _LoginTestPageState();
}

class _LoginTestPageState extends State<LoginTestPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String _message = '';

  Future<void> _signIn() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      setState(() {
        _message = '로그인 성공! 사용자 UID: ${credential.user?.uid}';
      });
    } catch (e) {
      setState(() {
        _message = '로그인 실패: $e';
      });
    }
  }

  Future<void> _signUp() async {
    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      setState(() {
        _message = '회원가입 성공! 사용자 UID: ${credential.user?.uid}';
      });
    } catch (e) {
      setState(() {
        _message = '회원가입 실패: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Firebase Login Test")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: _passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _signIn, child: const Text('로그인')),
            ElevatedButton(onPressed: _signUp, child: const Text('회원가입')),
            const SizedBox(height: 20),
            Text(_message),
          ],
        ),
      ),
    );
  }
}
