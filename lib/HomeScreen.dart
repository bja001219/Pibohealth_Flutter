import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 스페이스바 감지용
import 'quest.dart';
import 'statistic.dart';
import 'start.dart';
import 'ranking.dart';
import 'mypage.dart';
import 'notification.dart'; // 알림 화면으로 이동
import 'notification_data.dart'; // 알림 데이터 리스트

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2; // 시작은 홈 화면
  final FocusNode _focusNode = FocusNode(); // RawKeyboardListener용

  // 알림 후보 목록
  final List<Map<String, dynamic>> possibleNotifications = [
    {
      "title": "금일 일일퀘스트가 깨지지 않았어요!",
      "body": "운동하실 시간이에요!",
    },
    {
      "title": "근육량이 줄고있어요!",
      "body": "운동하실 시간이에요!",
    },
    {
      "title": "저번주의 나보다 뒤쳐지고 있어요!",
      "body": "꾸준함이 답입니다. 함께 운동해요!",
    },
    {
      "title": "오늘의 작은 노력이 큰 변화를 만듭니다!",
      "body": "지금 바로 운동 시작해볼까요?",
    },
    {
      "title": "랭킹이 뒤쳐지고 있어요!",
      "body": "힘내서 오늘도 움직여봐요!",
    },
    {
      "title": "건강은 하루아침에 오지 않아요!",
      "body": "꾸준함이 답입니다. 함께 운동해요!",
    },
    {
      "title": "오늘 하루, 나를 위한 투자 어떠세요?",
      "body": "운동하고 더 나은 내일을 맞이하세요!",
    },
    {
      "title": "지금 멈추면 어제와 같고,",
      "body": "지금 시작하면 내일이 달라져요!",
    },
    {
      "title": "짧은 운동도 소중한 습관이 됩니다!",
      "body": "5분만이라도 몸을 움직여봐요!",
    },
    {
      "title": "운동은 최고의 자기관리입니다!",
      "body": "나를 위해 오늘도 한 세트!",
    },
  ];

  @override
  void initState() {
    super.initState();
    _scheduleDailyNotification(); // 매일 7시 알림 예약
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  // 스페이스바 누르면 랜덤 알림 추가
  void _handleKeyEvent(RawKeyEvent event) {
    if (event.runtimeType == RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space) {
        _addRandomNotification();
      }
    }
  }

  // 랜덤 알림 추가 함수
  void _addRandomNotification() {
    final random = Random();
    final notif = possibleNotifications[random.nextInt(possibleNotifications.length)];
    notifications.add({
      "title": notif["title"],
      "body": notif["body"],
      "isRead": false,
    });
    setState(() {}); // UI 새로고침
  }

  // 매일 저녁 7시 알림 예약
  void _scheduleDailyNotification() {
    final now = DateTime.now();
    DateTime next7PM = DateTime(now.year, now.month, now.day, 19, 0);

    if (now.isAfter(next7PM)) {
      next7PM = next7PM.add(const Duration(days: 1));
    }

    final initialDelay = next7PM.difference(now);

    Timer(initialDelay, () {
      _addRandomNotification();

      Timer.periodic(const Duration(days: 1), (timer) {
        _addRandomNotification();
      });
    });
  }

  // 하단 네비게이션바 탭 이동
  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const QuestScreen()));
        break;
      case 1:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const StatisticPage()));
        break;
      case 2:
        // 현재화면, 아무것도 안함
        break;
      case 3:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const RankingScreen()));
        break;
      case 4:
        Navigator.push(context, MaterialPageRoute(builder: (_) => const MyPageScreen()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    // 읽지 않은 알림 존재하는지 확인
    bool hasUnreadNotifications = notifications.any((notif) => notif['isRead'] == false);

    return RawKeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKey: _handleKeyEvent,
      child: Scaffold(
        backgroundColor: const Color(0xFFF0F8FF),
        appBar: AppBar(
          title: const Text(
            'Pibo Health',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_none, color: Colors.black),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const NotificationScreen()),
                      ).then((_) => setState(() {})); // 알림 읽으면 다시 리프레시
                    },
                  ),
                  if (hasUnreadNotifications)
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/pibo.png', height: 500),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const StartScreen()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF87CEEB),
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 4,
                ),
                child: const Text(
                  'Connect with Pibo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          backgroundColor: const Color(0xFFE0F7FA),
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: '퀘스트'),
            BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '통계'),
            BottomNavigationBarItem(icon: Icon(Icons.home), label: '시작'),
            BottomNavigationBarItem(icon: Icon(Icons.graphic_eq), label: '랭킹'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: '마이'),
          ],
        ),
      ),
    );
  }
}
