import 'package:flutter/material.dart';
// Import tất cả các file màn hình của bạn vào đây:
import 'japanese_search_screen.dart';
import 'vocab_study_screen.dart';
import 'kanji_study_screen.dart';
import 'grammar_study_screen.dart';

class TempMenuScreen extends StatelessWidget {
  const TempMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Thử Nghiệm Giao Diện', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E88E5),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text('Bấm vào từng mục để xem giao diện:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54)),
          ),
          _buildMenuButton(context, '1. Giao diện Tra cứu & Tìm kiếm', const JapaneseSearchScreen(), Colors.blue),
          _buildMenuButton(context, '2. Giao diện Học từ mới (Flashcard)', const VocabStudyScreen(), Colors.green),
          _buildMenuButton(context, '3. Giao diện Kho chữ Kanji', const KanjiStudyScreen(), Colors.redAccent),
          _buildMenuButton(context, '4. Giao diện Ngữ pháp chuyên sâu', const GrammarStudyScreen(), Colors.orange),
        ],
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, String title, Widget targetScreen, Color color) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(backgroundColor: color.withValues(alpha: 0.1), child: Icon(Icons.layers, color: color)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.black38),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => targetScreen));
        },
      ),
    );
  }
}