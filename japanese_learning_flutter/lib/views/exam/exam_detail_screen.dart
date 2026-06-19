import 'package:flutter/material.dart';
import '../../data/models/exam.dart';
import '../exam_attempt/exam_attempt_screen.dart';

class ExamDetailScreen extends StatelessWidget {
  final Exam exam;

  const ExamDetailScreen({super.key, required this.exam});

  // Styling Constants
  static const Color cobaltBlue = Color(0xFF0D47A1);
  static const Color energeticOrange = Color(0xFFFF9800);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);

  String _formatPrice(double price) {
    if (price == 0.0) return 'Miễn phí';
    final value = price.toInt().toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = value.length - 1; i >= 0; i--) {
      buffer.write(value[i]);
      count++;
      if (count % 3 == 0 && i != 0) {
        buffer.write('.');
      }
    }
    return '${buffer.toString().split('').reversed.join('')}đ';
  }

  void _showStartExamDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.play_circle_outline, color: cobaltBlue),
              SizedBox(width: 8),
              Text(
                'Bắt đầu làm bài',
                style: TextStyle(color: cobaltBlue, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bạn đã sẵn sàng để làm bài thi "${exam.title}"?',
                style: const TextStyle(color: textDark, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 16, color: textLight),
                  const SizedBox(width: 6),
                  Text('Thời gian: ${exam.durationMinutes} phút', style: const TextStyle(fontSize: 13, color: textLight)),
                ],
              ),
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.help_outline, size: 16, color: textLight),
                  const SizedBox(width: 6),
                  Text('Số câu hỏi: ${exam.questionsCount} câu', style: const TextStyle(fontSize: 13, color: textLight)),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Lưu ý: Bạn không nên thoát ứng dụng trong suốt thời gian làm bài để tránh mất kết quả.',
                style: TextStyle(color: Colors.redAccent, fontSize: 11, fontStyle: FontStyle.italic),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Huỷ bỏ', style: TextStyle(color: textLight)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ExamAttemptScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: energeticOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Bắt đầu'),
            ),
          ],
        );
      },
    );
  }

  void _showUnlockDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.lock_open, color: energeticOrange),
              SizedBox(width: 8),
              Text(
                'Mở khoá bài thi',
                style: TextStyle(color: cobaltBlue, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bài thi này yêu cầu thanh toán để sử dụng.',
                style: const TextStyle(color: textDark, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Giá gốc:', style: TextStyle(color: textLight)),
                  Text(_formatPrice(exam.price), style: const TextStyle(color: energeticOrange, fontWeight: FontWeight.bold, fontSize: 16)),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'Sau khi mở khoá, bạn sẽ có quyền truy cập vĩnh viễn và xem lời giải chi tiết cho đề thi này.',
                style: TextStyle(color: textLight, fontSize: 12),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Để sau', style: TextStyle(color: textLight)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Thanh toán thành công! Bài thi đã được mở khoá.'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: energeticOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Mở khoá ngay'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: cobaltBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          exam.type,
          style: const TextStyle(
            color: cobaltBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Difficulty Badge & Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: energeticOrange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'JLPT: ${exam.jlptLevel} • ${exam.difficulty}',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: energeticOrange,
                          ),
                        ),
                      ),
                      Text(
                        _formatPrice(exam.price),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: exam.isFree ? Colors.green.shade700 : energeticOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    exam.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quick Stats Row
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade100),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem(Icons.timer_outlined, '${exam.durationMinutes} phút', 'Thời gian'),
                        _buildDivider(),
                        _buildStatItem(Icons.help_outline, '${exam.questionsCount} câu', 'Câu hỏi'),
                        _buildDivider(),
                        _buildStatItem(Icons.star_outline, exam.rating.toString(), 'Đánh giá'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description Section
                  const Text(
                    'Giới thiệu bài thi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: cobaltBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    exam.description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: textDark,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Exam structure / Syllabus
                  const Text(
                    'Cấu trúc đề thi',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: cobaltBlue,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSectionItem('Phần 1: Kiến thức ngôn ngữ (Từ vựng, Chữ Hán)', 'Thời gian khuyên dùng: 30 phút'),
                  _buildSectionItem('Phần 2: Ngữ pháp & Đọc hiểu', 'Thời gian khuyên dùng: 60 phút'),
                  _buildSectionItem('Phần 3: Nghe hiểu', 'Thời gian khuyên dùng: 40 phút'),
                  const SizedBox(height: 24),

                  // Regulations
                  const Text(
                    'Quy chế & Hướng dẫn',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: cobaltBlue,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildInstructionItem('1. Đọc kỹ câu hỏi trước khi chọn đáp án.'),
                  _buildInstructionItem('2. Hệ thống tự động nộp bài khi hết thời gian đếm ngược.'),
                  _buildInstructionItem('3. Xem lời giải chi tiết ngay sau khi hoàn tất.'),
                ],
              ),
            ),
          ),

          // Bottom Action Bar
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                )
              ],
            ),
            child: Row(
              children: [
                // Display price in bar
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Tổng chi phí', style: TextStyle(color: textLight, fontSize: 12)),
                    const SizedBox(height: 4),
                    Text(
                      _formatPrice(exam.price),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: exam.isFree ? Colors.green.shade700 : energeticOrange,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 24),

                // Action Button
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        if (exam.isFree) {
                          _showStartExamDialog(context);
                        } else {
                          _showUnlockDialog(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: energeticOrange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        exam.isFree ? 'BẮT ĐẦU THI' : 'MỞ KHÓA BÀI THI',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
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

  Widget _buildStatItem(IconData icon, String value, String label) {
    return Column(
      children: [
        Icon(icon, color: cobaltBlue, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textDark),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 11, color: textLight),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 36,
      width: 1,
      color: Colors.grey.shade300,
    );
  }

  Widget _buildSectionItem(String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, color: cobaltBlue, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: textLight),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Text(
        text,
        style: const TextStyle(fontSize: 13, color: textDark, height: 1.4),
      ),
    );
  }
}
