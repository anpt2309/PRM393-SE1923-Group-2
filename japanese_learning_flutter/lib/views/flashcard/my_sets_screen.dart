import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/flashcard_provider.dart';
import '../../providers/app_setting_provider.dart';
import '../../data/models/flashcard_set.dart';

class MySetsScreen extends ConsumerStatefulWidget {
  final int userId;

  const MySetsScreen({
    super.key,
    required this.userId,
  });

  @override
  ConsumerState<MySetsScreen> createState() => _MySetsScreenState();
}

class _MySetsScreenState extends ConsumerState<MySetsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  
  // Search state
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

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
    if (cardCount <= 0) return [];
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
    Future.microtask(() => _loadData());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final provider = ref.read(flashcardProvider);
    await provider.loadMySets(widget.userId);
    await provider.loadPublicSets();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  List<FlashcardSet> _filterSets(List<FlashcardSet> sets) {
    if (_searchQuery.isEmpty) return sets;
    return sets.where((set) {
      return set.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
             set.description.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(flashcardProvider);
    final settings = ref.watch(appSettingProvider);
    final isDark = settings.isDarkMode;

    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.grey[50];
    final appBarColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFF1E88E5);
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: _isSearching 
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Tìm kiếm bộ thẻ...',
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.white70),
              ),
              style: const TextStyle(color: Colors.white, fontSize: 18),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            )
          : const Text(
              'Bộ thẻ của tôi',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
        centerTitle: !_isSearching,
        backgroundColor: appBarColor,
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
            icon: Icon(_isSearching ? Icons.close : Icons.search, color: Colors.white),
            onPressed: () {
              setState(() {
                if (_isSearching) {
                  _isSearching = false;
                  _searchQuery = '';
                  _searchController.clear();
                } else {
                  _isSearching = true;
                }
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => context.push(
              '/flashcards/create',
              extra: {'userId': widget.userId},
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
            controller: _tabController,
            children: [
              _buildSetList(_filterSets(provider.mySets), isMySets: true, isDark: isDark),
              _buildSetList(_filterSets(provider.publicSets), isMySets: false, isDark: isDark),
            ],
          ),
    );
  }

  Widget _buildSetList(List<FlashcardSet> sets, {required bool isMySets, required bool isDark}) {
    if (sets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isMySets ? Icons.folder_open : Icons.public_off,
              size: 80,
              color: isDark ? Colors.grey[700] : Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty 
                ? 'Không tìm thấy bộ thẻ nào phù hợp'
                : (isMySets ? 'Bạn chưa có bộ thẻ nào' : 'Chưa có bộ thẻ công khai'),
              style: TextStyle(color: isDark ? Colors.white60 : Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 8),
            if (isMySets && _searchQuery.isEmpty)
              ElevatedButton(
                onPressed: () => context.push(
                  '/flashcards/create',
                  extra: {'userId': widget.userId},
                ),
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

    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sets.length,
        itemBuilder: (context, index) {
          final set = sets[index];
          return _buildSetCard(set, isMySets: isMySets, isDark: isDark);
        },
      ),
    );
  }

  Widget _buildSetCard(FlashcardSet set, {required bool isMySets, required bool isDark}) {
    final cards = _getCardsForSet(set.totalCards);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.white60 : Colors.grey[600];

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.grey.withValues(alpha: 0.1),
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
                    color: const Color(0xFF1E88E5).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    set.isPublic == true ? Icons.public : Icons.lock,
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
                        set.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.style, size: 14, color: isDark ? Colors.grey[500] : Colors.grey[500]),
                          const SizedBox(width: 4),
                          Text(
                            '${set.totalCards} thẻ',
                            style: TextStyle(
                              fontSize: 13,
                              color: subTextColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (isMySets)
                  PopupMenuButton(
                    icon: Icon(Icons.more_vert, color: subTextColor),
                    onSelected: (value) async {
                      if (value == 'edit') {
                        context.push(
                          '/flashcards/edit/${set.id}',
                          extra: {
                            'userId': widget.userId,
                            'setId': set.id,
                            'setName': set.name,
                            'description': set.description,
                            'isPublic': set.isPublic,
                          },
                        );
                      } else if (value == 'delete') {
                        _showDeleteSetDialog(set.id);
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20, color: isDark ? Colors.white70 : Colors.black87),
                            const SizedBox(width: 8),
                            Text('Sửa', style: TextStyle(color: isDark ? Colors.white70 : Colors.black87)),
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
            if (set.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                set.description,
                style: TextStyle(color: subTextColor, fontSize: 14),
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
                      context.push(
                        '/flashcards/${set.id}/study',
                        extra: {
                          'userId': widget.userId,
                          'setId': set.id,
                          'setName': set.name,
                          'cardCount': set.totalCards,
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E88E5).withValues(alpha: 0.15),
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
                              fontWeight: FontWeight.w600,
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
                      context.push(
                        '/flashcards/${set.id}/quiz',
                        extra: {
                          'userId': widget.userId,
                          'setId': set.id,
                          'setName': set.name,
                          'cards': cards,
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF6B35).withValues(alpha: 0.15),
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
                              fontWeight: FontWeight.w600,
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
                      context.push(
                        '/flashcards/${set.id}/quiz/history',
                        extra: {
                          'userId': widget.userId,
                          'setName': set.name,
                          'setId': set.id,
                        },
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.grey[200],
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 16, color: isDark ? Colors.white60 : Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            'Lịch sử',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : Colors.grey[700],
                              fontWeight: FontWeight.w600,
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

  void _showDeleteSetDialog(int setId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa bộ thẻ'),
        content: const Text('Bạn có chắc chắn muốn xóa bộ thẻ này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              final navigator = Navigator.of(context);
              final scaffoldMessenger = ScaffoldMessenger.of(context);
              navigator.pop();
              
              final provider = ref.read(flashcardProvider);
              final success = await provider.deleteSet(
                setId: setId,
                userId: widget.userId,
              );
              
              if (success) {
                await _loadData();
              } else {
                scaffoldMessenger.showSnackBar(
                  SnackBar(
                    content: Text(provider.error ?? 'Xóa thất bại'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}
