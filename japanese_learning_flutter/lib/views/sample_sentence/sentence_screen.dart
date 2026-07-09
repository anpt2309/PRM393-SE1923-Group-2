import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/app_setting_provider.dart';
import '../../../widgets/app_bar.dart';
import '../../../widgets/add_menu_button.dart';
import '../../data/repositories/sentence_repository.dart';
import '../../data/models/sentence_item.dart';
import '../../data/models/sentence_group.dart';
import '../../data/models/sentence_part.dart';

class SentenceScreen extends ConsumerStatefulWidget {
  const SentenceScreen({super.key});

  @override
  ConsumerState<SentenceScreen> createState() => _SentenceScreenState();
}

class _SentenceScreenState extends ConsumerState<SentenceScreen> with SingleTickerProviderStateMixin {
  final _repository = SentenceRepository();
  final FlutterTts _flutterTts = FlutterTts();
  late TabController _tabController;

  int _currentStep = 0; // 0: Bản đồ bài học, 1: Danh sách câu, 2: Quiz, 3: Kết quả

  List<SentencePart> _parts = [];
  List<SentenceItem> _sentences = [];

  SentenceGroup? _selectedGroup;
  SentencePart? _selectedPart;
  bool _isLoading = false;

  // Trạng thái Quiz
  int _currentQuestionIndex = 0;
  List<String> _shuffledWords = [];
  List<String> _selectedWords = [];
  bool? _isCorrect;
  final Map<int, bool> _quizResults = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) _loadInitialData();
    });
    _initTts();
    _loadInitialData();
  }

  void _initTts() async {
    await _flutterTts.setLanguage("ja-JP");
    await _flutterTts.setSpeechRate(0.45);
    await _flutterTts.setVolume(1.0);
  }

  // Tự động load Parts ngay khi vào màn hình hoặc đổi Tab
  Future<void> _loadInitialData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final type = _tabController.index == 0 ? SentenceGroupType.DISCOVERY : SentenceGroupType.CHALLENGE;
      final groups = await _repository.getGroups(type);

      if (groups.isNotEmpty) {
        final parts = await _repository.getParts(groups.first.id);
        if (mounted) {
          setState(() {
            _selectedGroup = groups.first;
            _parts = parts;
            _currentStep = 0; // Luôn bắt đầu từ bản đồ bài học
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _parts = [];
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _speak(String text) async {
    if (text.isNotEmpty) await _flutterTts.speak(text);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingProvider);
    final isDark = settings.isDarkMode;
    final double scale = settings.textScaleFactor;

    final backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.8);
    final subTextColor = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(
        title: _getStepTitle(),
        centerTitle: true,
        onBackPressed: _currentStep > 0 ? () => setState(() => _currentStep--) : () => context.pop(),
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFF1976D2),
        textColor: Colors.white,
        iconColor: Colors.white,
        bottom: _currentStep == 0 ? TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Khám phá (Chủ đề)'), Tab(text: 'Thử thách (JLPT)')],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
        ) : null,
        actions: [
          GlobalAddMenuButton(
            cardColor: cardColor, textColor: textColor, subTextColor: subTextColor,
            icon: const Icon(Icons.add, color: Colors.white, size: 26),
            onAction: (value) { if (value == 'settings') context.push('/profile/settings'); },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1976D2)))
          : _buildBody(scale, cardColor, textColor, subTextColor, isDark),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0: return _selectedGroup?.name ?? 'Luyện mẫu câu';
      case 1: return 'Mẫu Câu';
      case 2: return 'Ghép câu';
      case 3: return 'Kết quả Test';
      default: return 'Luyện mẫu câu';
    }
  }

  Widget _buildBody(double scale, Color cardColor, Color textColor, Color subTextColor, bool isDark) {
    switch (_currentStep) {
      case 0: return _buildTopicMap(cardColor, textColor, subTextColor);
      case 1: return _buildSentenceList(cardColor, textColor, subTextColor);
      case 2: return _buildQuizEngine(scale, cardColor, textColor, subTextColor, isDark);
      case 3: return _buildFinalScore(isDark);
      default: return _buildTopicMap(cardColor, textColor, subTextColor);
    }
  }

  // --- BẢN ĐỒ BÀI HỌC ---
  Widget _buildTopicMap(Color cardColor, Color textColor, Color subTextColor) {
    if (_parts.isEmpty) return Center(child: Text('Chưa có dữ liệu bài học', style: TextStyle(color: subTextColor)));
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: _parts.length,
      itemBuilder: (context, i) {
        final part = _parts[i];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(color: const Color(0xFF1976D2), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 2.5)),
                  child: Center(child: Text(part.icon, style: const TextStyle(fontSize: 18))),
                ),
                if (i != _parts.length - 1) Container(width: 3, height: 60, color: const Color(0xFF1976D2).withValues(alpha: 0.2)),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () => _loadSentences(part),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 30),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 15,
                        offset: Offset.zero, // Đổ bóng đều xung quanh ô
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(part.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
                      const SizedBox(height: 4),
                      Text(part.description, style: TextStyle(fontSize: 13, color: subTextColor)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // --- DANH SÁCH MẪU CÂU (PREVIEW) ---
  Widget _buildSentenceList(Color cardColor, Color textColor, Color subTextColor) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => _startQuiz(false),
                icon: const Icon(Icons.auto_stories_outlined, size: 18, color: Color(0xFF1976D2)),
                label: const Text('Ghép trình tự', style: TextStyle(fontSize: 13, color: Color(0xFF1976D2), fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: () => _startQuiz(true),
                icon: const Icon(Icons.psychology_outlined, size: 18, color: Color(0xFF1976D2)),
                label: const Text('Ghép xáo trộn', style: TextStyle(fontSize: 13, color: Color(0xFF1976D2), fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _sentences.length,
            itemBuilder: (context, i) => Card(
              color: cardColor, elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(_sentences[i].kanji, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1976D2))),
                      const SizedBox(height: 4),
                      Text(_sentences[i].hira, style: TextStyle(fontSize: 13, color: subTextColor)),
                      const SizedBox(height: 4),
                      Text(_sentences[i].viet, style: TextStyle(fontSize: 14, color: textColor)),
                    ])),
                    IconButton(icon: const Icon(Icons.volume_up, color: Colors.black54), onPressed: () => _speak(_sentences[i].kanji)),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // --- MÀN HÌNH QUIZ VỚI 3 NÚT ĐIỀU HƯỚNG ---
  Widget _buildQuizEngine(double scale, Color cardColor, Color textColor, Color subTextColor, bool isDark) {
    final q = _sentences[_currentQuestionIndex];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            height: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (_currentQuestionIndex + 1) / _sentences.length,
                backgroundColor: const Color(0xFF1976D2).withValues(alpha: 0.1),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Câu ${_currentQuestionIndex + 1}/${_sentences.length}', style: TextStyle(color: subTextColor, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(q.viet, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1976D2)), textAlign: TextAlign.center),
          const SizedBox(height: 30),
          Container(
            height: 140, width: double.infinity, padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFF1976D2).withValues(alpha: 0.03), borderRadius: BorderRadius.circular(16), border: Border.all(color: _isCorrect == false ? Colors.red.withValues(alpha: 0.4) : const Color(0xFF1976D2).withValues(alpha: 0.1))),
            child: Wrap(spacing: 8, runSpacing: 8, children: _selectedWords.map((w) => ActionChip(label: Text(w), padding: EdgeInsets.zero, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), onPressed: () => setState(() { _selectedWords.remove(w); _shuffledWords.add(w); _isCorrect = null; }))).toList()),
          ),
          const SizedBox(height: 30),
          Wrap(spacing: 12, runSpacing: 12, alignment: WrapAlignment.center, children: _shuffledWords.map((w) => ActionChip(label: Text(w, style: const TextStyle(color: Color(0xFF1976D2))), backgroundColor: cardColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), onPressed: () => setState(() { _selectedWords.add(w); _shuffledWords.remove(w); }))).toList()),
          const Spacer(),
          if (_isCorrect != null) Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(color: _isCorrect! ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(_isCorrect! ? Icons.check_circle : Icons.lightbulb, color: _isCorrect! ? Colors.green : Colors.orange, size: 20),
                const SizedBox(width: 8),
                Text(_isCorrect! ? 'Chính xác! 🎉' : 'Gợi ý từ Mazii:', style: TextStyle(fontWeight: FontWeight.bold, color: _isCorrect! ? Colors.green : Colors.red)),
              ]),
              if (!_isCorrect! && q.explanation != null) Padding(padding: const EdgeInsets.only(top: 8, left: 28), child: Text(q.explanation!, style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87))),
              if (_isCorrect!) Padding(padding: const EdgeInsets.only(top: 8, left: 28), child: Text(q.kanji, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
            ]),
          ),
          Row(
            children: [
              Expanded(child: ElevatedButton(
                onPressed: _currentQuestionIndex == 0 ? null : () => setState(() { _currentQuestionIndex--; _initQuizForCurrentQuestion(); }),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade100, foregroundColor: Colors.blue.shade700, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Câu trước', style: TextStyle(fontWeight: FontWeight.bold)),
              )),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton(
                onPressed: _selectedWords.isEmpty ? null : _checkAnswer,
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1976D2), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Kiểm tra', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )),
              const SizedBox(width: 8),
              Expanded(child: ElevatedButton(
                onPressed: () {
                  if (_currentQuestionIndex < _sentences.length - 1) {
                    setState(() { _currentQuestionIndex++; _initQuizForCurrentQuestion(); });
                  } else {
                    setState(() => _currentStep = 3);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade100, foregroundColor: Colors.blue.shade700, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text(_currentQuestionIndex < _sentences.length - 1 ? 'Câu tiếp' : 'Kết quả', style: const TextStyle(fontWeight: FontWeight.bold)),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinalScore(bool isDark) {
    int correct = _quizResults.values.where((v) => v).length;
    int failed = _quizResults.length - correct;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng số câu: ${_sentences.length} câu, đã làm ${_quizResults.length} câu',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 6),
          Text(
            'Làm đúng $correct câu, làm sai $failed câu',
            style: const TextStyle(fontSize: 15),
          ),
          const SizedBox(height: 20),
          const Center(
            child: Text(
              '** Chi tiết kết quả bài Test **',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1976D2)),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: _sentences.length,
              itemBuilder: (context, index) {
                final item = _sentences[index];
                final isCorrect = _quizResults[index];

                Color? bgColor;
                if (isCorrect == true) {
                  bgColor = Colors.green.withValues(alpha: 0.1);
                } else if (isCorrect == false) {
                  bgColor = Colors.red.withValues(alpha: 0.1);
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${index + 1}. ${item.kanji}',
                              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1976D2)),
                            ),
                            const SizedBox(height: 2),
                            Text(item.hira, style: const TextStyle(fontSize: 13, color: Colors.black54)),
                            Text(item.viet, style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up, color: Colors.black54, size: 20),
                        onPressed: () => _speak(item.kanji),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: () => setState(() {
                _currentQuestionIndex = 0;
                _quizResults.clear();
                _initQuizForCurrentQuestion();
                _currentStep = 0; // Quay lại bản đồ bài học
              }),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1976D2), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text('Làm Lại Toàn Bộ Thử Thách', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }

  // --- LOGIC HELPER ---
  Future<void> _loadSentences(SentencePart part) async {
    setState(() => _isLoading = true);
    final data = await _repository.getSentences(part.id);
    setState(() { _sentences = data; _selectedPart = part; _currentStep = 1; _isLoading = false; });
  }

  Future<void> _startQuiz(bool shuffle) async {
    setState(() => _isLoading = true);
    // Lưu ý: Dữ liệu đã được load ở bước 1, nên ở đây chỉ cần xử lý shuffle
    if (shuffle) _sentences.shuffle();
    setState(() {
      _currentQuestionIndex = 0;
      _quizResults.clear();
      _initQuizForCurrentQuestion();
      _currentStep = 2;
      _isLoading = false;
    });
  }

  void _initQuizForCurrentQuestion() {
    final q = _sentences[_currentQuestionIndex];
    setState(() {
      _selectedWords = [];
      _shuffledWords = List<String>.from(q.words)..shuffle();
      _isCorrect = null;
    });
  }

  void _checkAnswer() {
    final q = _sentences[_currentQuestionIndex];
    // SỬA LỖI: Chỉ xóa khoảng trắng, giữ nguyên dấu chấm để so sánh khớp 100% mảnh ghép
    bool check = _selectedWords.join('') == q.kanji.replaceAll(' ', '');
    setState(() { _isCorrect = check; _quizResults[_currentQuestionIndex] = check; });
    _speak(q.kanji);
  }
}
