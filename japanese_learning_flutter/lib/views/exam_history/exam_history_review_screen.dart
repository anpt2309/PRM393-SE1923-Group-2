import 'dart:async';
import 'package:flutter/material.dart';

class ReviewQuestion {
  final int number;
  final String title;
  final String questionText;
  final List<String> options;
  final int userSelectedIndex;
  final int correctIndex;
  final String explanation;
  final List<Map<String, String>> comments;

  ReviewQuestion({
    required this.number,
    required this.title,
    required this.questionText,
    required this.options,
    required this.userSelectedIndex,
    required this.correctIndex,
    required this.explanation,
    required this.comments,
  });

  bool get isCorrect => userSelectedIndex == correctIndex;
}

class ExamHistoryReviewScreen extends StatefulWidget {
  const ExamHistoryReviewScreen({super.key});

  @override
  State<ExamHistoryReviewScreen> createState() => _ExamHistoryReviewScreenState();
}

class _ExamHistoryReviewScreenState extends State<ExamHistoryReviewScreen> {
  // Palette Colors
  static const Color primaryCobalt = Color(0xFF1A237E); // Cobalt Blue
  static const Color accentOrange = Color(0xFFFF9800);  // Accent Orange
  static const Color textDark = Color(0xFF0F172A);      // Dark slate accent
  static const Color textLight = Color(0xFF64748B);
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color greenCorrect = Color(0xFF2E7D32);
  static const Color redIncorrect = Color(0xFFC62828);

  // States
  final Set<int> _expandedExplanations = {};
  final Map<int, List<Map<String, String>>> _dynamicComments = {};
  final Map<int, TextEditingController> _commentControllers = {};

  // Mock data of 30 review questions
  late final List<ReviewQuestion> _reviewQuestions;

  @override
  void initState() {
    super.initState();
    _initMockQuestions();
  }

