import 'package:flutter/material.dart';

class VocabStudyScreen extends StatefulWidget {
  const VocabStudyScreen({super.key});

  @override
  State<VocabStudyScreen> createState() => _VocabStudyScreenState();
}

class _VocabStudyScreenState extends State<VocabStudyScreen> {
  int _currentIndex = 0;
  bool _showBack = false; // Trạng thái lật thẻ mặt sau

  final List<Map<String, dynamic>> _vocabList = [
    {'word': '図書館', 'hira': 'としょかん', 'kanji': 'ĐỒ THƯ QUÁN', 'mean': 'Thư viện', 'ex': '図書館で本を借ります。', 'ex_mean': 'Tôi mượn sách ở thư viện.'},
    {'word': '自動車', 'hira': 'じどうしゃ', 'kanji': 'TỰ ĐỘNG XA', 'mean': 'Xe ô tô, xe hơi', 'ex': '新しい自動車を買いました。', 'ex_mean': 'Tôi đã mua một chiếc ô tô mới.'},
    {'word': '約束', 'hira': 'やくそく', 'kanji': 'ƯỚC THÚC', 'mean': 'Lời hứa, hẹn gặp', 'ex': '友達と約束があります。', 'ex_mean': 'Tôi có hẹn với bạn bè.'},
  ];

  void _nextCard() {
    if (_currentIndex < _vocabList.length - 1) {
      setState(() {
        _currentIndex++;
        _showBack = false;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chúc mừng! Bạn đã hoàn thành bộ thẻ từ này.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentItem = _vocabList[_currentIndex];
    double progress = (_currentIndex + 1) / _vocabList.length;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Học Từ Mới Flashcard', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Thanh tiến trình học
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.black12,
                    color: const Color(0xFF1E88E5),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(width: 12),
                Text('${_currentIndex + 1}/${_vocabList.length}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 40),

            // THẺ FLASHCARD CHÍNH
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _showBack = !_showBack),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: _showBack
                        ? _buildCardBack(currentItem)
                        : _buildCardFront(currentItem),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),

            // NÚT CHỨC NĂNG (ĐÃ THUỘC / CHƯA THUỘC)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _nextCard,
                    icon: const Icon(Icons.close, color: Colors.white),
                    label: const Text('Chưa thuộc', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _nextCard,
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text('Đã thuộc', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Text('Mẹo: Nhấn vào giữa thẻ để lật xem nghĩa ẩn', style: TextStyle(color: Colors.black45, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFront(Map<String, dynamic> item) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(item['word']!, style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
        const SizedBox(height: 16),
        const Icon(Icons.touch_app_outlined, color: Colors.black26, size: 30),
        const SizedBox(height: 8),
        const Text('Xem nghĩa mặt sau', style: TextStyle(color: Colors.black38, fontSize: 14)),
      ],
    );
  }

  Widget _buildCardBack(Map<String, dynamic> item) {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(item['word']!, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87)),
          Text('「${item['hira']!}」 - Hán Việt: ${item['kanji']!}', style: const TextStyle(fontSize: 16, color: Colors.black54)),
          const Divider(height: 40, thickness: 1),
          const Text('Ý NGHĨA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5), letterSpacing: 1.2)),
          const SizedBox(height: 6),
          Text(item['mean']!, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
          const Divider(height: 40, thickness: 1),
          const Text('VÍ DỤ MINH HỌA', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.orange, letterSpacing: 1.2)),
          const SizedBox(height: 8),
          Text(item['ex']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.black87)),
          const SizedBox(height: 4),
          Text(item['ex_mean']!, style: const TextStyle(fontSize: 14, color: Colors.black54, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }
}