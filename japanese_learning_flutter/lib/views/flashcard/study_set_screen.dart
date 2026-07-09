// lib/vocab/study_set_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class StudySetScreen extends StatefulWidget {
  final String setName;
  final int cardCount;

  const StudySetScreen({
    super.key,
    required this.setName,
    required this.cardCount,
  });

  @override
  State<StudySetScreen> createState() => _StudySetScreenState();
}

class _StudySetScreenState extends State<StudySetScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;
  bool _showMeaning = false;
  bool _isShuffled = false;

  // Dữ liệu mẫu cho các thẻ
  final List<Map<String, String>> _sampleCards = [
    {
      'word': '食べる',
      'reading': 'たべる',
      'meaning': 'ăn',
      'example': '毎日ご飯を食べます。',
      'exampleMeaning': 'Mỗi ngày tôi ăn cơm.',
    },
    {
      'word': '飲む',
      'reading': 'のむ',
      'meaning': 'uống',
      'example': '水を飲みます。',
      'exampleMeaning': 'Uống nước.',
    },
    {
      'word': '行く',
      'reading': 'いく',
      'meaning': 'đi',
      'example': '学校へ行きます。',
      'exampleMeaning': 'Đi đến trường.',
    },
    {
      'word': '見る',
      'reading': 'みる',
      'meaning': 'xem, nhìn',
      'example': 'テレビを見ます。',
      'exampleMeaning': 'Xem TV.',
    },
    {
      'word': '聞く',
      'reading': 'きく',
      'meaning': 'nghe, hỏi',
      'example': '音楽を聞きます。',
      'exampleMeaning': 'Nghe nhạc.',
    },
    {
      'word': '話す',
      'reading': 'はなす',
      'meaning': 'nói',
      'example': '日本語を話します。',
      'exampleMeaning': 'Nói tiếng Nhật.',
    },
  ];

  late List<Map<String, String>> _displayCards;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _displayCards = List.from(_sampleCards);
    while (_displayCards.length < widget.cardCount) {
      _displayCards.addAll(_sampleCards);
    }
    _displayCards = _displayCards.take(widget.cardCount).toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _nextCard() {
    if (_currentIndex < _displayCards.length - 1) {
      setState(() {
        _currentIndex++;
        _showMeaning = false;
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _previousCard() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _showMeaning = false;
      });
    }
  }

  void _toggleMeaning() {
    setState(() {
      _showMeaning = !_showMeaning;
    });
  }

  void _shuffleCards() {
    setState(() {
      _displayCards.shuffle();
      _currentIndex = 0;
      _showMeaning = false;
      _isShuffled = true;
    });
  }

  void _resetOrder() {
    setState(() {
      _displayCards = List.from(_sampleCards);
      while (_displayCards.length < widget.cardCount) {
        _displayCards.addAll(_sampleCards);
      }
      _displayCards = _displayCards.take(widget.cardCount).toList();
      _currentIndex = 0;
      _showMeaning = false;
      _isShuffled = false;
    });
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🎉 Hoàn thành!'),
        content: Text('Bạn đã học xong bộ "${widget.setName}" với ${_displayCards.length} thẻ.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentIndex = 0;
                _showMeaning = false;
              });
            },
            child: const Text('Học lại'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
            ),
            child: const Text('Về danh sách'),
          ),
        ],
      ),
    );
  }

  void _startQuiz() {
    context.push(
      '/flashcards/${widget.setName}/quiz',
      extra: {
        'setName': widget.setName,
        'cards': _displayCards,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.setName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.quiz, color: Colors.white),
            onPressed: _startQuiz,
            tooltip: 'Bài kiểm tra',
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'shuffle') {
                _shuffleCards();
              } else if (value == 'reset') {
                _resetOrder();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'shuffle',
                child: Row(
                  children: [
                    Icon(Icons.shuffle, size: 20),
                    SizedBox(width: 8),
                    Text('Xào bài'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.restore, size: 20),
                    SizedBox(width: 8),
                    Text('Khôi phục thứ tự'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          labelStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: '📖 Học thẻ'),
            Tab(text: '📋 Danh sách từ'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStudyTab(),
          _buildWordListTab(),
        ],
      ),
    );
  }

  // Tab 1: Học thẻ
  Widget _buildStudyTab() {
    final currentCard = _displayCards[_currentIndex];
    final progress = ((_currentIndex + 1) / _displayCards.length * 100).round();

    return Column(
      children: [
        // Thanh tiến độ
        Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_currentIndex + 1}/${_displayCards.length}',
                    style: const TextStyle(
                      color: Color(0xFF1E88E5),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$progress%',
                    style: const TextStyle(
                      color: Color(0xFF1E88E5),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress / 100,
                  backgroundColor: Colors.grey[200],
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ),

        // Thẻ flashcard
        Expanded(
          child: GestureDetector(
            onTap: _toggleMeaning,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Container(
                key: ValueKey(_showMeaning),
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.15),
                      blurRadius: 20,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (!_showMeaning) ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E88E5).withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Từ vựng',
                                    style: TextStyle(
                                      color: Color(0xFF1E88E5),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  currentCard['word']!,
                                  style: const TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF333333),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (currentCard['reading'] != null && currentCard['reading']!.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    currentCard['reading']!,
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: Colors.grey[500],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ] else ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text(
                                    'Nghĩa',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  currentCard['meaning']!,
                                  style: const TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF333333),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (currentCard['example'] != null && currentCard['example']!.isNotEmpty) ...[
                                  const SizedBox(height: 32),
                                  const Divider(),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Ví dụ',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    currentCard['example']!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF555555),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  if (currentCard['exampleMeaning'] != null && currentCard['exampleMeaning']!.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      currentCard['exampleMeaning']!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[500],
                                        fontStyle: FontStyle.italic,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ],
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        _showMeaning ? '👆 Chạm để xem từ vựng' : '👆 Chạm để xem nghĩa',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Nút điều hướng
        Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _previousCard,
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('Trước'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E88E5),
                    side: const BorderSide(color: Color(0xFF1E88E5)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _nextCard,
                  icon: Icon(
                    _currentIndex == _displayCards.length - 1 ? Icons.check : Icons.arrow_forward,
                    size: 18,
                  ),
                  label: Text(
                    _currentIndex == _displayCards.length - 1 ? 'Hoàn thành' : 'Đã nhớ',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Tab 2: Danh sách từ vựng
  Widget _buildWordListTab() {
    return Column(
      children: [
        // Nút tạo bài kiểm tra
        Container(
          margin: const EdgeInsets.all(16),
          child: ElevatedButton.icon(
            onPressed: _startQuiz,
            icon: const Icon(Icons.quiz, size: 24),
            label: const Text(
              'Tạo bài kiểm tra',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B35),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              minimumSize: const Size(double.infinity, 50),
            ),
          ),
        ),

        // Thông tin số lượng từ
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_displayCards.length} từ vựng',
                  style: const TextStyle(
                    color: Color(0xFF1E88E5),
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _displayCards.sort((a, b) => a['word']!.compareTo(b['word']!));
                  });
                },
                icon: const Icon(Icons.sort_by_alpha, size: 18),
                label: const Text('Sắp xếp'),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Danh sách từ vựng
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _displayCards.length,
            itemBuilder: (context, index) {
              final card = _displayCards[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      // Chuyển đến tab học và hiển thị thẻ này
                      _tabController.animateTo(0);
                      setState(() {
                        _currentIndex = index;
                        _showMeaning = false;
                      });
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E88E5).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Color(0xFF1E88E5),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  card['word']!,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF333333),
                                  ),
                                ),
                                if (card['reading'] != null && card['reading']!.isNotEmpty)
                                  Text(
                                    card['reading']!,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Text(
                              card['meaning']!,
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[700],
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right,
                            color: Colors.grey[400],
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}