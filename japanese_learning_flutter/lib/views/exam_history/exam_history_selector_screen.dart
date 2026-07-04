import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/exam_history.dart';
import '../../providers/exam_history_provider.dart';

class ExamHistorySelectorScreen extends ConsumerWidget {
  const ExamHistorySelectorScreen({super.key});

  // Color Palette (di chuyển vào widget vì ConsumerWidget không có State class)
  static const Color primaryCobalt = Color(0xFF1A237E);
  static const Color accentOrange = Color(0xFFFF9800);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textLight = Color(0xFF64748B);
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color greenCorrect = Color(0xFF2E7D32);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(examHistoryListProvider);
    final notifier = ref.read(examHistoryListProvider.notifier);
    final sortedList = state.sortedItems;


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
                      value: state.sortOrder,
                      icon: const Icon(Icons.arrow_drop_down, color: primaryCobalt),
                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: primaryCobalt),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          notifier.setSortOrder(newValue);
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
            child: state.isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: primaryCobalt),
                  )
                : state.error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.cloud_off, size: 48, color: Colors.redAccent),
                              const SizedBox(height: 12),
                              const Text(
                                'Không thể tải lịch sử làm bài',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textDark),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                state.error!,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 13, color: textLight),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: notifier.loadHistory,
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
                      )
                    : sortedList.isEmpty
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
                              context.push('/exams/0/history/review', extra: item.idAttempt);
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
          context.push('/exams');
        },
        backgroundColor: accentOrange,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Luyện đề mới', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
