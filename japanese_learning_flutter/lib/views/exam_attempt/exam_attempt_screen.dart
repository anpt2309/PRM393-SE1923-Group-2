import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';


class ExamQuestion {
  final int number;
  final String title;
  final String questionText;
  final List<String> options;
  final String? formulaText;
  final bool isListening;
  final String? audioDuration;

  const ExamQuestion({
    required this.number,
    required this.title,
    required this.questionText,
    required this.options,
    this.formulaText,
    this.isListening = false,
    this.audioDuration,
  });
}

class ExamAttemptScreen extends StatefulWidget {
  const ExamAttemptScreen({super.key});

  @override
  State<ExamAttemptScreen> createState() => _ExamAttemptScreenState();
}

class _ExamAttemptScreenState extends State<ExamAttemptScreen> {
  // Mobile Palette Colors
  static const Color primaryCobalt = Color(0xFF1A237E); // Cobalt Blue
  static const Color accentOrange = Color(0xFFFF9800);  // Accent Orange
  static const Color darkFooter = Color(0xFF0F172A);     // Dark Slate Footer
  static const Color textDark = Color(0xFF1E293B);
  static const Color textLight = Color(0xFF64748B);
  static const Color bgLight = Color(0xFFF8FAFC);

  // Active question index (0 to 29)
  int _activeQuestionIndex = 0;
  final Map<int, int> _selectedAnswers = {};

  // Timer: 54 minutes
  int _secondsRemaining = 54 * 60;
  Timer? _countdownTimer;

  // Audio Player state for listening questions
  bool _isAudioPlaying = false;
  double _audioProgress = 0.0;
  Timer? _audioTimer;
  int _audioCurrentSeconds = 0;
  static const int _audioTotalSeconds = 45;