  @override
  void dispose() {
    for (var controller in _commentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _initMockQuestions() {
    // We will generate 30 questions matching the JLPT test format
    _reviewQuestions = List.generate(30, (index) {
      final qNum = index + 1;
      String title = '';
      String questionText = '';
      List<String> options = [];
      int correctIdx = 0;
      int userSelectedIdx = 0;
      String explanationText = '';

      if (qNum <= 10) {
        title = 'Phần 1: Từ vựng (Vocabulary)';
        if (qNum == 1) {
          questionText = 'Chữ Hán của từ "nihon" (Nhật Bản) được viết như thế nào?';
          options = ['A. 日本', 'B. 本日', 'C. 毎日', 'D. 日本語'];
          correctIdx = 0;
          userSelectedIdx = 0; // Correct
          explanationText = 'Chữ "Nhật" (日 - mặt trời) kết hợp với chữ "Bản" (本 - gốc rễ, nguồn gốc) tạo thành "Nhật Bản" (日本 - đất nước mặt trời mọc).';
        } else if (qNum == 2) {
          questionText = 'Cách đọc Hiragana chính xác của chữ Hán "先生" (Giáo viên) là gì?';
          options = ['A. せんせい', 'B. がくせい', 'C. けんせい', 'D. てんせい'];
          correctIdx = 0;
          userSelectedIdx = 1; // Incorrect (selected B: がくせい)
          explanationText = 'Chữ "Tiên" (先 - trước) đọc là せん, chữ "Sinh" (生 - sinh ra) đọc là sei. Hợp lại là せんせい (sensei). Còn がくせい là Học Sinh (学生).';
        } else if (qNum == 3) {
          questionText = 'Chữ Hán "水" (Nước) có âm đọc Kunyomi là gì?';
          options = ['A. みず', 'B. おかね', 'C. つくえ', 'D. いす'];
          correctIdx = 0;
          userSelectedIdx = 0; // Correct
          explanationText = 'Âm đọc thuần Nhật (Kunyomi) của chữ 水 (Thủy) là みず (mizu). Âm Onyomi đọc là すい trong từ 水泳 (swimming - すいえい).';
        } else {
          questionText = 'Từ vựng Kanji tương ứng cho câu hỏi số $qNum';
          options = ['A. Đáp án đúng', 'B. Đáp án nhiễu 1', 'C. Đáp án nhiễu 2', 'D. Đáp án nhiễu 3'];
          correctIdx = 0;
          userSelectedIdx = (qNum % 3 == 0) ? 1 : 0; // Mix correct/incorrect
          explanationText = 'Giải thích chi tiết cho câu hỏi từ vựng số $qNum: Đáp án chính xác là A theo ngữ cảnh ngữ nghĩa trong kỳ thi JLPT N3.';
        }
      } else if (qNum <= 20) {
        title = 'Phần 2: Ngữ pháp & Đọc hiểu';
        if (qNum == 11) {
          questionText = 'Chọn trợ từ thích hợp điền vào chỗ trống:\nわたしは毎日日本語___ 勉強します。';
          options = ['A. を', 'B. が', 'C. に', 'D. で'];
          correctIdx = 0;
          userSelectedIdx = 0; // Correct
          explanationText = 'Trợ từ "を" (wo) chỉ đối tượng trực tiếp tác động của ngoại động từ 勉強します (học).';
        } else if (qNum == 12) {
          questionText = 'Chọn trợ từ thích hợp điền vào chỗ trống:\nここに本___ あります。';
          options = ['A. が', 'B. を', 'C. に', 'D. は'];
          correctIdx = 0;
          userSelectedIdx = 0; // Correct
          explanationText = 'Cấu trúc chỉ sự tồn tại của đồ vật vô tri vô giác: [Địa điểm] に [Vật] が あります. Do đó cần dùng trợ từ "...".';
        } else {
          questionText = 'Cấu trúc ngữ pháp / đoạn văn ngắn số $qNum';
          options = ['A. Đáp án đúng', 'B. Đáp án nhiễu A', 'C. Đáp án nhiễu B', 'D. Đáp án nhiễu C'];
          correctIdx = 0;
          userSelectedIdx = (qNum % 2 == 0) ? 0 : 2; // Mix correct/incorrect
          explanationText = 'Giải thích ngữ pháp câu số $qNum: Dùng trợ từ/công thức liên kết đúng ngữ pháp sơ cấp/trung cấp Nhật ngữ.';
        }
      } else {
        title = 'Phần 3: Nghe hiểu (Listening)';
        questionText = 'Nội dung câu hỏi nghe hiểu số $qNum';
        options = ['A. Đáp án đúng', 'B. Đáp án nhiễu 1', 'C. Đáp án nhiễu 2', 'D. Đáp án nhiễu 3'];
        correctIdx = 0;
        userSelectedIdx = (qNum % 4 == 0) ? 3 : 0; // Mix correct/incorrect
        explanationText = 'Đoạn băng nói về thông tin cuộc hẹn. Từ khóa nằm ở phần sau khi nhân vật nam đồng ý thay đổi kế hoạch sang phương án A.';
      }

      // Default comments
      final initialComments = [
        {'user': 'Linh Trần', 'content': 'Câu này lúc thi em phân vân giữa A và B, may mà chọn đúng.'},
        {'user': 'Minh Nhật', 'content': 'Nhờ phần giải thích rõ ràng này mới vỡ lẽ ra cách dùng trợ từ.'},
      ];

      return ReviewQuestion(
        number: qNum,
        title: title,
        questionText: questionText,
        options: options,
        userSelectedIndex: userSelectedIdx,
        correctIndex: correctIdx,
        explanation: explanationText,
        comments: initialComments,
      );
    });
  }

  // Toggle state helper
  void _toggleExplanation(int index) {
    setState(() {
      if (_expandedExplanations.contains(index)) {
        _expandedExplanations.remove(index);
      } else {
        _expandedExplanations.add(index);
      }
    });
  }

  // Report error dialog
  void _reportError(int questionNumber) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: accentOrange, size: 28),
            SizedBox(width: 8),
            Text('Báo lỗi câu hỏi', style: TextStyle(color: primaryCobalt, fontWeight: FontWeight.bold)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bạn phát hiện sai sót ở câu hỏi số $questionNumber?', style: const TextStyle(fontWeight: FontWeight.w600, color: textDark)),
            const SizedBox(height: 12),
            TextField(
              maxLines: 3,
              style: const TextStyle(fontSize: 13, color: textDark),
              decoration: InputDecoration(
                hintText: 'Nhập chi tiết lỗi (sai đáp án, dịch nghĩa sai, lỗi âm thanh...)',
                hintStyle: const TextStyle(color: textLight, fontSize: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.all(12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: textLight)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã gửi báo cáo lỗi cho câu hỏi số $questionNumber. Cảm ơn bạn!'),
                  backgroundColor: greenCorrect,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: accentOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text('Gửi báo cáo'),
          )
        ],
      ),
    );
  }

