import 'package:flutter/material.dart';

class JapaneseSearchScreen extends StatefulWidget {
  const JapaneseSearchScreen({super.key});

  @override
  State<JapaneseSearchScreen> createState() => _JapaneseSearchScreenState();
}

class _JapaneseSearchScreenState extends State<JapaneseSearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;
  bool _hasInput = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _hasInput = _searchController.text.isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Container(
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFF1F3F4),
            borderRadius: BorderRadius.circular(24),
          ),
          child: TextField(
            controller: _searchController,
            autofocus: false,
            decoration: InputDecoration(
              hintText: 'Tra từ vựng, Kanji, ngữ pháp, romaji...',
              hintStyle: const TextStyle(fontSize: 14, color: Colors.black45),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF1E88E5)),
              suffixIcon: _hasInput
                  ? IconButton(
                icon: const Icon(Icons.clear, color: Colors.black45, size: 20),
                onPressed: () => _searchController.clear(),
              )
                  : const Icon(Icons.mic, color: Colors.black45),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF1E88E5),
          unselectedLabelColor: Colors.black54,
          indicatorColor: const Color(0xFF1E88E5),
          indicatorWeight: 3,
          tabs: const [
            Tab(text: 'Từ vựng (12)'),
            Tab(text: 'Kanji (3)'),
            Tab(text: 'Ngữ pháp (2)'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildVocabSearchResults(),
          _buildKanjiSearchResults(),
          _buildGrammarSearchResults(),
        ],
      ),
    );
  }

  // --- TAB 1: KẾT QUẢ TỪ VỰNG ---
  Widget _buildVocabSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 5,
      itemBuilder: (context, index) {
        final mockWords = [
          {'kanji': '食べる', 'hira': 'たべる', 'mean': 'Ăn (Hành động nhai nuốt thức ăn)', 'lvl': 'N5'},
          {'kanji': '美味しい', 'hira': 'おいしい', 'mean': 'Ngon, thơm ngon, hấp dẫn', 'lvl': 'N5'},
          {'kanji': '料理', 'hira': 'りょうり', 'mean': 'Món ăn, nấu ăn, ẩm thực', 'lvl': 'N4'},
        ];
        final item = mockWords[index % mockWords.length];

        return Card(
          color: Colors.white,
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 10),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Row(
              children: [
                Text(item['kanji']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
                const SizedBox(width: 10),
                Text('(${item['hira']!})', style: const TextStyle(fontSize: 14, color: Colors.black54)),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.orange.shade400, borderRadius: BorderRadius.circular(4)),
                  child: Text(item['lvl']!, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Text(item['mean']!, style: const TextStyle(fontSize: 14, color: Colors.black87)),
            ),
            trailing: const Icon(Icons.volume_up, color: Colors.black45),
          ),
        );
      },
    );
  }

  // --- TAB 2: KẾT QUẢ KANJI ---
  Widget _buildKanjiSearchResults() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.4,
      ),
      itemCount: 3,
      itemBuilder: (context, index) {
        final mockKanji = [
          {'char': '食', 'han': 'THỰC', 'onyomi': 'ショク', 'kunyomi': 'た.べる', 'mean': 'Ăn, thực phẩm'},
          {'char': '飲', 'han': 'ẨM', 'onyomi': 'イン', 'kunyomi': 'の.む', 'mean': 'Uống, ẩm thực'},
          {'char': '料', 'han': 'LIỆU', 'onyomi': 'リョウ', 'kunyomi': '-', 'mean': 'Nguyên liệu, chi phí'},
        ];
        final item = mockKanji[index];

        return Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Text(item['char']!, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(item['han']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                    const SizedBox(height: 2),
                    Text('Nghĩa: ${item['mean']!}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.black87)),
                    Text('Kun: ${item['kunyomi']!}', maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.black54)),
                  ],
                ),
              )
            ],
          ),
        );
      },
    );
  }

  // --- TAB 3: KẾT QUẢ NGỮ PHÁP ---
  Widget _buildGrammarSearchResults() {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: 2,
      itemBuilder: (context, index) {
        final mockGrammars = [
          {'form': '～たい', 'mean': 'Muốn làm gì đó (Chỉ nguyện vọng bản thân)', 'use': 'V-ます + たい'},
          {'form': '～ながら', 'mean': 'Vừa làm hành động A vừa làm hành động B', 'use': 'V1-ます + ながら + V2'},
        ];
        final item = mockGrammars[index];

        return Card(
          color: Colors.white,
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item['form']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(4)),
                      child: const Text('N5', style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Cấu trúc: ${item['use']!}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black54)),
                const Divider(height: 16),
                Text(item['mean']!, style: const TextStyle(fontSize: 14, color: Colors.black87)),
              ],
            ),
          ),
        );
      },
    );
  }
}