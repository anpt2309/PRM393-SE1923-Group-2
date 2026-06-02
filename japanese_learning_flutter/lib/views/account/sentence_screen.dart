import 'package:flutter/material.dart';
import 'settings_screen.dart'; // Đảm bảo bạn đã có file này trong dự án

class SentenceScreen extends StatefulWidget {
  const SentenceScreen({super.key});

  @override
  State<SentenceScreen> createState() => _SentenceScreenState();
}

class _SentenceScreenState extends State<SentenceScreen> {
  // Trạng thái bước màn hình: 0 = Chọn Part, 1 = Danh sách câu, 2 = Làm bài tập, 3 = Kết quả Test
  int _currentStep = 0;

  // Dữ liệu mẫu 100 câu ngẫu nhiên thông dụng
  final List<Map<String, dynamic>> _sentencesData = [
    {
      'kanji': '私は北海道の出身です。',
      'hira': 'わたしはほっかいどうのしゅっしんです。',
      'viet': 'Tôi đến từ Hokkaido.',
      'words': ['です', 'わたし', '北海道', 'の', '出身', 'は'],
    },
    {
      'kanji': '彼は新しい車を持っています。',
      'hira': 'かれはあたらしいくるまをもっています。',
      'viet': 'Xe của anh ta mới.',
      'words': ['は', '。', 'の', '車', '新しい', '彼'],
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

  // Các biến phục vụ trạng thái làm bài tập (Bước 2)
  int _currentQuestionIndex = 0;
  List<String> _shuffledWords = [];
  List<String> _selectedWords = [];

  // Trạng thái kiểm tra đáp án: null = chưa kiểm tra, true = đúng, false = sai
  bool? _isCorrect;

  // Lưu lịch sử làm bài để hiển thị ở màn hình kết quả (Bước 3)
  final Map<int, bool> _quizResults = {};

  @override
  void initState() {
    super.initState();
    _initQuizForCurrentQuestion();
  }

  // Khởi tạo/Đặt lại câu hỏi hiện tại
  void _initQuizForCurrentQuestion() {
    if (_sentencesData.isEmpty) return;
    final currentQuestion = _sentencesData[_currentQuestionIndex];
    setState(() {
      _selectedWords = [];
      _shuffledWords = List<String>.from(currentQuestion['words'])..shuffle();
      _isCorrect = null;
    });
  }

  // Logic kiểm tra câu trả lời ghép từ
  void _checkAnswer() {
    final currentQuestion = _sentencesData[_currentQuestionIndex];
    final userAnswer = _selectedWords.join('').trim();

    bool check = userAnswer == (currentQuestion['words'] as List<String>).join('').replaceAll('。', '').trim() ||
        _selectedWords.length == (currentQuestion['words'] as List<String>).length;

    setState(() {
      _isCorrect = check;
      _quizResults[_currentQuestionIndex] = check;
    });
  }

  // Đếm số câu đúng / sai cho màn hình kết quả công thức tổng quan
  int get _totalCorrect => _quizResults.values.where((v) => v == true).length;
  int get _totalWrong => _quizResults.values.where((v) => v == false).length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          _currentStep == 0
              ? 'Luyện Mẫu Câu'
              : _currentStep == 1
              ? 'Mẫu Câu'
              : _currentStep == 2
              ? 'Sắp Xếp Từ Thành Câu'
              : 'Kết quả Test',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: _currentStep > 0
            ? IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.blue, size: 20),
          onPressed: () {
            setState(() {
              if (_currentStep == 3) {
                _currentStep = 2; // Từ kết quả quay lại bài tập cũ
              } else {
                _currentStep--;
              }
            });
          },
        )
            : const BackButton(color: Colors.black87),
        actions: [
          // 🔴 ĐÃ THAY THẾ: Menu thả xuống (PopupMenuButton) theo đúng yêu cầu của bạn
          PopupMenuButton<String>(
            icon: const Icon(Icons.add, color: Colors.blue, size: 28),
            onSelected: (value) {
              if (value == 'home') {
                setState(() => _currentStep = 0); // Quay về màn hình chọn Part chính
              } else if (value == 'search') {
                _showQuickSearchBottomSheet();
              } else if (value == 'settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(
                value: 'home',
                child: Row(
                  children: [
                    Icon(Icons.home_outlined, color: Colors.black54),
                    SizedBox(width: 10),
                    Text('Trang chính'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'search',
                child: Row(
                  children: [
                    Icon(Icons.search, color: Colors.black54),
                    SizedBox(width: 10),
                    Text('Tra cứu'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: Row(
                  children: [
                    Icon(Icons.settings_outlined, color: Colors.black54),
                    SizedBox(width: 10),
                    Text('Cài đặt'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    switch (_currentStep) {
      case 0: return _buildPartSelector();
      case 1: return _buildSentenceList();
      case 2: return _buildSentencePuzzle();
      case 3: return _buildTestResult();
      default: return _buildPartSelector();
    }
  }

  // ================= BƯỚC 1: CHỌN PART HỌC =================
  Widget _buildPartSelector() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          color: Colors.white,
          elevation: 0,
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            title: Text('Part ${index + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: const Text('100 Câu ngẫu nhiên thông dụng', style: TextStyle(fontSize: 13, color: Colors.black54)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.black26),
            onTap: () => setState(() => _currentStep = 1),
          ),
        );
      },
    );
  }

  // ================= BƯỚC 2: DANH SÁCH SONG NGỮ (ĐÃ SẮP XẾP LẠI THANH TIÊU ĐỀ HÀM) =================
  Widget _buildSentenceList() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // 🔴 ĐÊN TRÁI: Ghép câu cho toàn bộ danh sách
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _currentQuestionIndex = 0; // Bắt đầu từ câu số 1 trong list
                    _initQuizForCurrentQuestion();
                    _currentStep = 2; // Kích hoạt quy trình ghép câu liên tiếp
                  });
                },
                icon: const Icon(Icons.extension, size: 18, color: Colors.orange),
                label: const Text('Ghép câu', style: TextStyle(fontSize: 13, color: Colors.orange, fontWeight: FontWeight.bold)),
              ),
              // 🔴 BÊN PHẢI: Đảo thứ tự xáo trộn danh sách hiện tại
              TextButton.icon(
                onPressed: () {
                  setState(() => _sentencesData.shuffle());
                },
                icon: const Icon(Icons.refresh, size: 18, color: Colors.blue),
                label: const Text('Đảo câu', style: TextStyle(fontSize: 13, color: Colors.blue, fontWeight: FontWeight.bold)),
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
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['kanji']!, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                    const SizedBox(height: 4),
                    Text(item['hira']!, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                    const SizedBox(height: 6),
                    Text(item['viet']!, style: const TextStyle(fontSize: 13, color: Colors.black87, fontWeight: FontWeight.w400)),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ================= BƯỚC 3: GHÉP TỪ THÀNH CÂU VÀ KIỂM TRA ĐÚNG/SAI =================
  Widget _buildSentencePuzzle() {
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
              const Text('Chọn từ để ghép thành câu', style: TextStyle(fontSize: 15, color: Colors.black54, fontWeight: FontWeight.w500)),
              Text('${_currentQuestionIndex + 1}/${_sentencesData.length}', style: const TextStyle(fontSize: 15, color: Colors.black54, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),

          Center(
            child: Text(
              currentQuestion['viet']!,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.blue),
            ),
          ),
          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 160),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9).withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: Colors.black12.withValues(alpha: 0.05)),
            ),
            child: Wrap(
              spacing: 8,
              runSpacing: 10,
              children: _selectedWords.map((word) => ActionChip(
                backgroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: const BorderSide(color: Colors.black12)),
                label: Text(word, style: const TextStyle(fontSize: 15, color: Colors.blue)),
                onPressed: () {
                  setState(() {
                    _selectedWords.remove(word);
                    _shuffledWords.add(word);
                  });
                },
              )).toList(),
            ),
          ),
          const SizedBox(height: 40),

          Center(
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: _shuffledWords.map((word) => ActionChip(
                backgroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6), side: const BorderSide(color: Colors.black12)),
                label: Text(word, style: const TextStyle(fontSize: 15, color: Colors.blue)),
                onPressed: () {
                  setState(() {
                    _selectedWords.add(word);
                    _shuffledWords.remove(word);
                  });
                },
              )).toList(),
            ),
          ),
          const Spacer(),

          if (_isCorrect != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: _isCorrect! ? const Color(0xFFD4EDDA) : const Color(0xFFF8D7DA),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    _isCorrect! ? Icons.check_circle : Icons.cancel,
                    color: _isCorrect! ? Colors.green : Colors.red,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _isCorrect! ? 'Làm tốt lắm!' : 'Không chính xác',
                          style: TextStyle(fontWeight: FontWeight.bold, color: _isCorrect! ? Colors.green[800] : Colors.red[800], fontSize: 15),
                        ),
                        const SizedBox(height: 4),
                        Text(currentQuestion['kanji']!, style: TextStyle(color: _isCorrect! ? Colors.green[900] : Colors.red[900], fontWeight: FontWeight.w500)),
                        Text(currentQuestion['hira']!, style: TextStyle(color: _isCorrect! ? Colors.green[700] : Colors.red[700], fontSize: 13)),
                        Text(currentQuestion['viet']!, style: TextStyle(color: _isCorrect! ? Colors.green[700] : Colors.red[700], fontSize: 13)),
                      ],
                    ),
                  ),
                  Icon(Icons.volume_up, color: _isCorrect! ? Colors.green : Colors.red),
                ],
              ),
            ),
          ],

          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _currentQuestionIndex > 0 ? () {
                    setState(() {
                      _currentQuestionIndex--;
                      _initQuizForCurrentQuestion();
                    });
                  } : null,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(vertical: 14)
                  ),
                  child: const Text('Câu Trước'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedWords.isEmpty ? null : _checkAnswer,
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue, foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(vertical: 14)
                  ),
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
                      backgroundColor: Colors.blue, foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                      padding: const EdgeInsets.symmetric(vertical: 14)
                  ),
                  child: Text(_currentQuestionIndex < _sentencesData.length - 1 ? 'Câu Tiếp' : 'Xem Kết Quả'),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  // ================= BƯỚC 4: MÀN HÌNH CHI TIẾT KẾT QUẢ TEST =================
  Widget _buildTestResult() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tổng số câu: ${_sentencesData.length} câu, đã làm ${_quizResults.length} câu', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text('Làm đúng $_totalCorrect câu, làm sai $_totalWrong câu', style: const TextStyle(fontSize: 15)),
          const SizedBox(height: 20),
          const Center(
            child: Text('** Chi tiết kết quả bài Test **', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('${index + 1}. ${item['kanji']}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blue)),
                          const SizedBox(width: 8),
                          if (isCorrect != null)
                            Icon(isCorrect ? Icons.check : Icons.close, color: isCorrect ? Colors.green : Colors.red, size: 18),
                        ],
                      ),
                      Text(item['hira']!, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                      Text(item['viet']!, style: const TextStyle(fontSize: 13, color: Colors.black87)),
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
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
              child: const Text('Làm Lại Toàn Bộ Thử Thách'),
            ),
          )
        ],
      ),
    );
  }

  // Phương thức phụ: Hiển thị BottomSheet tra cứu nhanh
  void _showQuickSearchBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom, left: 16, right: 16, top: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tra cứu nhanh mẫu câu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              decoration: InputDecoration(
                  hintText: 'Nhập từ khóa tìm kiếm (Kanji, Romaji, Việt)...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8))
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}