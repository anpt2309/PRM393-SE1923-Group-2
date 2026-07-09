import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/exam_history_detail.dart';
import '../../data/models/comment_response.dart';
import '../../providers/exam_history_provider.dart';

class ExamHistoryReviewScreen extends ConsumerStatefulWidget {
  final int? attemptId;
  const ExamHistoryReviewScreen({super.key, this.attemptId});

  @override
  ConsumerState<ExamHistoryReviewScreen> createState() => _ExamHistoryReviewScreenState();
}

class _ExamHistoryReviewScreenState extends ConsumerState<ExamHistoryReviewScreen> {
  // Palette Colors
  static const Color primaryCobalt = Color(0xFF1A237E); // Cobalt Blue
  static const Color accentOrange = Color(0xFFFF9800);  // Accent Orange
  static const Color textDark = Color(0xFF0F172A);      // Dark slate accent
  static const Color textLight = Color(0xFF64748B);
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color greenCorrect = Color(0xFF2E7D32);
  static const Color redIncorrect = Color(0xFFC62828);

  // TextEditingControllers for comments (local UI state, kept in widget)
  final Map<int, TextEditingController> _commentControllers = {};

  // Shorthand getters — provider parameterized by attemptId
  int get _effectiveAttemptId => widget.attemptId ?? 1;
  ExamHistoryReviewNotifier get _notifier =>
      ref.read(examHistoryReviewProvider(_effectiveAttemptId).notifier);
  ExamHistoryReviewState get _reviewState =>
      ref.watch(examHistoryReviewProvider(_effectiveAttemptId));

  @override
  void initState() {
    super.initState();
    // Không cần gọi gì thêm — provider tự load khi được khởi tạo
  }

