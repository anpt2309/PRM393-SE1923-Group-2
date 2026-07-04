import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/app_setting_provider.dart';
import '../../../widgets/app_bar.dart';
import '../../../widgets/add_menu_button.dart';

class SentenceScreen extends ConsumerStatefulWidget {
  const SentenceScreen({super.key});

  @override
  ConsumerState<SentenceScreen> createState() => _SentenceScreenState();
}

class _SentenceScreenState extends ConsumerState<SentenceScreen> {
  int _currentStep = 0;

  // Khởi tạo thực thể FlutterTts
  final FlutterTts _flutterTts = FlutterTts();

  final List<Map<String, dynamic>> _sentencesData = [
    {
      'kanji': '私はHokkaidoの出身です。',
      'hira': 'わたしはほっかいどうのしゅっしんです。',
      'viet': 'Tôi đến từ Hokkaido.',
      'words': ['です', 'わたし', '北海道', 'の', '出身', 'は'],
    },
    {
      'kanji': '彼は新しい車を持っています。',
      'hira': 'かれはあたらしいくるまをもっています。',
      'viet': 'Xe của anh ta mới.',
      'words': ['持っています', '新しい', '車', '彼は', 'を'],
    },
    {
      'kanji': '何てきれいな人なんだ。',
      'hira': 'なんてきれいなひとなんだ。',
      'viet': 'Thật là một người đẹp!',
      'words': ['何', 'て', 'きれい', 'な', '人', 'な', 'ん', 'だ', '。'],
    },
    {
      'kanji': 'あなたは間違っている。',
      'hira': 'あなたはまちがっている。',
      'viet': 'Bạn sai rồi.',
      'words': ['まちがっている', 'あなた', 'は', '。'],
    },
  ];

  int _currentQuestionIndex = 0;
  List<String> _shuffledWords = [];
  List<String> _selectedWords = [];
  bool? _isCorrect;
  final Map<int, bool> _quizResults = {};

  @override
  void initState() {
    super.initState();
    _initTts(); // Cấu hình ngôn ngữ nói khi vào màn hình
    _initQuizForCurrentQuestion();
  }

  // Hàm cấu hình phát âm tiếng Nhật
  void _initTts() async {
    await _flutterTts.setLanguage("ja-JP"); // Đặt ngôn ngữ là tiếng Nhật
    await _flutterTts.setSpeechRate(0.5); // Đặt tốc độ nói vừa phải (0.0 đến 1.0)
    await _flutterTts.setVolume(1.0); // Âm lượng tối đa
  }

  // Hàm thực thi phát âm
  void _speak(String text) async {
    if (text.isNotEmpty) {
      await _flutterTts.speak(text);
    }
  }

  @override
  void dispose() {
    _flutterTts.stop(); // Giải phóng bộ nhớ khi thoát màn hình
    super.dispose();
  }

  void _initQuizForCurrentQuestion() {
    if (_sentencesData.isEmpty) return;
    final currentQuestion = _sentencesData[_currentQuestionIndex];
    setState(() {
      _selectedWords = [];
      _shuffledWords = List<String>.from(currentQuestion['words'])..shuffle();
      _isCorrect = null;
    });
  }

  void _checkAnswer() {
    final currentQuestion = _sentencesData[_currentQuestionIndex];

    // Kiểm tra câu trả lời dựa trên việc ghép đủ ký tự hoặc số từ tương đương
    bool check =
        _selectedWords.length == (currentQuestion['words'] as List<String>).length;

    setState(() {
      _isCorrect = check;
      _quizResults[_currentQuestionIndex] = check;
    });

    // Tự động phát âm khi người dùng trả lời xong để tăng phản xạ nghe
    _speak(currentQuestion['kanji']!);
  }

