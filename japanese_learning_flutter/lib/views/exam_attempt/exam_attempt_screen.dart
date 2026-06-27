import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'exam_attempt_controller.dart';
import 'constants/colors.dart';
import 'widgets/question_card.dart';
import 'widgets/options_list.dart';
import 'widgets/question_grid_sheet.dart';

class ExamAttemptScreen extends StatefulWidget {
  final int examId;
  const ExamAttemptScreen({super.key, required this.examId});

  @override
  State<ExamAttemptScreen> createState() => _ExamAttemptScreenState();
}

class _ExamAttemptScreenState extends State<ExamAttemptScreen> {
  late ExamAttemptController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ExamAttemptController(examId: widget.examId);
    _controller.addListener(_onControllerChanged);
    _controller.initExam();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
      // Auto-submit when time is up
      if (_controller.secondsRemaining <= 0 && !_controller.isLoading && _controller.errorMessage == null) {
        _submitExam();
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Thoát phòng thi?', style: TextStyle(color: primaryCobalt, fontWeight: FontWeight.bold)),
        content: const Text('Mọi kết quả thi chưa nộp sẽ bị hủy bỏ. Bạn có muốn thoát?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ở lại')),
          TextButton(
            onPressed: () async {
              await _controller.cancelExamAttempt();
              if (context.mounted) {
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text('Thoát', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }

  void _showSubmitConfirmation() {
    int totalQuestions = _controller.questions.length;
    int answeredCount = _controller.selectedAnswers.length;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Xác nhận nộp bài', style: TextStyle(color: primaryCobalt, fontWeight: FontWeight.bold)),
        content: Text('Bạn đã làm $answeredCount/$totalQuestions câu. Bạn có muốn nộp bài thi ngay bây giờ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: textLight)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _submitExam();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              elevation: 0,
            ),
            child: const Text('Nộp bài'),
          )
        ],
      ),
    );
  }

  Future<void> _submitExam() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: primaryCobalt),
      ),
    );

    try {
      final response = await _controller.submitExam();
      
      if (!mounted) return;
      // Close loading dialog
      Navigator.pop(context);

      final totalScore = response['totalScore'] is num ? (response['totalScore'] as num).toDouble() : 0.0;
      final totalCorrectAnswer = response['totalCorrectAnswer']?.toString() ?? '0/0';
      final totalTime = response['totalTime']?.toString() ?? '00:00';

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 72),
                const SizedBox(height: 16),
                const Text(
                  'Nộp bài thành công!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryCobalt),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Bài thi của bạn đã được ghi nhận trên hệ thống.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: textLight, fontSize: 13),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: bgLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Số câu đúng', style: TextStyle(fontSize: 13, color: textLight)),
                          Text(totalCorrectAnswer, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDark)),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Điểm số', style: TextStyle(fontSize: 13, color: textLight)),
                          Text('$totalScore', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: accentOrange)),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Thời gian làm bài', style: TextStyle(fontSize: 13, color: textLight)),
                          Text(totalTime, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: textDark)),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _controller.clearLocalAnswers();
                      if (context.mounted) {
                        Navigator.pop(context); // Pop dialog
                        context.go('/exams'); // Go back to exam list
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryCobalt,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    child: const Text('Quay lại', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      // Close loading dialog
      Navigator.pop(context);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          title: const Text('Lỗi nộp bài', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          content: Text('Không thể nộp bài lên máy chủ: $e'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            )
          ],
        ),
      );
    }
  }

  void _openQuestionGridBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return QuestionGridBottomSheet(
          partsInfo: _controller.partsInfo,
          activeQuestionIndex: _controller.activeQuestionIndex,
          selectedAnswers: _controller.selectedAnswers,
          onSelectQuestion: (index) {
            _controller.changeQuestion(index);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_controller.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: primaryCobalt),
        ),
      );
    }

    if (_controller.errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: primaryCobalt,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Lỗi tải bài thi',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 64),
                const SizedBox(height: 16),
                Text(
                  'Không thể khởi tạo hoặc tải câu hỏi: ${_controller.errorMessage}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: textDark, fontSize: 16),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _controller.initExam,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryCobalt,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (_controller.questions.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: primaryCobalt,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Bài thi trống',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        body: const Center(
          child: Text('Không có câu hỏi nào cho đề thi này.', style: TextStyle(color: textLight, fontSize: 14)),
        ),
      );
    }

    final activeQuestion = _controller.questions[_controller.activeQuestionIndex];
    final totalQuestions = _controller.questions.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryCobalt,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: _showExitDialog,
        ),
        title: Text(
          _controller.examTitle.isNotEmpty ? _controller.examTitle : 'WT2025T21',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.account_circle, color: Colors.white, size: 26),
          )
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Scrollable Main Content Area
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Question Section Index
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          activeQuestion.title,
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: accentOrange),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: primaryCobalt.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Câu ${activeQuestion.number}/$totalQuestions',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryCobalt),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Question Card Widget
                    QuestionCard(
                      question: activeQuestion,
                      isAudioPlaying: _controller.isAudioPlaying,
                      audioProgress: _controller.audioProgress,
                      audioCurrentSeconds: _controller.audioCurrentSeconds,
                      audioTotalSeconds: _controller.audioTotalSeconds,
                      onToggleAudio: _controller.toggleAudioPlayer,
                    ),
                    const SizedBox(height: 20),

                    // Options List Widget
                    OptionsList(
                      options: activeQuestion.options,
                      selectedOptionIndex: _controller.selectedAnswers[_controller.activeQuestionIndex],
                      onSelectOption: (idx) {
                        _controller.selectAnswer(idx);
                      },
                    ),
                  ],
                ),
              ),
            ),

            // 2. Interactive Bottom Panel (Fixed directly above footer)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  )
                ],
                border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Show Question Grid Text Button
                  GestureDetector(
                    onTap: _openQuestionGridBottomSheet,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Xem danh sách câu hỏi',
                          style: TextStyle(color: primaryCobalt, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.keyboard_arrow_up, color: primaryCobalt, size: 18),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Timer & Submit Button
                  Row(
                    children: [
                      // Timer (Left)
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: bgLight,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade300),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.timer_outlined, color: textDark, size: 16),
                              const SizedBox(width: 6),
                              Text(
                                _controller.formatDuration(_controller.secondsRemaining),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: textDark,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Submit Button (Right)
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: _showSubmitConfirmation,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentOrange,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Nộp bài',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),

            // 3. Bottom Footer Navigation Bar (Fixed at the very bottom)
            Container(
              height: 56,
              color: darkFooter,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Prev Button
                  TextButton.icon(
                    onPressed: _controller.activeQuestionIndex > 0
                        ? () => _controller.changeQuestion(_controller.activeQuestionIndex - 1)
                        : null,
                    icon: const Icon(Icons.arrow_back_ios, size: 12, color: Colors.white),
                    label: const Text('Câu trước', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    style: TextButton.styleFrom(
                      disabledForegroundColor: Colors.white30,
                    ),
                  ),

                  // Next Button
                  TextButton.icon(
                    onPressed: _controller.activeQuestionIndex < totalQuestions - 1
                        ? () => _controller.changeQuestion(_controller.activeQuestionIndex + 1)
                        : null,
                    icon: const Text('Câu tiếp', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    label: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.white),
                    style: TextButton.styleFrom(
                      disabledForegroundColor: Colors.white30,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
