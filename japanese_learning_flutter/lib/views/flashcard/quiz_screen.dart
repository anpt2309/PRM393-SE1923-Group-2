import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/flashcard_provider.dart';
import '../../providers/app_setting_provider.dart';
import '../../data/models/flashcard_quiz.dart';

class QuizScreen extends ConsumerStatefulWidget {
  final int userId;
  final int setId;
  final String setName;

  const QuizScreen({
    super.key,
    required this.userId,
    required this.setId,
    required this.setName,
  });

  @override
  ConsumerState<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends ConsumerState<QuizScreen> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  bool _showResult = false;
  String? _selectedAnswer;
  bool _answered = false;
  bool _isLoading = true;
  int _quizId = 0;

  List<Map<String, dynamic>> _questions = [];
  List<Map<String, dynamic>> _answers = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _startQuiz());
  }

  Future<void> _startQuiz() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _questions = [];
      _currentQuestionIndex = 0;
      _score = 0;
      _showResult = false;
      _selectedAnswer = null;
      _answered = false;
    });

    final provider = ref.read(flashcardProvider);

    try {
      await provider.loadFlashcards(widget.setId);
      final cards = provider.flashcards;

      if (cards.isEmpty) {
        if (mounted) setState(() => _isLoading = false);
        return;
      }

      final totalQuestionsCount = cards.length > 20 ? 20 : cards.length;

      final success = await provider.startQuiz(
        userId: widget.userId,
        setId: widget.setId,
        totalQuestion: totalQuestionsCount,
      );

      if (success && mounted) {
        final quiz = provider.currentQuiz;
        if (quiz != null) {
          _quizId = quiz.quizId;
          _generateQuestionsFromQuiz(quiz);
        }
      }
    } catch (e) {
      debugPrint("Quiz Start Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _generateQuestionsFromQuiz(FlashcardQuiz quiz) {
    _questions = [];
    for (var q in quiz.questions) {
      String correctAns = q.correctAnswer ?? "";

      List<String> options = [q.optionA, q.optionB, q.optionC, q.optionD];
      options.removeWhere((element) => element.trim().isEmpty);

      _questions.add({
        'questionId': q.questionId,
        'question': q.question,
        'correctAnswer': correctAns, 
        'options': options,
      });
    }

    _answers = List.generate(_questions.length, (index) => {
      'isCorrect': false,
      'selected': '',
      'questionId': _questions[index]['questionId'],
      'correct': _questions[index]['correctAnswer']
    });
  }

  void _selectAnswer(String answer) {
    if (_answered) return;

    setState(() {
      _selectedAnswer = answer;
      _answered = true;

      final String correctVal = _questions[_currentQuestionIndex]['correctAnswer'].toString().trim().toLowerCase();
      final String selectedVal = answer.trim().toLowerCase();

      bool isCorrect = selectedVal == correctVal;
      
      int idx = _questions[_currentQuestionIndex]['options'].indexOf(answer);
      String label = String.fromCharCode(65 + idx).toLowerCase();
      if (label == correctVal) isCorrect = true;

      if (isCorrect) {
        _score++;
      }

      _answers[_currentQuestionIndex] = {
        'isCorrect': isCorrect,
        'selected': answer,
        'correct': _questions[_currentQuestionIndex]['correctAnswer'],
        'questionId': _questions[_currentQuestionIndex]['questionId'],
        'questionText': _questions[_currentQuestionIndex]['question'],
      };
    });
  }

  Future<void> _nextQuestion() async {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _answered = false;
      });
    } else {
      await _submitQuiz();
    }
  }

  Future<void> _submitQuiz() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    final provider = ref.read(flashcardProvider);

    try {
      final List<Map<String, dynamic>> answerData = [];
      for (var answer in _answers) {
        answerData.add({
          'questionId': answer['questionId'],
          'answer': answer['selected'],
          'isCorrect': answer['isCorrect'],
        });
      }

      final success = await provider.submitQuiz(
        userId: widget.userId,
        quizId: _quizId,
        answers: answerData,
      );

      if (mounted) {
        if (success) {
          setState(() => _showResult = true);
        }
      }
    } catch (e) {
      debugPrint("Submit Error: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingProvider);
    final isDark = settings.isDarkMode;

    final backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    final appBarColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : const Color(0xFF2D3142);

    if (_isLoading) {
      return Scaffold(
        backgroundColor: isDark ? backgroundColor : const Color(0xFF1E88E5),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 24),
              Text(
                'Đang chuẩn bị...',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        backgroundColor: isDark ? backgroundColor : const Color(0xFF1E88E5),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 80, color: Colors.white70),
                const SizedBox(height: 24),
                const Text(
                  'Không tìm thấy câu hỏi!',
                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _startQuiz,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1E88E5),
                  ),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_showResult) return _buildResultScreen(isDark);

    final question = _questions[_currentQuestionIndex];
    final progress = (_currentQuestionIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(widget.setName, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 16)),
        centerTitle: true,
        backgroundColor: appBarColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: isDark ? Colors.white70 : Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
            minHeight: 4,
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // KHU VỰC CÂU HỎI
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
                            blurRadius: 10,
                          )
                        ],
                      ),
                      child: Column(
                        children: [
                          Text('Câu ${_currentQuestionIndex + 1}/${_questions.length}',
                              style: TextStyle(color: isDark ? Colors.white30 : Colors.grey[400], fontWeight: FontWeight.w600, fontSize: 13)),
                          const SizedBox(height: 20),
                          Text(
                            question['question'] ?? '',
                            style: TextStyle(
                              fontSize: (question['question']?.toString().length ?? 0) > 30 ? 24 : 32,
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // DANH SÁCH ĐÁP ÁN
                    Column(
                      children: [
                        ...List.generate(question['options'].length, (index) {
                          final String option = question['options'][index];
                          final String correctVal = question['correctAnswer'].toString().trim().toLowerCase();
                          
                          bool isThisOptionCorrect = option.trim().toLowerCase() == correctVal || 
                                                     String.fromCharCode(65 + index).toLowerCase() == correctVal;
                          bool isThisOptionSelected = _selectedAnswer == option;

                          Color buttonColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
                          Color itemTextColor = isDark ? Colors.white70 : const Color(0xFF4F5D75);
                          Color borderColor = isDark ? Colors.white.withValues(alpha: 0.1) : Colors.grey[200]!;

                          if (_answered) {
                            if (isThisOptionCorrect) {
                              buttonColor = const Color(0xFF4CAF50);
                              itemTextColor = Colors.white;
                              borderColor = const Color(0xFF4CAF50);
                            } else if (isThisOptionSelected) {
                              buttonColor = const Color(0xFFF44336);
                              itemTextColor = Colors.white;
                              borderColor = const Color(0xFFF44336);
                            } else {
                              itemTextColor = isDark ? Colors.white.withValues(alpha: 0.2) : Colors.grey[400]!;
                            }
                          } else if (isThisOptionSelected) {
                            borderColor = const Color(0xFF1E88E5);
                            buttonColor = const Color(0xFF1E88E5).withValues(alpha: 0.05);
                          }

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: InkWell(
                              onTap: _answered ? null : () => _selectAnswer(option),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                                decoration: BoxDecoration(
                                  color: buttonColor,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: borderColor, width: 1.5),
                                ),
                                child: Row(
                                  children: [
                                    Text(String.fromCharCode(65 + index),
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: _answered && (isThisOptionCorrect || isThisOptionSelected)
                                                ? Colors.white : const Color(0xFF1E88E5))),
                                    const SizedBox(width: 12),
                                    Expanded(
                                        child: Text(
                                            option,
                                            style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                                color: itemTextColor
                                            )
                                        )
                                    ),
                                    if (_answered && isThisOptionCorrect)
                                      const Icon(Icons.check_circle, color: Colors.white, size: 20),
                                    if (_answered && isThisOptionSelected && !isThisOptionCorrect)
                                      const Icon(Icons.cancel, color: Colors.white, size: 20),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                        if (_answered)
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _nextQuestion,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF1E88E5),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: Text(
                                _currentQuestionIndex == _questions.length - 1 ? 'Xem kết quả' : 'Tiếp theo',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResultScreen(bool isDark) {
    final percentage = (_score / _questions.length * 100).round();
    final result = ref.watch(flashcardProvider).quizResult;
    final wrongAnswers = _answers.where((a) => !a['isCorrect']).toList();

    final backgroundColor = isDark ? const Color(0xFF121212) : Colors.white;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF8F9FA);
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const SizedBox(height: 30),
              Icon(percentage >= 50 ? Icons.emoji_events : Icons.auto_stories,
                  size: 80, color: percentage >= 50 ? Colors.green : Colors.orange),
              const SizedBox(height: 20),
              Text("Hoàn thành!", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: textColor)),
              const SizedBox(height: 8),
              Text('Bạn đã hoàn thành bài kiểm tra ${widget.setName}',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: isDark ? Colors.white60 : Colors.grey[600])),
              const SizedBox(height: 40),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20)
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatCol('Đúng', '$_score', Colors.green),
                    _buildStatCol('Sai', '${_questions.length - _score}', Colors.red),
                    _buildStatCol('Tỉ lệ', '$percentage%', const Color(0xFF1E88E5)),
                  ],
                ),
              ),
              
              if (result != null) ...[
                const SizedBox(height: 24),
                Text('Điểm tích lũy: +${result.score}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.orange)),
              ],

              if (wrongAnswers.isNotEmpty) ...[
                const SizedBox(height: 32),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Xem lại các câu sai:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white70 : const Color(0xFF2D3142))),
                ),
                const SizedBox(height: 16),
                ...wrongAnswers.map((answer) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark ? Colors.red.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: isDark ? Colors.red.withValues(alpha: 0.2) : Colors.red.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(answer['questionText'] ?? 'Câu hỏi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(Icons.cancel, color: Colors.red, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Bạn chọn: ${answer['selected']}', style: const TextStyle(color: Colors.red, fontSize: 14))),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.green, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Đáp án đúng: ${answer['correct']}', style: const TextStyle(color: Colors.green, fontSize: 14, fontWeight: FontWeight.w600))),
                        ],
                      ),
                    ],
                  ),
                )),
              ],

              const SizedBox(height: 40),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        ref.read(flashcardProvider).clearQuizData();
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        side: isDark ? const BorderSide(color: Colors.white24) : null,
                      ),
                      child: Text('Về trang chủ', style: TextStyle(color: isDark ? Colors.white70 : null)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _startQuiz,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E88E5),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: const Text('Làm lại', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCol(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
      ],
    );
  }
}
