import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'LoginPromptScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyDN0AfvkJk0hsjoabaMwGiak9U_gSvkhN0",
      authDomain: "ent-pibo.firebaseapp.com",
      projectId: "ent-pibo",
      storageBucket: "ent-pibo.appspot.com",
      messagingSenderId: "932388220155",
      appId: "1:932388220155:web:f2663af1503d4333bcd45e",
    ),
  );
  runApp(const PiboHealthApp());
}

class PiboHealthApp extends StatelessWidget {
  const PiboHealthApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pibo Health',
      theme: ThemeData(
        fontFamily: 'Pretendard', // 폰트도 부드러운 걸로 설정 추천
        primaryColor: Colors.lightBlue,
        scaffoldBackgroundColor: Colors.white,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            backgroundColor: const Color(0xFF9DD9F3),
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
      home: LoginPromptScreen(),
    );
  }
}