  @override
  void dispose() {
    for (var controller in _commentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  // Toggle explanation — gọi notifier thay vì setState
  void _toggleExplanation(int index) {
    _notifier.toggleExplanation(index);
  }

  // Report error dialog
  void _reportError(ReviewQuestion question) {
    final TextEditingController errorTextController = TextEditingController();

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
            Text('Bạn phát hiện sai sót ở câu hỏi số ${question.number}?', style: const TextStyle(fontWeight: FontWeight.w600, color: textDark)),
            const SizedBox(height: 12),
            TextField(
              controller: errorTextController,
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
            onPressed: () async {
              final contentText = errorTextController.text.trim();
              if (contentText.isEmpty) return;

              Navigator.pop(context); // Close the dialog
              
              try {
                await _notifier.createReportQuestion(1, contentText, question.questionId);
                
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã gửi báo cáo lỗi cho câu hỏi số ${question.number}. Cảm ơn bạn!'),
                      backgroundColor: greenCorrect,
                    ),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Phản hồi đã được gửi, vui lòng không spam'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                }
              }
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

  // AI Chat Dialog kết nối API thật
  void _openAIChatDialog(ReviewQuestion question) {
    // Mỗi tin nhắn có 'sender': 'ai'|'user'|'typing', 'message': String
    final List<Map<String, String>> chatMessages = [
      {
        'sender': 'ai',
        'message': 'Xin chào! Mình là AI Sensei 🤖. Bạn có thắc mắc gì về câu hỏi số ${question.number} này không?\nHãy hỏi mình về ngữ pháp, từ vựng hoặc tại sao đáp án là "✓ ${question.options[question.correctIndex]}" nhé!'
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
            final bool isTyping = chatMessages.any((m) => m['sender'] == 'typing');
            final ScrollController scrollController = ScrollController();

            void scrollToBottom() {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (scrollController.hasClients) {
                  scrollController.animateTo(
                    scrollController.position.maxScrollExtent,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                }
              });
            }

            Future<void> handleSend() async {
              final userMsg = textController.text.trim();
              if (userMsg.isEmpty || isTyping) return;

              textController.clear();
              setModalState(() {
                chatMessages.add({'sender': 'user', 'message': userMsg});
                chatMessages.add({'sender': 'typing', 'message': ''});
              });
              scrollToBottom();

              try {
                final aiReply = await _notifier.sendAiMessage(1, userMsg, question.questionId);
                setModalState(() {
                  chatMessages.removeWhere((m) => m['sender'] == 'typing');
                  chatMessages.add({'sender': 'ai', 'message': aiReply});
                });
              } catch (e) {
                setModalState(() {
                  chatMessages.removeWhere((m) => m['sender'] == 'typing');
                  chatMessages.add({
                    'sender': 'ai',
                    'message': '❌ Xin lỗi, mình đang gặp sự cố kết nối. Vui lòng thử lại sau nhé!',
                  });
                });
              }
              scrollToBottom();
            }

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
                              const Text('AI Sensei - Trợ lý học tập', style: TextStyle(fontWeight: FontWeight.bold, color: primaryCobalt, fontSize: 15)),
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
                        controller: scrollController,
                        itemCount: chatMessages.length,
                        itemBuilder: (context, index) {
                          final msg = chatMessages[index];
                          final sender = msg['sender']!;
                          final isAI = sender == 'ai';
                          final isTypingBubble = sender == 'typing';

                          return Align(
                            alignment: isAI || isTypingBubble ? Alignment.centerLeft : Alignment.centerRight,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: (isAI || isTypingBubble) ? Colors.grey.shade100 : primaryCobalt.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(12),
                                  topRight: const Radius.circular(12),
                                  bottomLeft: (isAI || isTypingBubble) ? Radius.zero : const Radius.circular(12),
                                  bottomRight: (isAI || isTypingBubble) ? const Radius.circular(12) : Radius.zero,
                                ),
                                border: (isAI || isTypingBubble) ? Border.all(color: Colors.grey.shade200) : null,
                              ),
                              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                              child: isTypingBubble
                                  ? Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(strokeWidth: 2, color: primaryCobalt),
                                        ),
                                        const SizedBox(width: 8),
                                        Text('AI Sensei đang soạn...', style: TextStyle(fontSize: 12, color: Colors.grey.shade500, fontStyle: FontStyle.italic)),
                                      ],
                                    )
                                  : Text(
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
                                enabled: !isTyping,
                                style: const TextStyle(fontSize: 13, color: textDark),
                                onSubmitted: (_) => handleSend(),
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
                            backgroundColor: isTyping ? Colors.grey.shade300 : primaryCobalt,
                            radius: 20,
                            child: IconButton(
                              icon: Icon(
                                isTyping ? Icons.hourglass_empty : Icons.send,
                                color: Colors.white,
                                size: 16,
                              ),
                              onPressed: isTyping ? null : handleSend,
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
    final detail = _reviewState.detail;
    if (detail == null || index >= detail.questions.length) return;
    final question = detail.questions[index];
    bool isCommentsLoading = true;
    String? commentsError;
    List<Map<String, String>> dialogCommentList = [];

    Future<void> fetchCommentsForQuestion(StateSetter setDialogState) async {
      try {
        final List<CommentResponse> allComments = await _notifier.fetchComments();
        final questionComments = allComments
            .where((c) => c.questionId == question.questionId)
            .map((c) => c.toMapForReview())
            .toList();

        setDialogState(() {
          dialogCommentList = questionComments;
          isCommentsLoading = false;
        });

        if (mounted) {
          _notifier.addLocalComment(index, 'Bạn', questionComments.isNotEmpty ? questionComments.last['content'] ?? '' : '');
        }
      } catch (e) {
        setDialogState(() {
          commentsError = e.toString();
          isCommentsLoading = false;
        });
      }
    }
    
    showDialog(
      context: context,
      builder: (context) {
        bool hasInitialized = false;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            if (!hasInitialized) {
              hasInitialized = true;
              fetchCommentsForQuestion(setDialogState);
            }

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
                      child: isCommentsLoading
                          ? const Center(
                              child: CircularProgressIndicator(color: primaryCobalt),
                            )
                          : commentsError != null
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        commentsError!,
                                        style: const TextStyle(color: Colors.red, fontSize: 13),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      ElevatedButton(
                                        onPressed: () {
                                          setDialogState(() {
                                            isCommentsLoading = true;
                                            commentsError = null;
                                          });
                                          fetchCommentsForQuestion(setDialogState);
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: primaryCobalt,
                                          foregroundColor: Colors.white,
                                        ),
                                        child: const Text('Thử lại'),
                                      )
                                    ],
                                  ),
                                )
                              : dialogCommentList.isEmpty
                                  ? const Center(
                                      child: Text('Chưa có bình luận nào.', style: TextStyle(color: textLight, fontSize: 13)),
                                    )
                                  : ListView.builder(
                                      shrinkWrap: true,
                                      itemCount: dialogCommentList.length,
                                      itemBuilder: (context, cIdx) {
                                        final c = dialogCommentList[cIdx];
                                        return Padding(
                                          padding: const EdgeInsets.only(bottom: 12.0),
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CircleAvatar(
                                                backgroundColor: primaryCobalt.withValues(alpha: 0.1),
                                                radius: 12,
                                                child: Text(
                                                  c['user'] != null && c['user']!.isNotEmpty ? c['user']![0] : 'U',
                                                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: primaryCobalt),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(c['user'] ?? 'Người dùng', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textDark)),
                                                    const SizedBox(height: 2),
                                                    Text(c['content'] ?? '', style: const TextStyle(fontSize: 12, color: textDark)),
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
                              enabled: !isCommentsLoading,
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
                            onPressed: isCommentsLoading
                                ? null
                                : () async {
                                    if (controller.text.trim().isEmpty) return;
                                    final commentText = controller.text.trim();
                                    
                                    setDialogState(() {
                                      isCommentsLoading = true;
                                      commentsError = null;
                                    });

                                    try {
                                      // Sử dụng userId = 1 mặc định giống các chỗ khác trong ứng dụng
                                      final CommentResponse newComment = await _notifier.createComment(
                                        1, 
                                        commentText, 
                                        question.questionId,
                                      );

                                      setDialogState(() {
                                        dialogCommentList.add(newComment.toMapForReview());
                                        isCommentsLoading = false;
                                      });

                                      if (mounted) {
                                        _notifier.addLocalComment(index, 'Bạn', commentText);
                                      }
                                      controller.clear();
                                    } catch (e) {
                                      setDialogState(() {
                                        isCommentsLoading = false;
                                        commentsError = 'Không thể gửi bình luận: $e';
                                      });
                                    }
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
    final reviewState = _reviewState; // cached for this build frame
    final detail = reviewState.detail;

    if (reviewState.isLoading) {
      return Scaffold(
        backgroundColor: bgLight,
        appBar: AppBar(
          backgroundColor: primaryCobalt,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Đang tải kết quả...',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: primaryCobalt),
        ),
      );
    }

    if (reviewState.error != null) {
      return Scaffold(
        backgroundColor: bgLight,
        appBar: AppBar(
          backgroundColor: primaryCobalt,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Lỗi tải kết quả',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off, size: 48, color: Colors.redAccent),
                const SizedBox(height: 12),
                const Text(
                  'Không thể tải chi tiết kết quả bài thi',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark),
                ),
                const SizedBox(height: 6),
                Text(
                  reviewState.error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: textLight),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _notifier.loadDetail(_effectiveAttemptId),
                  icon: const Icon(Icons.refresh, color: Colors.white, size: 16),
                  label: const Text('Thử lại', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryCobalt,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Stats calculation
    final totalCorrectAnswer = detail?.totalCorrectAnswer ?? '0/0';
    int totalQuestions = 0;
    int correctCount = 0;
    if (totalCorrectAnswer.contains('/')) {
      final parts = totalCorrectAnswer.split('/');
      if (parts.length >= 2) {
        correctCount = int.tryParse(parts[0].trim()) ?? 0;
        totalQuestions = int.tryParse(parts[1].trim()) ?? 0;
      }
    }
    final reviewQuestions = detail?.questions ?? [];
    if (totalQuestions == 0) {
      totalQuestions = reviewQuestions.length;
      correctCount = reviewQuestions.where((q) => q.isCorrect).length;
    }

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        backgroundColor: primaryCobalt,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          detail?.examName ?? 'Kết Quả Bài Thi',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
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
                  _buildSummaryCard(correctCount, totalQuestions, detail?.totalScore ?? 0.0, reviewState.detail != null ? (correctCount / (totalQuestions == 0 ? 1 : totalQuestions)) : 0.0, detail?.totalTime ?? '00:00'),
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
                    itemCount: reviewQuestions.length,
                    itemBuilder: (context, index) {
                      final question = reviewQuestions[index];
                      return _buildQuestionReviewCard(question, index, reviewState);
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
  Widget _buildSummaryCard(int correctCount, int totalQuestions, double score, double rate, String totalTime) {
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
                      _buildSummaryStatItem('Thời gian', totalTime),
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
  Widget _buildQuestionReviewCard(ReviewQuestion question, int index, ExamHistoryReviewState reviewState) {
    final isCorrect = question.isCorrect;
    final isExplExpanded = reviewState.expandedExplanations.contains(index);
    final commentList = (reviewState.dynamicComments[index] ?? []).isNotEmpty
        ? reviewState.dynamicComments[index]!
        : question.comments;

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
                  onTap: () => _reportError(question),
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
                  label: 'Bình luận',
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
