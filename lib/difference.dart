import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class DifferenceScreen extends StatefulWidget {
  const DifferenceScreen({super.key});

  @override
  State<DifferenceScreen> createState() => _DifferenceScreenState();
}

class _DifferenceScreenState extends State<DifferenceScreen> {
  Map<String, String> differenceMessages = {};
  String selectedPeriod = '어제'; // '어제', '저번 주', '한 달 전'

  @override
  void initState() {
    super.initState();
    calculateDifferences();
  }

  Future<void> calculateDifferences() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final exercises = ['squat', 'bench', 'deadlift'];
    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

    final today = DateTime.now();
    final todayStr = "${today.year}-${today.month.toString().padLeft(2, '0')}-${today.day.toString().padLeft(2, '0')}";

    Map<String, String> newMessages = {};

    for (final exercise in exercises) {
      final todayDoc = await userDoc.collection(exercise).doc(todayStr).get();

      int todayTotal = 0;

      if (todayDoc.exists) {
        final data = todayDoc.data()!;
        todayTotal = (data['easy_set'] ?? 0) * 8 +
            (data['normal_set'] ?? 0) * 12 +
            (data['hard_set'] ?? 0) * 15;
      }

      double totalSum = 0;
      int count = 0;

      if (selectedPeriod == '어제') {
        final yesterday = today.subtract(const Duration(days: 1));
        final yesterStr = "${yesterday.year}-${yesterday.month.toString().padLeft(2, '0')}-${yesterday.day.toString().padLeft(2, '0')}";
        final yesterDoc = await userDoc.collection(exercise).doc(yesterStr).get();

        if (yesterDoc.exists) {
          final data = yesterDoc.data()!;
          totalSum = (data['easy_set'] ?? 0) * 8 +
              (data['normal_set'] ?? 0) * 12 +
              (data['hard_set'] ?? 0) * 15;
          count = 1;
        }

      } else {
        final daysBack = selectedPeriod == '저번 주' ? 7 : 30;

        for (int i = 1; i <= daysBack; i++) {
          final day = today.subtract(Duration(days: i));
          final dayStr = "${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}";

          final doc = await userDoc.collection(exercise).doc(dayStr).get();
          if (doc.exists) {
            final data = doc.data()!;
            totalSum += (data['easy_set'] ?? 0) * 8 +
                (data['normal_set'] ?? 0) * 12 +
                (data['hard_set'] ?? 0) * 15;
            count++;
          }
        }
      }

      if (count == 0) {
        newMessages[exercise] = '$selectedPeriod 기록이 없습니다 운동을 꾸준히 해보세요!.';
        continue;
      }

      final pastAvg = (totalSum / count).round();
      final diff = todayTotal - pastAvg;

      if (todayTotal == 0 && pastAvg == 0) {
        newMessages[exercise] = '운동 기록이 없습니다.';
      } else if (diff > 0) {
        newMessages[exercise] = '$selectedPeriod보다 $diff회 더 했어요! 👍 계속 힘내요!';
      } else if (diff < 0) {
        newMessages[exercise] = '$selectedPeriod보다 ${-diff}회 덜 했어요. 😢 조금 더 분발해봐요!';
      } else {
        newMessages[exercise] = '$selectedPeriod과 동일한 횟수를 했어요! 🔁';
      }
    }

    setState(() {
      differenceMessages = newMessages;
    });
  }

  void onPeriodSelected(String period) {
    setState(() {
      selectedPeriod = period;
      differenceMessages.clear();
    });
    calculateDifferences();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text(
          '📊 비교 결과',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // 비교 버튼
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: ['어제', '저번 주', '한 달 전'].map((period) {
                final isSelected = selectedPeriod == period;
                return ElevatedButton(
                  onPressed: () => onPeriodSelected(period),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSelected ? Colors.lightBlueAccent : Colors.grey[300],
                    foregroundColor: isSelected ? Colors.white : Colors.black87,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(period),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            // 결과 카드
            ...['squat', 'bench', 'deadlift'].map((exercise) {
              return Card(
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(
                    exercise.toUpperCase(),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                  ),
                  subtitle: Text(
                    differenceMessages[exercise] ?? '불러오는 중...',
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
