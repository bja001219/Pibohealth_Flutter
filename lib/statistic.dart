import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'difference.dart';

class StatisticPage extends StatefulWidget {
  const StatisticPage({super.key});

  @override
  State<StatisticPage> createState() => _StatisticPageState();
}

class _StatisticPageState extends State<StatisticPage> {
  String selectedExercise = 'squat';
  List<Map<String, dynamic>> workoutData = [];

  @override
  void initState() {
    super.initState();
    fetchWorkoutData();
  }

  Future<void> fetchWorkoutData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
    final snapshot = await userDoc.collection(selectedExercise).get();

    final List<Map<String, dynamic>> data = snapshot.docs.map((doc) {
      final docData = doc.data();
      return {
        'date': doc.id,
        'easy_set': docData['easy_set'] ?? 0,
        'normal_set': docData['normal_set'] ?? 0,
        'hard_set': docData['hard_set'] ?? 0,
        'time': docData['time'] ?? 0,
      };
    }).toList();

    data.sort((a, b) => a['date'].compareTo(b['date'])); // 오래된 날짜가 먼저

    setState(() {
      workoutData = data;
    });
  }

  void updateExercise(String exercise) {
    setState(() {
      selectedExercise = exercise;
      workoutData = [];
    });
    fetchWorkoutData();
  }

  List<BarChartGroupData> getBarChartData() {
    final now = DateTime.now();
    final currentMonthData = workoutData.where((entry) {
      final date = DateTime.tryParse(entry['date']);
      return date != null && date.month == now.month && date.year == now.year;
    }).toList();

    currentMonthData.sort((a, b) => a['date'].compareTo(b['date'])); // 오래된 순
    final List<BarChartGroupData> bars = [];

    for (int i = 0; i < currentMonthData.length; i++) {
      final entry = currentMonthData[i];
      final totalReps = (entry['easy_set'] * 8) +
                        (entry['normal_set'] * 12) +
                        (entry['hard_set'] * 15);

      bars.add(BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: totalReps.toDouble(),
            color: Colors.lightBlueAccent,
            width: 16,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
        showingTooltipIndicators: [0],
      ));
    }

    return bars;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final currentMonthData = workoutData.where((entry) {
      final date = DateTime.tryParse(entry['date']);
      return date != null && date.month == now.month && date.year == now.year;
    }).toList();

    currentMonthData.sort((a, b) => a['date'].compareTo(b['date'])); // 오래된 순

    return Scaffold(
      backgroundColor: const Color(0xFFE6F7FF),
      appBar: AppBar(
        title: const Text(
          '📊 운동 통계',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildExerciseButton('스쿼트', 'squat'),
              const SizedBox(width: 10),
              buildExerciseButton('벤치프레스', 'bench'),
              const SizedBox(width: 10),
              buildExerciseButton('데드리프트', 'deadlift'),
            ],
          ),
          const Divider(thickness: 1),
          Expanded(
            child: workoutData.isEmpty
                ? const Center(
                    child: Text(
                      '운동 기록이 없습니다',
                      style: TextStyle(fontSize: 18, color: Colors.black54),
                    ),
                  )
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: workoutData.length,
                    itemBuilder: (context, index) {
                      final entry = workoutData[index];
                      return Card(
                        color: Colors.white,
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          title: Text(
                            entry['date'],
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            '쉬움 ${entry['easy_set']}세트, 보통 ${entry['normal_set']}세트, 어려움 ${entry['hard_set']}세트\n총 시간 ${entry['time']}초',
                            style: const TextStyle(fontSize: 15, color: Colors.black87),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          const SizedBox(height: 20),
          // 바 그래프
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: 250,
              child: BarChart(
                BarChartData(
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(value.toInt().toString(), style: TextStyle(fontSize: 10));
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          int index = value.toInt();
                          if (index >= 0 && index < currentMonthData.length) {
                            return Transform.translate(
                              offset: const Offset(-10, 5),
                              child: Text(
                                currentMonthData[index]['date'].substring(5), // MM-DD 형식
                                style: TextStyle(fontSize: 10),
                              ),
                            );
                          }
                          return Text('');
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: getBarChartData(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DifferenceScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4FC3F7),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                '📈 비교하기',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildExerciseButton(String label, String exerciseType) {
    final isSelected = selectedExercise == exerciseType;
    return ElevatedButton(
      onPressed: () => updateExercise(exerciseType),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blueAccent : Colors.grey.shade300,
        foregroundColor: isSelected ? Colors.white : Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
      child: Text(label),
    );
  }
}
