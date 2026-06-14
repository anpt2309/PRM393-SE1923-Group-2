import 'package:flutter/material.dart';
import '../exam_attempt/exam_attempt_screen.dart';
import 'exam_history_review_screen.dart';

class ExamAttemptHistoryItem {
  final String title;
  final String level; // N1, N2, N3, N4, N5
  final double score; // out of 180
  final int correctCount;
  final int totalQuestions;
  final String duration;
  final String date;

  ExamAttemptHistoryItem({
    required this.title,
    required this.level,
    required this.score,
    required this.correctCount,
    required this.totalQuestions,
    required this.duration,
    required this.date,
  });
}

class ExamHistorySelectorScreen extends StatefulWidget {
  const ExamHistorySelectorScreen({super.key});

  @override
  State<ExamHistorySelectorScreen> createState() => _ExamHistorySelectorScreenState();
}

class _ExamHistorySelectorScreenState extends State<ExamHistorySelectorScreen> {
  // Color Palette
  static const Color primaryCobalt = Color(0xFF1A237E);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textLight = Color(0xFF64748B);
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color greenCorrect = Color(0xFF2E7D32);

  // Sorting Option State
  // "highest" = Điểm cao nhất, "lowest" = Điểm thấp nhất
  String _sortOrder = 'highest'; 

  // Mock List of Taken Exams
  final List<ExamAttemptHistoryItem> _historyItems = [
    ExamAttemptHistoryItem(
      title: 'Đề thi thử JLPT N3 - WT2025T21',
      level: 'N3',
      score: 120.0,
      correctCount: 20,
      totalQuestions: 30,
      duration: '45:12',
      date: '12/06/2026',
    ),
    ExamAttemptHistoryItem(
      title: 'Đề thi thử JLPT N2 - Standard N2',
      level: 'N2',
      score: 156.0,
      correctCount: 26,
      totalQuestions: 30,
      duration: '58:20',
      date: '10/06/2026',
    ),
    ExamAttemptHistoryItem(
      title: 'Đề thi thử JLPT N3 - Intensive Gram',
      level: 'N3',
      score: 90.0,
      correctCount: 15,
      totalQuestions: 30,
      duration: '54:00',
      date: '08/06/2026',
    ),
    ExamAttemptHistoryItem(
      title: 'Đề thi thử JLPT N4 - Basic N4',
      level: 'N4',
      score: 174.0,
      correctCount: 29,
      totalQuestions: 30,
      duration: '32:45',
      date: '05/06/2026',
    ),
    ExamAttemptHistoryItem(
      title: 'Đề thi thử JLPT N5 - Vocabulary N5',
      level: 'N5',
      score: 180.0,
      correctCount: 30,
      totalQuestions: 30,
      duration: '21:10',
      date: '02/06/2026',
    ),
  ];

  List<ExamAttemptHistoryItem> get _sortedHistoryItems {
    final sortedList = List<ExamAttemptHistoryItem>.from(_historyItems);
    if (_sortOrder == 'highest') {
      sortedList.sort((a, b) => b.score.compareTo(a.score));
    } else {
      sortedList.sort((a, b) => a.score.compareTo(b.score));
    }
    return sortedList;
  }

  @override
  Widget build(BuildContext context) {
    final sortedList = _sortedHistoryItems;

    return Scaffold(
      backgroundColor: bgLight,
      appBar: AppBar(
        title: const Text('Lịch Sử Luyện Đề', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        backgroundColor: primaryCobalt,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Sort Options and Total attempts header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.assignment_outlined, color: primaryCobalt, size: 20),
                    const SizedBox(width: 6),
                    Text(
                      'Đã làm: ${sortedList.length} đề',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: textDark, fontSize: 14),
                    ),
                  ],
                ),
                
                // Sorting dropdown
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                  decoration: BoxDecoration(
                    color: bgLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _sortOrder,
                      icon: const Icon(Icons.arrow_drop_down, color: primaryCobalt),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryCobalt),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _sortOrder = newValue;
                          });
                        }
                      },
                      items: const [
                        DropdownMenuItem(
                          value: 'highest',
                          child: Text('Sắp xếp: Điểm cao nhất'),
                        ),
                        DropdownMenuItem(
                          value: 'lowest',
                          child: Text('Sắp xếp: Điểm thấp nhất'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
          
          // List view of history
          Expanded(
            child: sortedList.isEmpty
                ? const Center(
                    child: Text('Chưa có lịch sử làm đề nào.', style: TextStyle(color: textLight, fontSize: 14)),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: sortedList.length,
                    itemBuilder: (context, index) {
                      final item = sortedList[index];
                      final rate = item.score / 180.0;
                      final isPassed = rate >= 0.6; // N3 passing score average

                      return Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200, width: 1.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            )
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(12),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ExamHistoryReviewScreen()),
                              );
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                children: [
                                  // Progress Score Badge
                                  Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      SizedBox(
                                        width: 56,
                                        height: 56,
                                        child: CircularProgressIndicator(
                                          value: rate,
                                          strokeWidth: 4,
                                          backgroundColor: Colors.grey.shade100,
                                          color: isPassed ? greenCorrect : accentOrange,
                                          strokeCap: StrokeCap.round,
                                        ),
                                      ),
                                      Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            '${item.score.toInt()}',
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: primaryCobalt),
                                          ),
                                          const Text('/180', style: TextStyle(fontSize: 8, color: textLight)),
                                        ],
                                      ),
                                    ],
                                  ),
                                  
                                  const SizedBox(width: 16),
                                  
                                  // Exam info details
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        // JLPT Badge & Date
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: primaryCobalt.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                item.level,
                                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: primaryCobalt),
                                              ),
                                            ),
                                            Text(
                                              item.date,
                                              style: const TextStyle(fontSize: 11, color: textLight),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        
                                        // Title
                                        Text(
                                          item.title,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: textDark, fontSize: 14),
                                        ),
                                        const SizedBox(height: 6),
                                        
                                        // Accuracy and Duration
                                        Row(
                                          children: [
                                            const Icon(Icons.check_circle_outline, size: 12, color: textLight),
                                            const SizedBox(width: 4),
                                            Text(
                                              'Đúng: ${item.correctCount}/${item.totalQuestions}',
                                              style: const TextStyle(fontSize: 11, color: textLight),
                                            ),
                                            const SizedBox(width: 16),
                                            const Icon(Icons.timer_outlined, size: 12, color: textLight),
                                            const SizedBox(width: 4),
                                            Text(
                                              item.duration,
                                              style: const TextStyle(fontSize: 11, color: textLight),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                  
                                  const SizedBox(width: 8),
                                  // Chevron-right icon indicating clickability
                                  const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      
      // Floating Action Button to start a new exam
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ExamAttemptScreen()),
          );
        },
        backgroundColor: accentOrange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Luyện đề mới', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
