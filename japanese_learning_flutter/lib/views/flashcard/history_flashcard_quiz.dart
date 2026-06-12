// lib/screens/history_flashcard_quiz.dart
import 'package:flutter/material.dart';

class HistoryFlashcardQuiz extends StatefulWidget {
  final String? setName;
  const HistoryFlashcardQuiz({super.key, this.setName});

  @override
  State<HistoryFlashcardQuiz> createState() => _HistoryFlashcardQuizState();
}

class _HistoryFlashcardQuizState extends State<HistoryFlashcardQuiz> {
  // Dữ liệu lịch sử mẫu
  final List<Map<String, dynamic>> _sampleHistory = [
    {'id': 1, 'setName': 'Từ vựng JLPT N5', 'score': 45, 'total': 50, 'percentage': 90, 'date': 'Hôm nay, 14:30', 'answers': []},
    {'id': 2, 'setName': 'Từ vựng JLPT N5', 'score': 38, 'total': 50, 'percentage': 76, 'date': 'Hôm qua, 20:15', 'answers': []},
    {'id': 3, 'setName': 'Động từ thông dụng', 'score': 28, 'total': 35, 'percentage': 80, 'date': '2 ngày trước', 'answers': []},
    {'id': 4, 'setName': 'Từ vựng JLPT N5', 'score': 42, 'total': 50, 'percentage': 84, 'date': '3 ngày trước', 'answers': []},
    {'id': 5, 'setName': 'Màu sắc', 'score': 10, 'total': 12, 'percentage': 83, 'date': '1 tuần trước', 'answers': []},
  ];

  List<Map<String, dynamic>> get _history =>
      widget.setName != null
          ? _sampleHistory.where((h) => h['setName'] == widget.setName).toList()
          : _sampleHistory;

  Color _getColor(int percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 70) return Colors.blue;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  String _getEmoji(int percentage) {
    if (percentage >= 90) return '🎉';
    if (percentage >= 70) return '👍';
    if (percentage >= 50) return '💪';
    return '📚';
  }

  @override
  Widget build(BuildContext context) {
    final history = _history;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          widget.setName != null ? 'Lịch sử - ${widget.setName}' : 'Lịch sử làm bài',
          style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (history.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep, color: Colors.white),
              onPressed: () => showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Xóa lịch sử'),
                  content: const Text('Bạn có chắc muốn xóa tất cả lịch sử?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã xóa lịch sử (demo)')),
                        );
                      },
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Xóa'),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      body: history.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 80, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('Chưa có lịch sử làm bài', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5)),
              child: const Text('Làm bài kiểm tra'),
            ),
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: history.length,
        itemBuilder: (context, index) {
          final item = history[index];
          final color = _getColor(item['percentage']);
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 8)],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 50, height: 50,
                decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(15)),
                child: Center(child: Text(_getEmoji(item['percentage']), style: const TextStyle(fontSize: 28))),
              ),
              title: Text(item['setName'], style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(item['date'], style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('${item['score']}/${item['total']}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
                  Text('${item['percentage']}%', style: TextStyle(fontSize: 14, color: color)),
                ],
              ),
              onTap: () => _showDetailDialog(item),
            ),
          );
        },
      ),
    );
  }

  void _showDetailDialog(Map<String, dynamic> history) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(history['setName'], style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const Divider(),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDetailItem('Điểm', '${history['score']}/${history['total']}'),
                  _buildDetailItem('Phần trăm', '${history['percentage']}%'),
                  _buildDetailItem('Thời gian', history['date']),
                ],
              ),
              const SizedBox(height: 16),
              const Text('📝 Chi tiết sẽ hiển thị ở đây', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5)),
                child: const Text('Đóng'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
      ],
    );
  }
}