// lib/vocab/quiz_screen.dart
import 'package:flutter/material.dart';

class QuizScreen extends StatefulWidget {
  final String setName;
  final List<Map<String, String>> cards;

  const QuizScreen({
    super.key,
    required this.setName,
    required this.cards,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _showResult = false;
  String? _selectedAnswer;
  bool _answered = false;

  // Các câu hỏi được tạo từ danh sách thẻ
  late List<Map<String, dynamic>> _questions;

  // Lưu kết quả từng câu
  List<Map<String, dynamic>> _answers = [];

  @override
  void initState() {
    super.initState();
    _generateQuestions();
  }

  void _generateQuestions() {
    _questions = [];
    for (var card in widget.cards) {
      // Tạo câu hỏi dạng: hiển thị từ, chọn nghĩa
      List<String> options = [card['meaning']!];

      // Thêm các đáp án nhiễu từ các thẻ khác
      for (var otherCard in widget.cards) {
        if (otherCard['meaning'] != card['meaning'] && options.length < 4) {
          options.add(otherCard['meaning']!);
        }
      }

      // Nếu chưa đủ 4 đáp án, thêm đáp án mẫu
      while (options.length < 4) {
        options.add('Từ khác');
      }

      // Trộn đáp án
      options.shuffle();

      _questions.add({
        'question': card['word']!,
        'reading': card['reading'] ?? '',
        'correctAnswer': card['meaning']!,
        'options': options,
        'fullData': card,
      });
    }
    // Trộn câu hỏi
    _questions.shuffle();
    _answers = List.filled(_questions.length, {'isCorrect': false, 'selected': ''});
  }

  void _selectAnswer(String answer) {
    if (_answered) return;

    setState(() {
      _selectedAnswer = answer;
      _answered = true;

      final isCorrect = answer == _questions[_currentQuestionIndex]['correctAnswer'];
      if (isCorrect) {
        _score++;
      }

      _answers[_currentQuestionIndex] = {
        'isCorrect': isCorrect,
        'selected': answer,
        'correct': _questions[_currentQuestionIndex]['correctAnswer'],
      };
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      setState(() {
        _showResult = true;
      });
    }
  }

  void _restartQuiz() {
    setState(() {
      _currentQuestionIndex = 0;
      _score = 0;
      _showResult = false;
      _selectedAnswer = null;
      _answered = false;
      _questions.shuffle();
      for (var i = 0; i < _questions.length; i++) {
        // Trộn lại đáp án cho mỗi câu
        final options = _questions[i]['options'] as List;
        options.shuffle();
      }
      _answers = List.filled(_questions.length, {'isCorrect': false, 'selected': ''});
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showResult) {
      return _buildResultScreen();
    }

    final question = _questions[_currentQuestionIndex];
    final progress = ((_currentQuestionIndex + 1) / _questions.length * 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFF1E88E5),
      appBar: AppBar(
        title: const Text(
          'Bài kiểm tra',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Header với tiến độ
          Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Câu ${_currentQuestionIndex + 1}/${_questions.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Điểm: $_score',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: progress / 100,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),

          // Câu hỏi
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
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
                    question['question'],
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (question['reading'] != null && question['reading'].toString().isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      question['reading'],
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  const SizedBox(height: 32),
                  const Text(
                    'Chọn nghĩa đúng:',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Các đáp án
          Container(
            margin: const EdgeInsets.all(20),
            child: Column(
              children: [
                ...List.generate(question['options'].length, (index) {
                  final option = question['options'][index];
                  bool isSelected = _selectedAnswer == option;
                  bool isCorrect = option == question['correctAnswer'];

                  Color? buttonColor;
                  if (_answered) {
                    if (isCorrect) {
                      buttonColor = Colors.green;
                    } else if (isSelected && !isCorrect) {
                      buttonColor = Colors.red;
                    } else {
                      buttonColor = Colors.grey[300];
                    }
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _answered ? null : () => _selectAnswer(option),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor ?? Colors.white,
                        foregroundColor: _answered
                            ? Colors.white
                            : const Color(0xFF333333),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(
                            color: _answered
                                ? buttonColor ?? Colors.transparent
                                : Colors.grey[300]!,
                            width: 1.5,
                          ),
                        ),
                        elevation: _answered ? 0 : 2,
                      ),
                      child: Text(
                        option,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: _answered && isCorrect ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                  );
                }),

                const SizedBox(height: 16),

                // Nút tiếp theo
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _answered ? _nextQuestion : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _answered ? const Color(0xFF1E88E5) : Colors.grey[300],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _currentQuestionIndex == _questions.length - 1 ? 'Xem kết quả' : 'Câu tiếp theo',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultScreen() {
    final percentage = (_score / _questions.length * 100).round();
    String message;
    Color messageColor;

    if (percentage >= 90) {
      message = 'Xuất sắc! 🎉';
      messageColor = Colors.green;
    } else if (percentage >= 70) {
      message = 'Tốt lắm! 👍';
      messageColor = Colors.blue;
    } else if (percentage >= 50) {
      message = 'Cố gắng hơn nhé! 💪';
      messageColor = Colors.orange;
    } else {
      message = 'Hãy học lại bài này! 📚';
      messageColor = Colors.red;
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1E88E5),
      appBar: AppBar(
        title: const Text(
          'Kết quả',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Điểm số
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    '$_score',
                    style: const TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E88E5),
                    ),
                  ),
                  Text(
                    '/ ${_questions.length}',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Thông báo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: [
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: messageColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Bạn đã trả lời đúng $_score/${_questions.length} câu',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  LinearProgressIndicator(
                    value: percentage / 100,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(messageColor),
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Nút hành động
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Về bộ thẻ'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
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
                    onPressed: _restartQuiz,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Làm lại'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF1E88E5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Bảng tổng kết các câu sai
            if (_answers.where((a) => !a['isCorrect']).isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '📝 Các câu trả lời sai:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...List.generate(_questions.length, (index) {
                      if (_answers[index]['isCorrect']) return const SizedBox.shrink();
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _questions[index]['question'],
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Đáp án đúng: ${_answers[index]['correct']}',
                                    style: TextStyle(
                                      color: Colors.green[700],
                                      fontSize: 12,
                                    ),
                                  ),
                                  Text(
                                    'Bạn chọn: ${_answers[index]['selected']}',
                                    style: TextStyle(
                                      color: Colors.red[700],
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.cancel, color: Colors.red),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}