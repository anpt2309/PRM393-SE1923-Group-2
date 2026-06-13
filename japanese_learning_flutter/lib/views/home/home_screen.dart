import 'package:flutter/material.dart';
import '../account/news_screen.dart';
import '../account/sentence_screen.dart';
import '../account/profile_screen.dart';
import '../exam/exam_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 2; // Default to ExamListScreen (Index 2) as requested for the Exam usecase

  // List of screens for the navigation bar
  final List<Widget> _screens = [
    const NewsScreen(),
    const SentenceScreen(),
    const ExamListScreen(),
    const ProfileScreen(),
  ];

  static const Color cobaltBlue = Color(0xFF0D47A1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: cobaltBlue,
        unselectedItemColor: Colors.grey.shade500,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper_outlined),
            activeIcon: Icon(Icons.newspaper, color: cobaltBlue),
            label: 'Tin tức',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book_outlined),
            activeIcon: Icon(Icons.menu_book, color: cobaltBlue),
            label: 'Mẫu câu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            activeIcon: Icon(Icons.assignment, color: cobaltBlue),
            label: 'Đề thi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person, color: cobaltBlue),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}