  // 30 questions matching vocabulary, grammar/reading, listening
  static final List<ExamQuestion> _questions = [
    // Section 1: Vocabulary (1-10)
    const ExamQuestion(
      number: 1,
      title: 'Phần 1: Từ vựng (Vocabulary)',
      questionText: 'Chữ Hán của từ "nihon" (Nhật Bản) được viết như thế nào?',
      options: ['A. 日本', 'B. 本日', 'C. 毎日', 'D. 日本語'],
    ),
    const ExamQuestion(
      number: 2,
      title: 'Phần 1: Từ vựng (Vocabulary)',
      questionText: 'Cách đọc Hiragana chính xác của chữ Hán "先生" (Giáo viên) là gì?',
      options: ['A. せんせい', 'B. がくせい', 'C. けんせい', 'D. てんせい'],
    ),
    const ExamQuestion(
      number: 3,
      title: 'Phần 1: Từ vựng (Vocabulary)',
      questionText: 'Chữ Hán "水" (Nước) có âm đọc Kunyomi là gì?',
      options: ['A. みず', 'B. おかね', 'C. つくえ', 'D. いす'],
    ),
    const ExamQuestion(
      number: 4,
      title: 'Phần 1: Từ vựng (Vocabulary)',
      questionText: 'Từ "明日" (Ngày mai) được phát âm như thế nào?',
      options: ['A. あした', 'B. きょう', 'C. きのう', 'D. あさって'],
    ),
    const ExamQuestion(
      number: 5,
      title: 'Phần 1: Từ vựng (Vocabulary)',
      questionText: 'Chữ Hán biểu diễn hành động "taberu" (Ăn) là chữ nào sau đây?',
      options: ['A. 食べる', 'B. 飲む', 'C. 買う', 'D. 見る'],
    ),
    const ExamQuestion(
      number: 6,
      title: 'Phần 1: Từ vựng (Vocabulary)',
      questionText: 'Chữ Hán "車" (Ô tô) có âm đọc là gì?',
      options: ['A. くるま', 'B. でんしゃ', 'C. じてんしゃ', 'D. ひこうき'],
    ),
    const ExamQuestion(
      number: 7,
      title: 'Phần 1: Từ vựng (Vocabulary)',
      questionText: 'Chữ Hán "花" (Hoa) có cách đọc âm ôn (Onyomi) trong từ "Kabin" (Bình hoa - 花瓶) là gì?',
      options: ['A. か', 'B. はな', 'C. け', 'D. ばん'],
    ),
    const ExamQuestion(
      number: 8,
      title: 'Phần 1: Từ vựng (Vocabulary)',
      questionText: 'Từ "時間" (Thời gian) được đọc chính xác là gì?',
      options: ['A. じかん', 'B. じしょ', 'C. じしん', 'D. じこ'],
    ),
    const ExamQuestion(
      number: 9,
      title: 'Phần 1: Từ vựng (Vocabulary)',
      questionText: 'Chữ Hán biểu diễn động từ "nomu" (Uống) là chữ nào?',
      options: ['A. 飲む', 'B. 読む', 'C. 休む', 'D. 住む'],
    ),
    const ExamQuestion(
      number: 10,
      title: 'Phần 1: Từ vựng (Vocabulary)',
      questionText: 'Cách phát âm chính xác của từ "日本語" (Tiếng Nhật) là gì?',
      options: ['A. にほんご', 'B. にっぽん', 'C. にほん', 'D. にほんじん'],
    ),

    // Section 2: Grammar & Reading (11-20)
    const ExamQuestion(
      number: 11,
      title: 'Phần 2: Ngữ pháp & Đọc hiểu (Grammar & Reading)',
      questionText: 'Chọn trợ từ thích hợp điền vào chỗ trống:\nわたしは毎日日本語___ 勉強します。',
      options: ['A. を', 'B. が', 'C. に', 'D. で'],
    ),
    const ExamQuestion(
      number: 12,
      title: 'Phần 2: Ngữ pháp & Đọc hiểu (Grammar & Reading)',
      questionText: 'Chọn trợ từ thích hợp điền vào chỗ trống:\nここに本___ あります。',
      options: ['A. が', 'B. を', 'C. に', 'D. は'],
    ),
    const ExamQuestion(
      number: 13,
      title: 'Phần 2: Ngữ pháp & Đọc hiểu (Grammar & Reading)',
      questionText: 'Chọn trợ từ thích hợp điền vào chỗ trống:\nいっしょに京都___ 行きませんか。',
      options: ['A. へ', 'B. を', 'C. で', 'D. が'],
    ),
    const ExamQuestion(
      number: 14,
      title: 'Phần 2: Ngữ pháp & Đọc hiểu (Grammar & Reading)',
      questionText: 'Tính toán phân bổ thời gian học tập T tối ưu cho cấu trúc sau, trong đó α đại diện cho hệ số từ vựng mới:',
      formulaText: 'T(x) = ∫₀¹⁰ (α * x² + β * log(x + 1)) dx = 23.5',
      options: ['A. x = 2.45', 'B. x = 3.12', 'C. x = 1.98', 'D. x = 4.05'],
    ),
    const ExamQuestion(
      number: 15,
      title: 'Phần 2: Ngữ pháp & Đọc hiểu (Grammar & Reading)',
      questionText: 'Tìm công thức tối ưu hóa khả năng ghi nhớ dài hạn M theo tần số lặp lại f:',
      formulaText: 'M(f) = M₀ * e^(-λ * t) + ∑_{i=1}^n β_i * f_i',
      options: ['A. Tăng f tuyến tính', 'B. f lặp lại giãn cách (Spaced)', 'C. f cố định hàng ngày', 'D. Giảm dần λ về 0'],
    ),
    const ExamQuestion(
      number: 16,
      title: 'Phần 2: Ngữ pháp & Đọc hiểu (Grammar & Reading)',
      questionText: 'Chọn từ điền vào chỗ trống:\n昨日、デパートへ行って、買い物___ しました。',
      options: ['A. を', 'B. が', 'C. に', 'D. と'],
    ),
    const ExamQuestion(
      number: 17,
      title: 'Phần 2: Ngữ pháp & Đọc hiểu (Grammar & Reading)',
      questionText: 'Chọn liên từ thích hợp nối hai vế:\n日本語は難しい___、おもしろいです。',
      options: ['A. が', 'B. から', 'C. ので', 'D. でも'],
    ),
    const ExamQuestion(
      number: 18,
      title: 'Phần 2: Ngữ pháp & Đọc hiểu (Grammar & Reading)',
      questionText: 'Đọc đoạn văn ngắn sau và trả lời câu hỏi:\n「木村さんは毎朝６時に起きます。コーヒーを飲んでから、新聞を読みます。７時半に会社へ行きます。」\n木村さんは朝起きてから何をしますか。',
      options: [
        'A. Đọc báo rồi uống cà phê',
        'B. Uống cà phê rồi đọc báo',
        'C. Đến công ty trực tiếp',
        'D. Tập thể dục buổi sáng'
      ],
    ),
    const ExamQuestion(
      number: 19,
      title: 'Phần 2: Ngữ pháp & Đọc hiểu (Grammar & Reading)',
      questionText: 'Đọc đoạn văn ngắn về sở thích của Tanaka-san:\n「田中さんの趣味はテニスです。毎週土曜日に友達 và テニスをします。テニスのあとで、みんなでビールを飲みます。」\nTanaka-san làm gì vào thứ bảy hàng tuần?',
      options: [
        'A. Đi uống bia một mình',
        'B. Chơi tennis cùng bạn bè',
        'C. Xem tennis trên tivi',
        'D. Đi làm thêm ở sân quần vợt'
      ],
    ),
    const ExamQuestion(
      number: 20,
      title: 'Phần 2: Ngữ pháp & Đọc hiểu (Grammar & Reading)',
      questionText: 'Đọc đoạn văn ngắn về chuyến du lịch Kyoto:\n「先週、京都へ行きました。京都までは新幹線で行きました。京都で有名なお寺をたくさん見ました。とても楽しかったです。」\nNgười viết đã di chuyển đến Kyoto bằng phương tiện gì?',
      options: [
        'A. Tàu điện ngầm thông thường',
        'B. Xe buýt đường dài',
        'C. Tàu cao tốc Shinkansen',
        'D. Máy bay nội địa'
      ],
    ),

    // Section 3: Listening (21-30)
    const ExamQuestion(
      number: 21,
      title: 'Phần 3: Nghe hiểu (Listening)',
      questionText: 'Nghe đoạn âm thanh và xác định thời tiết hôm nay được nói đến là gì?',
      options: ['A. あめ (Trời mưa)', 'B. はれ (Trời nắng)', 'C. ゆき (Trời tuyết)', 'D. くもり (Nhiều mây)'],
      isListening: true,
      audioDuration: '0:45',
    ),
    const ExamQuestion(
      number: 22,
      title: 'Phần 3: Nghe hiểu (Listening)',
      questionText: 'Nghe đoạn hội thoại và xác định xem bạn Tanaka đang chuẩn bị đi đâu?',
      options: ['A. 駅 (Nhà ga)', 'B. 図書館 (Thư viện)', 'C. スーパー (Siêu thị)', 'D. レストラン (Nhà hàng)'],
      isListening: true,
      audioDuration: '0:45',
    ),
    const ExamQuestion(
      number: 23,
      title: 'Phần 3: Nghe hiểu (Listening)',
      questionText: 'Nghe và xác định giờ hẹn gặp nhau của hai người vào buổi tối?',
      options: ['A. 5 giờ chiều', 'B. 6 giờ tối', 'C. 7 giờ tối', 'D. 8 giờ tối'],
      isListening: true,
      audioDuration: '0:45',
    ),
    const ExamQuestion(
      number: 24,
      title: 'Phần 3: Nghe hiểu (Listening)',
      questionText: 'Nghe và chọn món ăn mà hai người quyết định gọi tại quán ăn?',
      options: ['A. ラーメン (Ramen)', 'B. 寿司 (Sushi)', 'C. 天ぷら (Tempura)', 'D. うどん (Udon)'],
      isListening: true,
      audioDuration: '0:45',
    ),
    const ExamQuestion(
      number: 25,
      title: 'Phần 3: Nghe hiểu (Listening)',
      questionText: 'Nghe cuộc đối thoại ngắn và xác định xem nhân vật nữ đã đánh mất đồ vật gì?',
      options: ['A. 鍵 (Chìa khóa)', 'B. 携帯電話 (Điện thoại)', 'C. 財布 (Ví tiền)', 'D. パスポート (Hộ chiếu)'],
      isListening: true,
      audioDuration: '0:45',
    ),
    const ExamQuestion(
      number: 26,
      title: 'Phần 3: Nghe hiểu (Listening)',
      questionText: 'Nghe và xác định chính xác ngày tổ chức bữa tiệc sinh nhật?',
      options: ['A. Thứ bảy tuần sau', 'B. Chủ nhật tuần này', 'C. Thứ sáu tuần sau', 'D. Thứ hai tuần tới'],
      isListening: true,
      audioDuration: '0:45',
    ),
    const ExamQuestion(
      number: 27,
      title: 'Phần 3: Nghe hiểu (Listening)',
      questionText: 'Nghe đoạn văn ngắn và chọn phương tiện đi làm hàng ngày của cô Yamada?',
      options: ['A. 自転車 (Xe đạp)', 'B. 電車 (Tàu điện)', 'C. 徒歩 (Đi bộ)', 'D. バス (Xe buýt)'],
      isListening: true,
      audioDuration: '0:45',
    ),
    const ExamQuestion(
      number: 28,
      title: 'Phần 3: Nghe hiểu (Listening)',
      questionText: 'Nghe hội thoại và xác định xem món quà sinh nhật họ chọn mua là gì?',
      options: ['A. 果物 (Hoa quả)', 'B. 本 (Sách)', 'C. 花 (Hoa tươi)', 'D. ケーキ (Bánh kem)'],
      isListening: true,
      audioDuration: '0:45',
    ),
    const ExamQuestion(
      number: 29,
      title: 'Phần 3: Nghe hiểu (Listening)',
      questionText: 'Nghe và ghi chép số điện thoại liên lạc của phòng khám tư nhân được nhắc tới?',
      options: ['A. 090-1234-5678', 'B. 090-8765-4321', 'C. 080-1111-2222', 'D. 090-5555-6666'],
      isListening: true,
      audioDuration: '0:45',
    ),
    const ExamQuestion(
      number: 30,
      title: 'Phần 3: Nghe hiểu (Listening)',
      questionText: 'Nghe đoạn hội thoại cuối cùng và chọn địa điểm tổ chức buổi họp mặt câu lạc bộ?',
      options: ['A. Tầng 3 khách sạn Sakura', 'B. Tầng 2 nhà hàng Fuji', 'C. Công viên Ueno', 'D. Quán cà phê cạnh trường học'],
      isListening: true,
      audioDuration: '0:45',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
    
    // Default answered count is 7/30 (23%) as in requirements
    _selectedAnswers[0] = 0;
    _selectedAnswers[1] = 1;
    _selectedAnswers[2] = 0;
    _selectedAnswers[10] = 2;
    _selectedAnswers[11] = 0;
    _selectedAnswers[20] = 1;
    _selectedAnswers[21] = 3;
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _stopAudioPlayer();
    super.dispose();
  }

  void _startTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _countdownTimer?.cancel();
        _submitExam();
      }
    });
  }

  String _formatDuration(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // Simulated listening audio player
  void _toggleAudioPlayer() {
    if (_isAudioPlaying) {
      _stopAudioPlayer();
    } else {
      setState(() {
        _isAudioPlaying = true;
      });
      _audioTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_audioCurrentSeconds < _audioTotalSeconds) {
          setState(() {
            _audioCurrentSeconds++;
            _audioProgress = _audioCurrentSeconds / _audioTotalSeconds;
          });
        } else {
          _resetAudioPlayer();
        }
      });
    }
  }

  void _stopAudioPlayer() {
    _audioTimer?.cancel();
    setState(() {
      _isAudioPlaying = false;
    });
  }

  void _resetAudioPlayer() {
    _audioTimer?.cancel();
    setState(() {
      _isAudioPlaying = false;
      _audioCurrentSeconds = 0;
      _audioProgress = 0.0;
    });
  }

  void _selectAnswer(int optionIndex) {
    setState(() {
      _selectedAnswers[_activeQuestionIndex] = optionIndex;
    });
  }

  void _changeQuestion(int index) {
    setState(() {
      _activeQuestionIndex = index;
    });
    _resetAudioPlayer();
  }

  void _submitExam() {
    _countdownTimer?.cancel();
    _stopAudioPlayer();

    int totalQuestions = _questions.length;
    int answeredCount = _selectedAnswers.length;

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
              Text(
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        const Text('Đã hoàn thành', style: TextStyle(fontSize: 11, color: textLight)),
                        const SizedBox(height: 4),
                        Text('$answeredCount / $totalQuestions', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textDark)),
                      ],
                    ),
                    Container(height: 24, width: 1, color: Colors.grey.shade300),
                    Column(
                      children: [
                        const Text('Thời gian làm bài', style: TextStyle(fontSize: 11, color: textLight)),
                        const SizedBox(height: 4),
                        Text(_formatDuration((54 * 60) - _secondsRemaining), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textDark)),
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
                  onPressed: () {
                    Navigator.pop(context); // Pop the confirmation dialog
                    context.go('/exams/0/history/review'); // Chuyển sang màn hình kết quả
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
  }

  void _showSubmitConfirmation() {
    int totalQuestions = _questions.length;
    int answeredCount = _selectedAnswers.length;

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

  // Draw the Dynamic Bottom Sheet Question Grid
  void _openQuestionGridBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6,
          maxChildSize: 0.85,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return StatefulBuilder(
              builder: (context, setModalState) {
                return SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Pull Indicator / Title Row
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Danh sách câu hỏi',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryCobalt),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: textLight),
                            onPressed: () => Navigator.pop(context),
                          )
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 12),

                      // Section 1: Vocabulary
                      _buildSectionLabel('Phần 1: Từ vựng (Q1 - Q10)'),
                      const SizedBox(height: 8),
                      _buildBottomSheetQuestionGrid(0, 10, setModalState),
                      const SizedBox(height: 20),

                      // Section 2: Grammar & Reading
                      _buildSectionLabel('Phần 2: Ngữ pháp & Đọc hiểu (Q11 - Q20)'),
                      const SizedBox(height: 8),
                      _buildBottomSheetQuestionGrid(10, 20, setModalState),
                      const SizedBox(height: 20),

                      // Section 3: Listening
                      _buildSectionLabel('Phần 3: Nghe hiểu (Q21 - Q30)'),
                      const SizedBox(height: 8),
                      _buildBottomSheetQuestionGrid(20, 30, setModalState),
                      const SizedBox(height: 24),

                      // Legend
                      const Divider(),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildLegendItem(primaryCobalt, 'Đã làm', isBordered: false),
                          _buildLegendItem(Colors.white, 'Đang chọn', isBordered: true),
                          _buildLegendItem(Colors.grey.shade200, 'Chưa làm', isBordered: false),
                        ],
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark),
    );
  }

  Widget _buildLegendItem(Color color, String text, {required bool isBordered}) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: isBordered ? Border.all(color: primaryCobalt, width: 2) : Border.all(color: Colors.transparent),
          ),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12, color: textLight)),
      ],
    );
  }

  Widget _buildBottomSheetQuestionGrid(int startIdx, int endIdx, StateSetter setModalState) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(endIdx - startIdx, (index) {
        final qIdx = startIdx + index;
        final questionNumber = qIdx + 1;
        final isAnswered = _selectedAnswers.containsKey(qIdx);
        final isActive = _activeQuestionIndex == qIdx;

        Color bgCol = Colors.grey.shade200;
        Color textCol = textDark;
        Color borderCol = Colors.transparent;

        if (isActive) {
          bgCol = Colors.white;
          textCol = primaryCobalt;
          borderCol = primaryCobalt;
        } else if (isAnswered) {
          bgCol = primaryCobalt;
          textCol = Colors.white;
        }

        return InkWell(
          onTap: () {
            setState(() {
              _activeQuestionIndex = qIdx;
            });
            _resetAudioPlayer();
            Navigator.pop(context); // Close bottom sheet
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: bgCol,
              shape: BoxShape.circle,
              border: Border.all(color: borderCol, width: isActive ? 2.5 : 0),
            ),
            alignment: Alignment.center,
            child: Text(
              '$questionNumber',
              style: TextStyle(
                fontSize: 11,
                fontWeight: isAnswered || isActive ? FontWeight.bold : FontWeight.normal,
                color: textCol,
              ),
            ),
          ),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeQuestion = _questions[_activeQuestionIndex];
    final totalQuestions = _questions.length;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: primaryCobalt,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                backgroundColor: Colors.white,
                title: const Text('Thoát phòng thi?', style: TextStyle(color: primaryCobalt, fontWeight: FontWeight.bold)),
                content: const Text('Mọi kết quả thi chưa nộp sẽ bị hủy bỏ. Bạn có muốn thoát?'),
                actions: [
                  TextButton(onPressed: () => Navigator.pop(context), child: const Text('Ở lại')),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.pop(context);
                    },
                    child: const Text('Thoát', style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
            );
          },
        ),
        title: const Text(
          'WT2025T21',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
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
                            'Câu ${activeQuestion.number}/30',
                            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: primaryCobalt),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Question Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Question Text
                          Text(
                            activeQuestion.questionText,
                            style: const TextStyle(fontSize: 15, color: textDark, height: 1.5, fontWeight: FontWeight.w500),
                          ),

                          // Math support formatting (if present)
                          if (activeQuestion.formulaText != null) ...[
                            const SizedBox(height: 14),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                              decoration: BoxDecoration(
                                color: bgLight,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                activeQuestion.formulaText!,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                  color: primaryCobalt,
                                ),
                              ),
                            ),
                          ],


                          // Audio Playback simulation for listening
                          if (activeQuestion.isListening) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: bgLight,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                    icon: Icon(
                                      _isAudioPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                                      color: primaryCobalt,
                                      size: 32,
                                    ),
                                    onPressed: _toggleAudioPlayer,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        LinearProgressIndicator(
                                          value: _audioProgress,
                                          backgroundColor: Colors.grey.shade300,
                                          color: primaryCobalt,
                                          minHeight: 4,
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            const Text('Đang phát đề nghe...', style: TextStyle(fontSize: 10, color: textLight)),
                                            Text(
                                              '${_audioCurrentSeconds ~/ 60}:${(_audioCurrentSeconds % 60).toString().padLeft(2, '0')} / ${activeQuestion.audioDuration}',
                                              style: const TextStyle(fontSize: 10, color: textLight),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Options List
                    const Text('Chọn một đáp án:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark)),
                    const SizedBox(height: 10),
                    Column(
                      children: List.generate(activeQuestion.options.length, (idx) {
                        final optionText = activeQuestion.options[idx];
                        final isSelected = _selectedAnswers[_activeQuestionIndex] == idx;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10.0),
                          child: InkWell(
                            onTap: () => _selectAnswer(idx),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? primaryCobalt.withValues(alpha: 0.04) : Colors.white,
                                border: Border.all(
                                  color: isSelected ? primaryCobalt : Colors.grey.shade200,
                                  width: isSelected ? 2.0 : 1.0,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  // Selected Radio circle
                                  Container(
                                    width: 18,
                                    height: 18,
                                    decoration: BoxDecoration(
                                      color: isSelected ? primaryCobalt : Colors.transparent,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected ? primaryCobalt : Colors.grey.shade400,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(Icons.circle, size: 8, color: Colors.white)
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      optionText,
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: isSelected ? primaryCobalt : textDark,
                                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      }),
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
                                _formatDuration(_secondsRemaining),
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
                    onPressed: _activeQuestionIndex > 0 ? () => _changeQuestion(_activeQuestionIndex - 1) : null,
                    icon: const Icon(Icons.arrow_back_ios, size: 12, color: Colors.white),
                    label: const Text('Câu trước', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                    style: TextButton.styleFrom(
                      disabledForegroundColor: Colors.white30,
                    ),
                  ),

                  // Next Button
                  TextButton.icon(
                    onPressed: _activeQuestionIndex < totalQuestions - 1 ? () => _changeQuestion(_activeQuestionIndex + 1) : null,
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