  // Dynamic AI Chat Demo sheet
  void _openAIChatDialog(ReviewQuestion question) {
    final List<Map<String, String>> chatMessages = [
      {
        'sender': 'ai',
        'message': 'Xin chào! Mình là AI Sensei 🤖. Mình thấy bạn làm chưa đúng câu hỏi số ${question.number} này.\nBạn có cần mình giải thích tại sao đáp án lại là "${question.options[question.correctIndex]}" thay vì đáp án bạn chọn không?'
      }
    ];

    final TextEditingController textController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: Container(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.7),
                child: Column(
                  children: [
                    // Pull indicator and header
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.psychology, color: primaryCobalt, size: 28),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('AI Sensei - Trợ lý học tập', style: const TextStyle(fontWeight: FontWeight.bold, color: primaryCobalt, fontSize: 15)),
                              Text('Giải đáp câu hỏi số ${question.number}', style: const TextStyle(color: textLight, fontSize: 11)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: textLight),
                          onPressed: () => Navigator.pop(context),
                        )
                      ],
                    ),
                    const Divider(),
                    
                    // Question Reference Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(color: bgLight, borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.grey.shade200)),
                      child: Text(
                        'Q${question.number}: ${question.questionText}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: textDark),
                      ),
                    ),

                    // Chat messages list
                    Expanded(
                      child: ListView.builder(
                        itemCount: chatMessages.length,
                        itemBuilder: (context, index) {
                          final msg = chatMessages[index];
                          final isAI = msg['sender'] == 'ai';

                          return Align(
                            alignment: isAI ? Alignment.centerLeft : Alignment.centerRight,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isAI ? Colors.grey.shade100 : primaryCobalt.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(12),
                                  topRight: const Radius.circular(12),
                                  bottomLeft: isAI ? Radius.zero : const Radius.circular(12),
                                  bottomRight: isAI ? const Radius.circular(12) : Radius.zero,
                                ),
                                border: isAI ? Border.all(color: Colors.grey.shade200) : null,
                              ),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                              child: Text(
                                msg['message']!,
                                style: TextStyle(fontSize: 13, color: isAI ? textDark : primaryCobalt, height: 1.4),
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Send panel
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(color: bgLight, borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.grey.shade300)),
                              child: TextField(
                                controller: textController,
                                style: const TextStyle(fontSize: 13, color: textDark),
                                decoration: const InputDecoration(
                                  hintText: 'Đặt câu hỏi cho AI Sensei...',
                                  hintStyle: TextStyle(fontSize: 12, color: textLight),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          CircleAvatar(
                            backgroundColor: primaryCobalt,
                            radius: 20,
                            child: IconButton(
                              icon: const Icon(Icons.send, color: Colors.white, size: 16),
                              onPressed: () {
                                if (textController.text.trim().isEmpty) return;
                                final userMsg = textController.text.trim();
                                setModalState(() {
                                  chatMessages.add({'sender': 'user', 'message': userMsg});
                                });
                                textController.clear();

                                // Simulate AI reply
                                Timer(const Duration(seconds: 1), () {
                                  setModalState(() {
                                    chatMessages.add({
                                      'sender': 'ai',
                                      'message': 'Cảm ơn câu hỏi của bạn. Để phân tích kỹ hơn:\nTrong câu này, ngữ pháp yêu cầu sự tương hợp trực tiếp. Đáp án "${question.options[question.correctIndex]}" là cấu trúc chuẩn N3, trong khi đáp án của bạn chưa tạo ra ngữ nghĩa chính xác. Bạn nên lưu ý lặp lại cấu trúc này ở phần luyện tập nhé!'
                                    });
                                  });
                                });
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Comments Popup Dialog
  void _showCommentsPopup(int index) {
    final question = _reviewQuestions[index];
    
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final commentList = _dynamicComments[index] ?? question.comments;
            if (!_commentControllers.containsKey(index)) {
              _commentControllers[index] = TextEditingController();
            }
            final controller = _commentControllers[index]!;

            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Row(
                children: [
                  const Icon(Icons.chat_bubble_outline, color: primaryCobalt, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bình luận (Câu ${question.number})',
                      style: const TextStyle(color: primaryCobalt, fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.45),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Question text preview
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(color: bgLight, borderRadius: BorderRadius.circular(8)),
                      child: Text(
                        question.questionText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: textLight),
                      ),
                    ),
                    
                    // Comments list
                    Expanded(
                      child: commentList.isEmpty
                          ? const Center(
                              child: Text('Chưa có bình luận nào.', style: TextStyle(color: textLight, fontSize: 13)),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              itemCount: commentList.length,
                              itemBuilder: (context, cIdx) {
                                final c = commentList[cIdx];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: primaryCobalt.withValues(alpha: 0.1),
                                        radius: 12,
                                        child: Text(
                                          c['user']![0],
                                          style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: primaryCobalt),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(c['user']!, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textDark)),
                                            const SizedBox(height: 2),
                                            Text(c['content']!, style: const TextStyle(fontSize: 12, color: textDark)),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                    const Divider(height: 16),
                    
                    // Input row
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 38,
                            decoration: BoxDecoration(
                              color: bgLight,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: TextField(
                              controller: controller,
                              style: const TextStyle(fontSize: 12, color: textDark),
                              decoration: const InputDecoration(
                                hintText: 'Nhập bình luận...',
                                hintStyle: TextStyle(fontSize: 11, color: textLight),
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        SizedBox(
                          height: 38,
                          child: ElevatedButton(
                            onPressed: () {
                              if (controller.text.trim().isEmpty) return;
                              final commentText = controller.text.trim();
                              
                              setState(() {
                                if (!_dynamicComments.containsKey(index)) {
                                  _dynamicComments[index] = List.from(_reviewQuestions[index].comments);
                                }
                                _dynamicComments[index]!.add({
                                  'user': 'Bạn (Học viên)',
                                  'content': commentText,
                                });
                              });
                              
                              setDialogState(() {});
                              controller.clear();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryCobalt,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              elevation: 0,
                            ),
                            child: const Icon(Icons.send, size: 14),
                          ),
                        )
                      ],
                    )
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Đóng', style: TextStyle(color: textLight, fontWeight: FontWeight.bold)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Stats calculation
    int totalQuestions = _reviewQuestions.length;
    int correctCount = _reviewQuestions.where((q) => q.isCorrect).length;
    double score = (correctCount / totalQuestions) * 180; // 180 score scale
    double completionRate = correctCount / totalQuestions;

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: primaryCobalt,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Kết Quả Bài Thi thử',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: Column(
        children: [
          // Scrollable Body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Top Exam Summary Card
                  _buildSummaryCard(correctCount, totalQuestions, score, completionRate),
                  const SizedBox(height: 24),

                  // Header of list
                  const Row(
                    children: [
                      Icon(Icons.list_alt, color: primaryCobalt, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Chi tiết từng câu hỏi',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // 2. Question Review List
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _reviewQuestions.length,
                    itemBuilder: (context, index) {
                      final question = _reviewQuestions[index];
                      return _buildQuestionReviewCard(question, index);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Top Summary widget
  Widget _buildSummaryCard(int correctCount, int totalQuestions, double score, double rate) {
    return Card(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            // Circular score indicator
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 88,
                  height: 88,
                  child: CircularProgressIndicator(
                    value: rate,
                    backgroundColor: Colors.grey.shade100,
                    color: rate >= 0.6 ? greenCorrect : accentOrange,
                    strokeWidth: 8,
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${score.toInt()}',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryCobalt),
                    ),
                    const Text('Điểm', style: TextStyle(fontSize: 10, color: textLight)),
                  ],
                )
              ],
            ),
            const SizedBox(width: 24),

            // Text stats
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'KẾT QUẢ CHUNG',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: accentOrange, letterSpacing: 1.1),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    rate >= 0.6 ? 'Đạt (Chúc mừng!) 🎉' : 'Chưa đạt (Cố gắng nhé)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: rate >= 0.6 ? greenCorrect : redIncorrect,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSummaryStatItem('Đúng', '$correctCount / $totalQuestions'),
                      _buildSummaryStatItem('Thời gian', '45:12'),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10, color: textLight)),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark)),
      ],
    );
  }

  // Question review card widget
  Widget _buildQuestionReviewCard(ReviewQuestion question, int index) {
    final isCorrect = question.isCorrect;
    final isExplExpanded = _expandedExplanations.contains(index);
    final commentList = _dynamicComments[index] ?? question.comments;

    return Card(
      color: Colors.white,
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header of card (Q-number & Correct/Incorrect indicator)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Câu ${question.number}',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: textDark),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isCorrect ? greenCorrect.withValues(alpha: 0.1) : redIncorrect.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isCorrect ? Icons.check_circle : Icons.cancel,
                            size: 14,
                            color: isCorrect ? greenCorrect : redIncorrect,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isCorrect ? 'Chính xác' : 'Sai',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isCorrect ? greenCorrect : redIncorrect,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Question Text
                Text(
                  question.questionText,
                  style: const TextStyle(fontSize: 14, color: textDark, height: 1.4),
                ),
                const SizedBox(height: 16),

                // Options Review
                Column(
                  children: List.generate(question.options.length, (optIdx) {
                    final optionText = question.options[optIdx];
                    final isUserSelected = question.userSelectedIndex == optIdx;
                    final isCorrectAnswer = question.correctIndex == optIdx;

                    Color borderCol = Colors.grey.shade200;
                    Color bgCol = Colors.white;
                    Color textCol = textDark;
                    Widget? suffixIcon;

                    if (isCorrectAnswer) {
                      bgCol = greenCorrect.withValues(alpha: 0.08);
                      borderCol = greenCorrect;
                      textCol = greenCorrect;
                      suffixIcon = const Icon(Icons.check, color: greenCorrect, size: 16);
                    } else if (isUserSelected && !isCorrect) {
                      bgCol = redIncorrect.withValues(alpha: 0.08);
                      borderCol = redIncorrect;
                      textCol = redIncorrect;
                      suffixIcon = const Icon(Icons.close, color: redIncorrect, size: 16);
                    }

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: bgCol,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: borderCol, width: isUserSelected || isCorrectAnswer ? 1.5 : 1.0),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              optionText,
                              style: TextStyle(fontSize: 13, color: textCol, fontWeight: isUserSelected || isCorrectAnswer ? FontWeight.bold : FontWeight.normal),
                            ),
                          ),
                          suffixIcon ?? const SizedBox.shrink(),
                        ],
                      ),
                    );
                  }),
                ),

                // 'Xem lời giải' toggle button
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => _toggleExplanation(index),
                  icon: Icon(
                    isExplExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    size: 16,
                    color: primaryCobalt,
                  ),
                  label: const Text(
                    'Xem lời giải chi tiết',
                    style: TextStyle(color: primaryCobalt, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),

                // Expanded Explanation Panel
                AnimatedSize(
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeInOut,
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.topLeft,
                      heightFactor: isExplExpanded ? 1.0 : 0.0,
                      child: Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(top: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: bgLight,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'LỜI GIẢI CHI TIẾT:',
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: greenCorrect, letterSpacing: 1.0),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              question.explanation,
                              style: const TextStyle(fontSize: 13, color: textDark, height: 1.4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider before Toolbar
          const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9)),

          // Action Toolbar: Báo lỗi, Chat với AI, Bình luận
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Report Error button
                _buildToolbarButton(
                  icon: Icons.error_outline,
                  label: 'Báo lỗi',
                  onTap: () => _reportError(question.number),
                ),
                // AI Tutor button
                _buildToolbarButton(
                  icon: Icons.psychology_outlined,
                  label: 'AI Tutor',
                  onTap: () => _openAIChatDialog(question),
                ),
                // Comments button
                _buildToolbarButton(
                  icon: Icons.chat_bubble_outline,
                  label: 'Bình luận (${commentList.length})',
                  onTap: () => _showCommentsPopup(index),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Icon(icon, size: 16, color: color ?? textLight),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: color ?? textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
