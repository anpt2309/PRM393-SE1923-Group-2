// lib/vocab_kanji_grammar/my_sets_screen.dart
import 'package:flutter/material.dart';
import '../flashcard/study_set_screen.dart';
import '../flashcard/quiz_screen.dart';
import '../flashcard/history_flashcard_quiz.dart';

class MySetsScreen extends StatefulWidget {
  const MySetsScreen({super.key});

  @override
  State<MySetsScreen> createState() => _MySetsScreenState();
}

class _MySetsScreenState extends State<MySetsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  // Dữ liệu mẫu cho giao diện
  final List<Map<String, dynamic>> _mySets = [
    {
      'id': '1',
      'name': 'Từ vựng JLPT N5',
      'description': 'Những từ vựng cơ bản nhất cho người mới bắt đầu',
      'cardCount': 50,
      'isPublic': false,
      'createdAt': 'Hôm qua',
    },
    {
      'id': '2',
      'name': 'Động từ thông dụng',
      'description': 'Các động từ hay dùng trong giao tiếp hàng ngày',
      'cardCount': 35,
      'isPublic': false,
      'createdAt': '3 ngày trước',
    },
    {
      'id': '3',
      'name': 'Màu sắc trong tiếng Nhật',
      'description': '',
      'cardCount': 12,
      'isPublic': false,
      'createdAt': '1 tuần trước',
    },
  ];

  final List<Map<String, dynamic>> _publicSets = [
    {
      'id': '4',
      'name': 'Từ vựng gia đình',
      'description': 'Từ vựng về chủ đề gia đình trong tiếng Nhật',
      'cardCount': 28,
      'isPublic': true,
      'createdAt': 'Hôm nay',
      'author': 'Minh Japanese',
    },
    {
      'id': '5',
      'name': 'Thời gian - Ngày tháng',
      'description': 'Cách nói về thời gian, ngày tháng',
      'cardCount': 42,
      'isPublic': true,
      'createdAt': '2 ngày trước',
      'author': 'Hana Sensei',
    },
    {
      'id': '6',
      'name': 'Kanji N5 - Bài 1',
      'description': '15 chữ Kanji cơ bản nhất',
      'cardCount': 15,
      'isPublic': true,
      'createdAt': '5 ngày trước',
      'author': 'Japanese Center',
    },
    {
      'id': '7',
      'name': 'Từ vựng trường học',
      'description': '',
      'cardCount': 30,
      'isPublic': true,
      'createdAt': '1 tuần trước',
      'author': 'StudyJapan',
    },
  ];

  // Dữ liệu mẫu cho các thẻ (để truyền vào quiz)
  final List<Map<String, String>> _sampleCards = [
    {'word': '食べる', 'reading': 'たべる', 'meaning': 'ăn', 'example': '毎日ご飯を食べます。', 'exampleMeaning': 'Mỗi ngày tôi ăn cơm.'},
    {'word': '飲む', 'reading': 'のむ', 'meaning': 'uống', 'example': '水を飲みます。', 'exampleMeaning': 'Uống nước.'},
    {'word': '行く', 'reading': 'いく', 'meaning': 'đi', 'example': '学校へ行きます。', 'exampleMeaning': 'Đi đến trường.'},
    {'word': '見る', 'reading': 'みる', 'meaning': 'xem', 'example': 'テレビを見ます。', 'exampleMeaning': 'Xem TV.'},
    {'word': '聞く', 'reading': 'きく', 'meaning': 'nghe', 'example': '音楽を聞きます。', 'exampleMeaning': 'Nghe nhạc.'},
    {'word': '話す', 'reading': 'はなす', 'meaning': 'nói', 'example': '日本語を話します。', 'exampleMeaning': 'Nói tiếng Nhật.'},
  ];

  List<Map<String, String>> _getCardsForSet(int cardCount) {
    List<Map<String, String>> cards = List.from(_sampleCards);
    while (cards.length < cardCount) {
      cards.addAll(_sampleCards);
    }
    return cards.take(cardCount).toList();
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTab = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Bộ thẻ của tôi',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'Của tôi'),
            Tab(text: 'Công khai'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildSetList(_mySets, isMySets: true),
          _buildSetList(_publicSets, isMySets: false),
        ],
      ),
    );
  }

  Widget _buildSetList(List<Map<String, dynamic>> sets, {required bool isMySets}) {
    if (sets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isMySets ? Icons.folder_open : Icons.public_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              isMySets ? 'Bạn chưa có bộ thẻ nào' : 'Chưa có bộ thẻ công khai',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (isMySets)
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E88E5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('+ Tạo bộ thẻ mới'),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: sets.length,
      itemBuilder: (context, index) {
        final set = sets[index];
        return _buildSetCard(set, isMySets: isMySets);
      },
    );
  }

  Widget _buildSetCard(Map<String, dynamic> set, {required bool isMySets}) {
    final cards = _getCardsForSet(set['cardCount']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E88E5).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    set['isPublic'] == true ? Icons.public : Icons.lock,
                    color: const Color(0xFF1E88E5),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        set['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.style, size: 14, color: Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            '${set['cardCount']} thẻ',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (set['author'] != null) ...[
                            const SizedBox(width: 12),
                            Icon(Icons.person, size: 14, color: Colors.grey[500]),
                            const SizedBox(width: 4),
                            Text(
                              set['author'],
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                if (isMySets)
                  PopupMenuButton(
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                    onSelected: (value) {},
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('Sửa'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, color: Colors.red, size: 20),
                            SizedBox(width: 8),
                            Text('Xóa', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            if (set['description'] != null && set['description'].toString().isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                set['description'],
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            // 3 nút: Học ngay, Bài kiểm tra, Lịch sử
            Row(
              children: [
                // Nút Học ngay
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StudySetScreen(
                            setName: set['name'],
                            cardCount: set['cardCount'],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E88E5).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow, size: 16, color: Color(0xFF1E88E5)),
                          SizedBox(width: 4),
                          Text(
                            'Học',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF1E88E5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Nút Bài kiểm tra
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuizScreen(
                            setName: set['name'],
                            cards: cards,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.quiz, size: 16, color: Color(0xFFFF6B35)),
                          SizedBox(width: 4),
                          Text(
                            'Kiểm tra',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFFF6B35),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Nút Lịch sử
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HistoryFlashcardQuiz(setName: set['name']),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 16, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            'Lịch sử',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}