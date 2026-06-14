import 'package:flutter/material.dart';

class GrammarStudyScreen extends StatefulWidget {
  const GrammarStudyScreen({super.key});

  @override
  State<GrammarStudyScreen> createState() => _GrammarStudyScreenState();
}

class _GrammarStudyScreenState extends State<GrammarStudyScreen> {
  final List<Map<String, dynamic>> _grammarData = [
    {
      'title': '～てください',
      'level': 'N5',
      'formula': 'V-て + ください',
      'meaning': 'Xin hãy làm gì đó... (Mẫu câu cầu khiến lịch sự hoặc ra lệnh nhẹ nhàng).',
      'examples': [
        {'jp': 'ここに名前を書いてください。', 'vn': 'Xin vui lòng viết tên vào đây.'},
        {'jp': 'ちょっと待ってください。', 'vn': 'Xin hãy đợi một chút.'},
      ]
    },
    {
      'title': '～から',
      'level': 'N5',
      'formula': 'Mệnh đề 1 (Thể thông thường/Lịch sự) + から、Mệnh đề 2',
      'meaning': 'Vì... nên... (Giải thích nguyên nhân, lý do).',
      'examples': [
        {'jp': '時間がありませんから、タクシーで行きます。', 'vn': 'Vì không có thời gian nên tôi sẽ đi bằng taxi.'},
      ]
    }
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Cấu Trúc Ngữ Pháp', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black87),
        actions: [
          IconButton(icon: const Icon(Icons.filter_list, color: Color(0xFF1E88E5)), onPressed: () {}),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(14),
        itemCount: _grammarData.length,
        itemBuilder: (context, index) {
          final item = _grammarData[index];
          return Card(
            color: Colors.white,
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ExpansionTile(
              shape: const Border(), // Xóa gạch viền mặc định của ExpansionTile
              title: Row(
                children: [
                  Text(item['title']!, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
                  const SizedBox(width: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.blue.shade50, borderRadius: BorderRadius.circular(4)),
                    child: Text(item['level']!, style: TextStyle(fontSize: 11, color: Colors.blue.shade700, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(item['meaning']!, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: Colors.black54)),
              ),
              childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                const Divider(height: 1),
                const SizedBox(height: 12),
                // Cấu trúc công thức
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: Colors.amber.shade50, borderRadius: BorderRadius.circular(8)),
                  child: Text('Cấu trúc: ${item['formula']!}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.amber.shade900)),
                ),
                const SizedBox(height: 12),
                // Ý nghĩa chi tiết
                const Text('Giải thích ý nghĩa:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 4),
                Text(item['meaning']!, style: const TextStyle(fontSize: 14, color: Colors.black87)),
                const SizedBox(height: 16),

                // Danh sách ví dụ
                const Text('Ví dụ câu mẫu:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.black87)),
                const SizedBox(height: 6),
                ...(item['examples'] as List<Map<String, String>>).map((ex) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1E88E5))),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ex['jp']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
                            Text(ex['vn']!, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                          ],
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          );
        },
      ),
    );
  }
}