import 'package:flutter/material.dart';

class KanjiStudyScreen extends StatefulWidget {
  const KanjiStudyScreen({super.key});

  @override
  State<KanjiStudyScreen> createState() => _KanjiStudyScreenState();
}

class _KanjiStudyScreenState extends State<KanjiStudyScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final List<Map<String, dynamic>> _kanjiN5List = [
    {'char': '日', 'han': 'NHẬT', 'mean': 'Ngày, mặt trời', 'strokes': 4},
    {'char': '本', 'han': 'BẢN', 'mean': 'Gốc, sách', 'strokes': 5},
    {'char': '人', 'han': 'NHÂN', 'mean': 'Người', 'strokes': 2},
    {'char': '月', 'han': 'NGUYỆT', 'mean': 'Tháng, mặt trăng', 'strokes': 4},
    {'char': '火', 'han': 'HỎA', 'mean': 'Lửa', 'strokes': 4},
    {'char': '水', 'han': 'THỦY', 'mean': 'Nước', 'strokes': 4},
    {'char': '木', 'han': 'MỘC', 'mean': 'Cây', 'strokes': 4},
    {'char': '金', 'han': 'KIM', 'mean': 'Vàng, tiền', 'strokes': 8},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Kho Chữ Kanji', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: const Color(0xFF1E88E5),
          unselectedLabelColor: Colors.black54,
          indicatorColor: const Color(0xFF1E88E5),
          tabs: const [
            Tab(text: 'N5 (8)'), Tab(text: 'N4'), Tab(text: 'N3'), Tab(text: 'N2'), Tab(text: 'N1'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildKanjiGrid(_kanjiN5List),
          const Center(child: Text('Dữ liệu Kanji N4 đang cập nhật')),
          const Center(child: Text('Dữ liệu Kanji N3 đang cập nhật')),
          const Center(child: Text('Dữ liệu Kanji N2 đang cập nhật')),
          const Center(child: Text('Dữ liệu Kanji N1 đang cập nhật')),
        ],
      ),
    );
  }

  Widget _buildKanjiGrid(List<Map<String, dynamic>> kanjiList) {
    return GridView.builder(
      padding: const EdgeInsets.all(14),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.85,
      ),
      itemCount: kanjiList.length,
      itemBuilder: (context, index) {
        final item = kanjiList[index];
        return GestureDetector(
          onTap: () => _showKanjiDetailBottomSheet(item),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(item['char']!, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(item['han']!, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                const SizedBox(height: 2),
                Text(item['mean']!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.black54)),
              ],
            ),
          ),
        );
      },
    );
  }

  // BottomSheet xem nhanh cấu trúc chữ và giả lập ô tập viết như Mazii
  void _showKanjiDetailBottomSheet(Map<String, dynamic> item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(item['char']!, style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
                const SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Âm Hán: ${item['han']!}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                    const SizedBox(height: 4),
                    Text('Số nét: ${item['strokes']} nét', style: const TextStyle(color: Colors.black54)),
                    Text('Thuần Việt: ${item['mean']!}', style: const TextStyle(fontWeight: FontWeight.w500)),
                  ],
                )
              ],
            ),
            const Divider(height: 30),
            const Text('Khung tập viết tay thử nghiệm:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black54)),
            const SizedBox(height: 10),
            // Giả lập ô lưới tập viết
            Center(
              child: Container(
                width: 140, height: 140,
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F3F4),
                  border: Border.all(color: Colors.black12, style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    Center(child: Text(item['char']!, style: TextStyle(fontSize: 70, color: Colors.black.withOpacity(0.08)))),
                    const Center(child: Icon(Icons.edit, color: Colors.black26, size: 36)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}