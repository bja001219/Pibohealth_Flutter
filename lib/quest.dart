import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class QuestScreen extends StatefulWidget {
  const QuestScreen({super.key});

  @override
  State<QuestScreen> createState() => _QuestScreenState();
}

class _QuestScreenState extends State<QuestScreen> {
  final String userId = 'YOUR_USER_ID'; // 실제 로그인한 유저 ID로 교체
  late final DateTime startDate;
  late final DateTime endDate;
  Map<String, bool?> questCompletion = {};

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    startDate = DateTime(now.year, now.month, 1);         // 이번 달 1일
    endDate = DateTime(now.year, now.month + 1, 0);       // 이번 달 마지막 날
    _fetchQuestCompletion();
  }

  Future<void> _fetchQuestCompletion() async {
    final now = DateTime.now();
    final firestore = FirebaseFirestore.instance;

    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      final date = startDate.add(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);

      if (date.isAfter(now)) {
        questCompletion[dateStr] = null;
        continue;
      }

      final doc = await firestore
          .collection('users')
          .doc(userId)
          .collection('daily_quest')
          .doc(dateStr)
          .get();

      if (doc.exists && doc.data() != null) {
        questCompletion[dateStr] = doc.data()!['completed'] == true;
      } else {
        questCompletion[dateStr] = false;
      }
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F8FF),
      appBar: AppBar(
        title: const Text('이번 달 퀘스트', style: TextStyle(fontSize: 24, color: Colors.black)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: questCompletion.length,
        itemBuilder: (context, index) {
          final dateStr = DateFormat('yyyy-MM-dd').format(startDate.add(Duration(days: index)));
          final status = questCompletion[dateStr];

          Icon icon;
          if (status == true) {
            icon = const Icon(Icons.check_circle, color: Colors.green);
          } else if (status == false) {
            icon = const Icon(Icons.cancel, color: Colors.red);
          } else {
            icon = const Icon(Icons.circle_outlined, color: Colors.grey);
          }

          return ListTile(
            leading: Text(
              dateStr,
              style: const TextStyle(
                fontSize: 22,           // 🔥 날짜 글자 크게!
                fontWeight: FontWeight.bold, // (선택) 굵게
              ),
            ),
            trailing: icon,
          );
        },
      ),
    );
  }
}
