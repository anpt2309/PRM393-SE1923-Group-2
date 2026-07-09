import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../providers/app_setting_provider.dart';
import '../../../providers/sentence_provider.dart';
import '../../../widgets/app_bar.dart';
import '../../../widgets/add_menu_button.dart';
import '../../data/models/sentence_group.dart';

class SentenceScreen extends ConsumerStatefulWidget {
  const SentenceScreen({super.key});

  @override
  ConsumerState<SentenceScreen> createState() => _SentenceScreenState();
}

class _SentenceScreenState extends ConsumerState<SentenceScreen> with SingleTickerProviderStateMixin {
  final FlutterTts _flutterTts = FlutterTts();
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        _loadInitialData();
      }
    });
    _initTts();
    // Load initial data for the current active tab
    Future.microtask(() => _loadInitialData());
  }

  void _initTts() async {
    await _flutterTts.setLanguage("ja-JP");
    await _flutterTts.setSpeechRate(1);
    await _flutterTts.setVolume(1.0);
  }

  void _loadInitialData() {
    final type = _tabController.index == 0 ? SentenceGroupType.DISCOVERY : SentenceGroupType.CHALLENGE;
    ref.read(sentenceProvider.notifier).loadInitialData(type);
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
    final sentenceState = ref.watch(sentenceProvider);

    final isDark = settings.isDarkMode;
    final double scale = settings.textScaleFactor;

    final backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black.withValues(alpha: 0.8);
    final subTextColor = isDark ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: CustomAppBar(
        title: _getStepTitle(sentenceState),
        centerTitle: true,
        onBackPressed: sentenceState.currentStep > 0
            ? () => ref.read(sentenceProvider.notifier).goBackStep()
            : () => context.pop(),
        backgroundColor: isDark ? const Color(0xFF1A1A1A) : const Color(0xFF1976D2),
        textColor: Colors.white,
        iconColor: Colors.white,
        bottom: sentenceState.currentStep == 0
            ? TabBar(
                controller: _tabController,
                tabs: const [Tab(text: 'Khám phá (Chủ đề)'), Tab(text: 'Thử thách (JLPT)')],
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                indicatorWeight: 3,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              )
            : null,
        actions: [
          GlobalAddMenuButton(
            cardColor: cardColor,
            textColor: textColor,
            subTextColor: subTextColor,
            icon: const Icon(Icons.add, color: Colors.white, size: 26),
            onAction: (value) {
              if (value == 'settings') context.push('/profile/settings');
            },
          ),
        ],
      ),
      body: sentenceState.isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF1976D2)))
          : _buildBody(sentenceState, scale, cardColor, textColor, subTextColor, isDark),
    );
  }

  String _getStepTitle(SentenceState state) {
    switch (state.currentStep) {
      case 0:
        return state.selectedGroup?.name ?? 'Luyện mẫu câu';
      case 1:
        return 'Mẫu Câu';
      case 2:
        return 'Ghép câu';
      case 3:
        return 'Kết quả Test';
      default:
        return 'Luyện mẫu câu';
    }
  }

  Widget _buildBody(
    SentenceState state,
    double scale,
    Color cardColor,
    Color textColor,
    Color subTextColor,
    bool isDark,
  ) {
    switch (state.currentStep) {
      case 0:
        return _buildTopicMap(state, cardColor, textColor, subTextColor);
      case 1:
        return _buildSentenceList(state, cardColor, textColor, subTextColor);
      case 2:
        return _buildQuizEngine(state, scale, cardColor, textColor, subTextColor, isDark);
      case 3:
        return _buildFinalScore(state, isDark);
      default:
        return _buildTopicMap(state, cardColor, textColor, subTextColor);
    }
  }

  // --- BẢN ĐỒ BÀI HỌC ---
  Widget _buildTopicMap(
    SentenceState state,
    Color cardColor,
    Color textColor,
    Color subTextColor,
  ) {
    if (state.parts.isEmpty) {
      return Center(child: Text('Chưa có dữ liệu bài học', style: TextStyle(color: subTextColor)));
    }
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: state.parts.length,
      itemBuilder: (context, i) {
        final part = state.parts[i];
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1976D2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2.5),
                  ),
                  child: Center(child: Text(part.icon, style: const TextStyle(fontSize: 18))),
                ),
                if (i != state.parts.length - 1)
                  Container(width: 3, height: 60, color: const Color(0xFF1976D2).withValues(alpha: 0.2)),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () => ref.read(sentenceProvider.notifier).loadSentences(part),
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
  Widget _buildSentenceList(
    SentenceState state,
    Color cardColor,
    Color textColor,
    Color subTextColor,
  ) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: () => ref.read(sentenceProvider.notifier).startQuiz(false),
                icon: const Icon(Icons.auto_stories_outlined, size: 18, color: Color(0xFF1976D2)),
                label: const Text('Luyện ghép câu',
                    style: TextStyle(fontSize: 13, color: Color(0xFF1976D2), fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              TextButton.icon(
                onPressed: () => ref.read(sentenceProvider.notifier).startQuiz(true),
                icon: const Icon(Icons.shuffle, size: 18, color: Color(0xFF1976D2)),
                label: const Text('Ghép ngẫu nhiên',
                    style: TextStyle(fontSize: 13, color: Color(0xFF1976D2), fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: state.sentences.length,
            itemBuilder: (context, i) => Card(
              color: cardColor,
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.black.withValues(alpha: 0.05)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(state.sentences[i].kanji,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1976D2))),
                      const SizedBox(height: 4),
                      Text(state.sentences[i].hira, style: TextStyle(fontSize: 13, color: subTextColor)),
                      const SizedBox(height: 4),
                      Text(state.sentences[i].viet, style: TextStyle(fontSize: 14, color: textColor)),
                    ])),
                    IconButton(
                        icon: const Icon(Icons.volume_up, color: Colors.black54),
                        onPressed: () => _speak(state.sentences[i].kanji)),
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
  Widget _buildQuizEngine(
    SentenceState state,
    double scale,
    Color cardColor,
    Color textColor,
    Color subTextColor,
    bool isDark,
  ) {
    final q = state.sentences[state.currentQuestionIndex];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          SizedBox(
            height: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: (state.currentQuestionIndex + 1) / state.sentences.length,
                backgroundColor: const Color(0xFF1976D2).withValues(alpha: 0.1),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text('Câu ${state.currentQuestionIndex + 1}/${state.sentences.length}',
              style: TextStyle(color: subTextColor, fontSize: 13, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(q.viet,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF1976D2)),
              textAlign: TextAlign.center),
          const SizedBox(height: 30),
          Container(
            height: 140,
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.05) : const Color(0xFF1976D2).withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: state.isCorrect == false
                        ? Colors.red.withValues(alpha: 0.4)
                        : const Color(0xFF1976D2).withValues(alpha: 0.1))),
            child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: state.selectedWords
                    .map((w) => ActionChip(
                        label: Text(w),
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        onPressed: () => ref.read(sentenceProvider.notifier).removeWord(w)))
                    .toList()),
          ),
          const SizedBox(height: 30),
          Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: state.shuffledWords
                  .map((w) => ActionChip(
                      label: Text(w, style: const TextStyle(color: Color(0xFF1976D2))),
                      backgroundColor: cardColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      onPressed: () => ref.read(sentenceProvider.notifier).addWord(w)))
                  .toList()),
          const Spacer(),
          if (state.isCorrect != null)
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                  color: state.isCorrect! ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Icon(state.isCorrect! ? Icons.check_circle : Icons.lightbulb,
                      color: state.isCorrect! ? Colors.green : Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Text(state.isCorrect! ? 'Chính xác! 🎉' : 'Gợi ý từ Mazii:',
                      style: TextStyle(fontWeight: FontWeight.bold, color: state.isCorrect! ? Colors.green : Colors.red)),
                ]),
                if (!state.isCorrect! && q.explanation != null)
                  Padding(
                      padding: const EdgeInsets.only(top: 8, left: 28),
                      child: Text(q.explanation!,
                          style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87))),
                if (state.isCorrect!)
                  Padding(
                      padding: const EdgeInsets.only(top: 8, left: 28),
                      child: Text(q.kanji, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue))),
              ]),
            ),
          Row(
            children: [
              Expanded(
                  child: ElevatedButton(
                onPressed: state.currentQuestionIndex == 0
                    ? null
                    : () => ref.read(sentenceProvider.notifier).previousQuestion(),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade100,
                    foregroundColor: Colors.blue.shade700,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Câu trước', style: TextStyle(fontWeight: FontWeight.bold)),
              )),
              const SizedBox(width: 8),
              Expanded(
                  child: ElevatedButton(
                onPressed: state.selectedWords.isEmpty
                    ? null
                    : () => ref.read(sentenceProvider.notifier).checkAnswer(_speak),
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1976D2),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                child: const Text('Kiểm tra', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              )),
              const SizedBox(width: 8),
              Expanded(
                  child: ElevatedButton(
                onPressed: () => ref.read(sentenceProvider.notifier).nextQuestion(),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade100,
                    foregroundColor: Colors.blue.shade700,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text(state.currentQuestionIndex < state.sentences.length - 1 ? 'Câu tiếp' : 'Kết quả',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinalScore(SentenceState state, bool isDark) {
    int correct = state.quizResults.values.where((v) => v).length;
    int failed = state.quizResults.length - correct;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Tổng số câu: ${state.sentences.length} câu, đã làm ${state.quizResults.length} câu',
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
              itemCount: state.sentences.length,
              itemBuilder: (context, index) {
                final item = state.sentences[index];
                final isCorrect = state.quizResults[index];

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
              onPressed: () => ref.read(sentenceProvider.notifier).restartAllQuiz(),
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1976D2),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
              child: const Text('Làm Lại Toàn Bộ Thử Thách',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          )
        ],
      ),
    );
  }
}