  int get _totalCorrect => _quizResults.values.where((v) => v == true).length;
  int get _totalWrong => _quizResults.values.where((v) => v == false).length;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingProvider);
    final double scale = settings.textScaleFactor;
    final isDarkMode = settings.isDarkMode;

    // Định cấu hình bảng màu động đồng bộ xuyên suốt màn hình
    final backgroundColor =
        isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final cardColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white70 : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white54 : Colors.black54;

    // Xác định tiêu đề động theo từng bước
    String appBarTitle = 'Luyện Mẫu Câu';
    if (_currentStep == 1) appBarTitle = 'Mẫu Câu';
    if (_currentStep == 2) appBarTitle = 'Sắp Xếp Từ Thành Câu';
    if (_currentStep == 3) appBarTitle = 'Kết quả Test';

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(
        title: appBarTitle,
        centerTitle: true,
        onBackPressed: _currentStep > 0
            ? () {
                setState(() {
                  if (_currentStep == 3) {
                    _currentStep = 2;
                  } else {
                    _currentStep--;
                  }
                });
              }
            : () => Navigator.of(context).pop(),
        actions: [
          GlobalAddMenuButton(
            cardColor: cardColor,
            textColor: textColor,
            subTextColor: subTextColor,
            icon: const Icon(Icons.add, color: Colors.white, size: 26),
            onAction: (value) {
              if (value == 'settings') {
                context.push('/profile/settings');
              }
            },
          ),
        ],
      ),
      body: _buildBody(scale, cardColor, textColor, subTextColor, isDarkMode),
    );
  }

  Widget _buildBody(double scale, Color cardColor, Color textColor,
      Color subTextColor, bool isDarkMode) {
    switch (_currentStep) {
      case 0:
        return _buildPartSelector(cardColor, subTextColor);
      case 1:
        return _buildSentenceList(cardColor, textColor, subTextColor);
      case 2:
        return _buildSentencePuzzle(
            scale, cardColor, textColor, subTextColor, isDarkMode);
      case 3:
        return _buildTestResult(textColor, subTextColor);
      default:
        return _buildPartSelector(cardColor, subTextColor);
    }
  }

  Widget _buildPartSelector(Color cardColor, Color subTextColor) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          color: cardColor,
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text('Part ${index + 1}',
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('100 Câu ngẫu nhiên thông dụng',
                style: TextStyle(fontSize: 13, color: subTextColor)),
            trailing: Icon(Icons.arrow_forward_ios,
                size: 14, color: subTextColor.withOpacity(0.5)),
            onTap: () => setState(() => _currentStep = 1),
          ),
        );
      },
    );
  }

  // ================= BƯỚC 1: DANH SÁCH MẪU CÂU =================
  Widget _buildSentenceList(
      Color cardColor, Color textColor, Color subTextColor) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _currentQuestionIndex = 0;
                    _initQuizForCurrentQuestion();
                    _currentStep = 2;
                  });
                },
                icon: const Icon(Icons.extension, size: 18, color: Colors.blue),
                label: const Text('Ghép câu',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold)),
              ),
              TextButton.icon(
                onPressed: () {
                  setState(() => _sentencesData.shuffle());
                },
                icon: const Icon(Icons.refresh, size: 18, color: Colors.blue),
                label: const Text('Đảo câu',
                    style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            itemCount: _sentencesData.length,
            itemBuilder: (context, index) {
              final item = _sentencesData[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item['kanji']!,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue)),
                          const SizedBox(height: 4),
                          Text(item['hira']!,
                              style: TextStyle(fontSize: 13, color: subTextColor)),
                          const SizedBox(height: 6),
                          Text(item['viet']!,
                              style: TextStyle(fontSize: 13, color: textColor)),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.volume_up,
                          color: subTextColor.withOpacity(0.7), size: 22),
                      onPressed: () => _speak(item['kanji']!),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ================= BƯỚC 2: MÀN HÌNH GHÉP CÂU =================
  Widget _buildSentencePuzzle(double scale, Color cardColor, Color textColor,
      Color subTextColor, bool isDarkMode) {
    if (_sentencesData.isEmpty) return const Center(child: Text('Không có dữ liệu'));
    final currentQuestion = _sentencesData[_currentQuestionIndex];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Chọn từ để ghép thành câu',
                  style: TextStyle(
                      fontSize: 15,
                      color: subTextColor,
                      fontWeight: FontWeight.w500)),
              Text('${_currentQuestionIndex + 1}/${_sentencesData.length}',
                  style: TextStyle(
                      fontSize: 15,
                      color: subTextColor,
                      fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              currentQuestion['viet']!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 17, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 140),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDarkMode
                  ? Colors.white10
                  : const Color(0xFFE8F5E9).withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border:
                  Border.all(color: isDarkMode ? Colors.white24 : Colors.black12),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 10,
              children: _selectedWords
                  .map((word) => ActionChip(
                        backgroundColor:
                            isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                            side: BorderSide(
                                color: isDarkMode
                                    ? Colors.white10
                                    : Colors.black12)),
                        label: Text(word,
                            style: const TextStyle(fontSize: 15, color: Colors.blue)),
                        onPressed: () {
                          setState(() {
                            _selectedWords.remove(word);
                            _shuffledWords.add(word);
                          });
                        },
                      ))
                  .toList(),
            ),
          ),
          const SizedBox(height: 30),
          Center(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: _shuffledWords
                  .map((word) => ActionChip(
                        backgroundColor:
                            isDarkMode ? const Color(0xFF2C2C2C) : Colors.white,
                        padding:
                            const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                            side: BorderSide(
                                color: isDarkMode
                                    ? Colors.white10
                                    : Colors.black12)),
                        label: Text(word,
                            style: const TextStyle(fontSize: 15, color: Colors.blue)),
                        onPressed: () {
                          setState(() {
                            _selectedWords.add(word);
                            _shuffledWords.remove(word);
                          });
                        },
                      ))
                  .toList(),
            ),
          ),
          const Spacer(),
          if (_isCorrect != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: _isCorrect!
                    ? (isDarkMode
                        ? const Color(0xFF1B5E20)
                        : const Color(0xFFD4EDDA))
                    : (isDarkMode
                        ? const Color(0xFFB71C1C)
                        : const Color(0xFFF8D7DA)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _isCorrect! ? Icons.check_circle : Icons.cancel,
                    color: _isCorrect!
                        ? (isDarkMode ? Colors.greenAccent : Colors.green)
                        : (isDarkMode ? Colors.redAccent : Colors.red),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isCorrect! ? 'Làm tốt lắm!' : 'Không chính xác',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _isCorrect!
                                  ? (isDarkMode ? Colors.white : Colors.green[800])
                                  : (isDarkMode ? Colors.white : Colors.red[800]),
                              fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(currentQuestion['kanji']!,
                            style: TextStyle(
                                color: _isCorrect!
                                    ? (isDarkMode
                                        ? Colors.white
                                        : Colors.green[900])
                                    : (isDarkMode
                                        ? Colors.white70
                                        : Colors.red[900]),
                                fontWeight: FontWeight.w500)),
                        Text(currentQuestion['hira']!,
                            style: TextStyle(
                                color: _isCorrect!
                                    ? (isDarkMode
                                        ? Colors.white70
                                        : Colors.green[700])
                                    : (isDarkMode
                                        ? Colors.white70
                                        : Colors.red[700]),
                                fontSize: 13)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.volume_up,
                        color: _isCorrect!
                            ? (isDarkMode ? Colors.greenAccent : Colors.green)
                            : (isDarkMode ? Colors.redAccent : Colors.red)),
                    onPressed: () => _speak(currentQuestion['kanji']!),
                  ),
                ],
              ),
            ),
          ],
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _currentQuestionIndex > 0
                      ? () {
                          setState(() {
                            _currentQuestionIndex--;
                            _initQuizForCurrentQuestion();
                          });
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('Câu Trước'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedWords.isEmpty ? null : _checkAnswer,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('Kiểm Tra'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      if (_currentQuestionIndex < _sentencesData.length - 1) {
                        _currentQuestionIndex++;
                        _initQuizForCurrentQuestion();
                      } else {
                        _currentStep = 3;
                      }
                    });
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: Text(_currentQuestionIndex < _sentencesData.length - 1
                      ? 'Câu Tiếp'
                      : 'Xem Kết Quả'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ================= BƯỚC 3: MÀN HÌNH KẾT QUẢ TEST =================
  Widget _buildTestResult(Color textColor, Color subTextColor) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'Tổng số câu: ${_sentencesData.length} câu, đã làm ${_quizResults.length} câu',
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold, color: textColor)),
          const SizedBox(height: 6),
          Text('Làm đúng $_totalCorrect câu, làm sai $_totalWrong câu',
              style: TextStyle(fontSize: 15, color: textColor)),
          const SizedBox(height: 20),
          const Center(
            child: Text('** Chi tiết kết quả bài Test **',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue)),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _sentencesData.length,
              itemBuilder: (context, index) {
                final item = _sentencesData[index];
                final isCorrect = _quizResults[index];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text('${index + 1}. ${item['kanji']}',
                                    style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue)),
                                const SizedBox(width: 8),
                                if (isCorrect != null)
                                  Icon(isCorrect ? Icons.check : Icons.close,
                                      color: isCorrect ? Colors.green : Colors.red,
                                      size: 18),
                              ],
                            ),
                            Text(item['hira']!,
                                style: TextStyle(fontSize: 13, color: subTextColor)),
                            Text(item['viet']!,
                                style: TextStyle(fontSize: 13, color: textColor)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.volume_up,
                            color: subTextColor.withOpacity(0.7), size: 20),
                        onPressed: () => _speak(item['kanji']!),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentQuestionIndex = 0;
                  _quizResults.clear();
                  _initQuizForCurrentQuestion();
                  _currentStep = 2;
                });
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, foregroundColor: Colors.white),
              child: const Text('Làm Lại Toàn Bộ Thử Thách'),
            ),
          )
        ],
      ),
    );
  }
}