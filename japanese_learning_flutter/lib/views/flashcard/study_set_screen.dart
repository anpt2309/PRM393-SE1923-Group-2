import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/flashcard_provider.dart';
import '../../providers/app_setting_provider.dart';
import '../../data/models/flashcard.dart';

class StudySetScreen extends ConsumerStatefulWidget {
  final int userId;
  final int setId;
  final String setName;
  final int cardCount;

  const StudySetScreen({
    super.key,
    required this.userId,
    required this.setId,
    required this.setName,
    required this.cardCount,
  });

  @override
  ConsumerState<StudySetScreen> createState() => _StudySetScreenState();
}

class _StudySetScreenState extends ConsumerState<StudySetScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentIndex = 0;
  bool _showMeaning = false;
  bool _isLoading = true;

  List<Flashcard> _displayCards = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    Future.microtask(() => _loadCards());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadCards() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final provider = ref.read(flashcardProvider);
    await provider.loadFlashcards(widget.setId);
    if (mounted) {
      setState(() {
        _displayCards = List.from(provider.flashcards);
        _isLoading = false;
      });
    }
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
    });
  }

  void _resetOrder() async {
    await _loadCards();
    if (mounted) {
      setState(() {
        _currentIndex = 0;
        _showMeaning = false;
      });
    }
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('🎉 Hoàn thành!'),
        content: Text(
          'Bạn đã học xong bộ "${widget.setName}" với ${_displayCards.length} thẻ.',
        ),
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
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
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
      '/flashcards/${widget.setId}/quiz',
      extra: {
        'userId': widget.userId,
        'setId': widget.setId,
        'setName': widget.setName,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingProvider);
    final isDark = settings.isDarkMode;

    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.grey[50];
    final appBarColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFF1E88E5);
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
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
        backgroundColor: appBarColor,
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
              PopupMenuItem(
                value: 'shuffle',
                child: Row(
                  children: [
                    Icon(Icons.shuffle, size: 20, color: isDark ? Colors.white70 : Colors.black87),
                    const SizedBox(width: 8),
                    Text('Xào bài', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'reset',
                child: Row(
                  children: [
                    Icon(Icons.restore, size: 20, color: isDark ? Colors.white70 : Colors.black87),
                    const SizedBox(width: 8),
                    Text('Khôi phục thứ tự', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _displayCards.isEmpty
          ? _buildEmptyState(isDark)
          : TabBarView(
        controller: _tabController,
        children: [
          _buildStudyTab(isDark),
          _buildWordListTab(isDark),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.credit_card_off, size: 64, color: isDark ? Colors.grey[700] : Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Không có thẻ nào trong bộ này',
            style: TextStyle(fontSize: 16, color: isDark ? Colors.white60 : Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _loadCards,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E88E5),
            ),
            child: const Text('Tải lại'),
          ),
        ],
      ),
    );
  }

  // Tab 1: Học thẻ
  Widget _buildStudyTab(bool isDark) {
    final currentCard = _displayCards[_currentIndex];
    final progress = ((_currentIndex + 1) / _displayCards.length * 100).round();
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF333333);

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
                  backgroundColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200],
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
                  color: cardColor,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.15),
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
                                    color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
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
                                  currentCard.front,
                                  style: TextStyle(
                                    fontSize: 48,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ] else ...[
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withValues(alpha: 0.1),
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
                                  currentCard.back,
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.w600,
                                    color: textColor,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                if (currentCard.note.isNotEmpty) ...[
                                  const SizedBox(height: 32),
                                  Divider(color: isDark ? Colors.white10 : Colors.grey[300]),
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.orange.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'Ghi chú',
                                      style: TextStyle(
                                        color: Colors.orange,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    currentCard.note,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: isDark ? Colors.white70 : const Color(0xFF555555),
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
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
                          color: isDark ? Colors.white30 : Colors.grey[400],
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
  Widget _buildWordListTab(bool isDark) {
    final textColor = isDark ? Colors.white : const Color(0xFF333333);
    final subTextColor = isDark ? Colors.white60 : Colors.grey[600];

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
                  color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
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
                    _displayCards.sort((a, b) => a.front.compareTo(b.front));
                  });
                },
                icon: const Icon(Icons.sort_by_alpha, size: 18),
                label: const Text('Sắp xếp'),
                style: TextButton.styleFrom(
                  foregroundColor: subTextColor,
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
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? Colors.black.withValues(alpha: 0.2) : Colors.grey.withValues(alpha: 0.05),
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
                              color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
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
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  card.front,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                if (card.note.isNotEmpty)
                                  Text(
                                    card.note,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark ? Colors.white30 : Colors.grey[400],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 1,
                            child: Text(
                              card.back,
                              style: TextStyle(
                                fontSize: 16,
                                color: isDark ? Colors.white70 : Colors.grey[700],
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.chevron_right,
                            color: isDark ? Colors.white24 : Colors.grey[400],
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
