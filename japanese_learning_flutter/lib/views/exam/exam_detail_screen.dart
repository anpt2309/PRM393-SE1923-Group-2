import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/exam.dart';
import '../../data/models/exam_detail.dart';
import '../../data/repository/exam_repository.dart';

class ExamDetailScreen extends StatefulWidget {
  final Exam exam;

  const ExamDetailScreen({super.key, required this.exam});

  @override
  State<ExamDetailScreen> createState() => _ExamDetailScreenState();
}

class _ExamDetailScreenState extends State<ExamDetailScreen> {
  // Styling Constants
  static const Color cobaltBlue = Color(0xFF0D47A1);
  static const Color energeticOrange = Color(0xFFFF9800);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);

  final ExamRepository _repository = ExamRepository();
  ExamDetail? _examDetail;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final detail = await _repository.getExamDetail(widget.exam.id);
      if (mounted) {
        setState(() {
          _examDetail = detail;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  String _formatPrice(String price) {
    final lowerPrice = price.toLowerCase().trim();
    if (lowerPrice == '0' || lowerPrice == '0.0' || lowerPrice == 'miễn phí' || lowerPrice.isEmpty) {
      return 'Miễn phí';
    }
    final cleanPrice = price.replaceAll(RegExp(r'[^\d]'), '');
    final parsed = double.tryParse(cleanPrice);
    if (parsed != null) {
      final value = parsed.toInt().toString();
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
    return price;
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
                'Bạn đã sẵn sàng để làm bài thi "${widget.exam.title}"?',
                style: const TextStyle(color: textDark, fontSize: 14),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  const Icon(Icons.timer_outlined, size: 16, color: textLight),
                  const SizedBox(width: 6),
                  Text('Thời gian: ${widget.exam.totalDuration} phút', style: const TextStyle(fontSize: 13, color: textLight)),
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
                context.push('/exams/${widget.exam.id}/attempt');
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
                  Text(_formatPrice(widget.exam.price), style: const TextStyle(color: energeticOrange, fontWeight: FontWeight.bold, fontSize: 16)),
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
                context.push('/payment/checkout');
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
    // Determine level display from detail or fallback
    final hasLevel = _examDetail != null && _examDetail!.level.isNotEmpty;
    final String badgeText = hasLevel
        ? 'Loại: ${widget.exam.examType} • Cấp độ: ${_examDetail!.level} • ${widget.exam.difficulty}'
        : 'Loại: ${widget.exam.examType} • ${widget.exam.difficulty}';

    // Get description from detail or fallback
    final String descriptionText = _examDetail != null ? _examDetail!.description : widget.exam.description;

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
          widget.exam.examType,
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
                  // Difficulty/Level Badge & Price Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: energeticOrange.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            badgeText,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: energeticOrange,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _formatPrice(widget.exam.price),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: widget.exam.isFree ? Colors.green.shade700 : energeticOrange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    widget.exam.title,
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
                        _buildStatItem(Icons.timer_outlined, '${widget.exam.totalDuration} phút', 'Thời gian'),
                        _buildDivider(),
                        _buildStatItem(Icons.star_outline, widget.exam.start.toString(), 'Đánh giá'),
                        _buildDivider(),
                        _buildStatItem(Icons.people_outline, widget.exam.userCount, 'Lượt thi'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Description Section
                  if (descriptionText.trim().isNotEmpty) ...[
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
                      descriptionText,
                      style: const TextStyle(
                        fontSize: 14,
                        color: textDark,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],

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

                  if (_isLoading)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 20),
                        child: CircularProgressIndicator(color: cobaltBlue),
                      ),
                    )
                  else if (_errorMessage != null)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        child: Column(
                          children: [
                            const Text('Lỗi tải cấu trúc đề thi từ backend.', style: TextStyle(color: Colors.redAccent, fontSize: 13)),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: _fetchDetail,
                              icon: const Icon(Icons.refresh, size: 16, color: cobaltBlue),
                              label: const Text('Thử lại', style: TextStyle(color: cobaltBlue, fontWeight: FontWeight.bold)),
                            )
                          ],
                        ),
                      ),
                    )
                  else if (_examDetail == null || _examDetail!.parts.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Không có thông tin cấu trúc đề thi.',
                        style: TextStyle(fontSize: 13, color: textLight),
                      ),
                    )
                  else
                    ..._examDetail!.parts.map((p) => _buildSectionItem(p.partName, 'Thời gian làm bài: ${p.partDuration} phút')),

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
                      _formatPrice(widget.exam.price),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: widget.exam.isFree ? Colors.green.shade700 : energeticOrange,
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
                        if (widget.exam.isFree) {
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
                        widget.exam.isFree ? 'BẮT ĐẦU THI' : 'MỞ KHÓA BÀI THI',
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
