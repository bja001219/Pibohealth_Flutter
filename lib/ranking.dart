import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  List<Map<String, dynamic>> topUsers = [];
  int? myRank;
  List<String> availableGroups = [];
  String? selectedGroup;

  @override
  void initState() {
    super.initState();
    loadGroups();
  }

  Future<void> loadGroups() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
    final userData = userDoc.data() ?? {};

    // 그룹 필터링: "group"으로 시작하는 key만 추출
    final groups = userData.keys.where((key) => key.startsWith("group")).map((key) => userData[key]).whereType<String>().toList();

    setState(() {
      availableGroups = groups;
      if (groups.isNotEmpty) {
        selectedGroup = groups.first;
        fetchTopUsers(); // 그룹 로딩 후 랭킹도 바로 보여줌
      }
    });
  }

  Future<void> fetchTopUsers() async {
    if (selectedGroup == null) return;

    final snapshot = await FirebaseFirestore.instance.collection('users').get();
    final currentUser = FirebaseAuth.instance.currentUser;

    final filteredUsers = snapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data.values.contains(selectedGroup); // 해당 그룹에 속해 있는지 확인
    }).map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return {
        'uid': doc.id,
        'name': data['name'] ?? 'Unknown',
        'level': data['level'] ?? 0,
        'exp': data['exp'] ?? 0,
      };
    }).toList();

    filteredUsers.sort((a, b) {
      if (b['level'] != a['level']) {
        return b['level'].compareTo(a['level']);
      } else {
        return b['exp'].compareTo(a['exp']);
      }
    });

    if (currentUser != null) {
      final myUid = currentUser.uid;
      myRank = filteredUsers.indexWhere((user) => user['uid'] == myUid) + 1;
    }

    setState(() {
      topUsers = filteredUsers.take(10).toList();
    });
  }

  Color getMedalColor(int index) {
    if (index == 0) return const Color(0xFFFFD700); // Gold
    if (index == 1) return const Color(0xFFC0C0C0); // Silver
    if (index == 2) return const Color(0xFFCD7F32); // Bronze
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F7FF),
      appBar: AppBar(
        title: const Text(
          '🏆 그룹 랭킹',
          style: TextStyle(color: Colors.black, fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: DropdownButton<String>(
              isExpanded: true,
              value: selectedGroup,
              hint: const Text('그룹 선택'),
              items: availableGroups.map((group) {
                return DropdownMenuItem<String>(
                  value: group,
                  child: Text(group),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedGroup = value;
                  topUsers.clear();
                });
                fetchTopUsers();
              },
            ),
          ),
          Expanded(
            child: topUsers.isEmpty
                ? const Center(child: Text('해당 그룹의 랭킹 데이터를 불러오는 중...'))
                : ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    itemCount: topUsers.length,
                    itemBuilder: (context, index) {
                      final user = topUsers[index];
                      return Card(
                        color: getMedalColor(index),
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          leading: CircleAvatar(
                            backgroundColor: Colors.lightBlueAccent,
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          title: Text(
                            user['name'],
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Level ${user['level']} | Exp ${user['exp']}',
                            style: const TextStyle(fontSize: 14, color: Colors.black87),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (myRank != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '현재 당신의 랭킹은 $myRank위 입니다!',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  if (myRank != 1)
                    const Text(
                      '분발해보세요!',
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
