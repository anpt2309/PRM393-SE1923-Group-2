import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanese_learning/data/models/vocabulary.dart';
import 'package:japanese_learning/providers/vocab_provider.dart';
import 'package:japanese_learning/views/vocab/widgets/cluster_map_widget.dart';

// ─────────────────────────────────────────────────────────────
// VOCABULARY DETAIL SCREEN
// ─────────────────────────────────────────────────────────────

class VocabDetailScreen extends ConsumerStatefulWidget {
  final String? lessonId;
  final int? initialIndex;
  final VocabularyWord? singleWord;

  const VocabDetailScreen({
    super.key,
    this.lessonId,
    this.initialIndex,
    this.singleWord,
  });

  @override
  ConsumerState<VocabDetailScreen> createState() => _VocabDetailScreenState();
}

class _VocabDetailScreenState extends ConsumerState<VocabDetailScreen> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.singleWord != null ? 0 : (widget.initialIndex ?? 0));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<VocabularyWord> words;
    if (widget.singleWord != null) {
      words = [widget.singleWord!];
    } else {
      final studyState = ref.watch(vocabStudyProvider);
      final currentLevel = studyState.selectedLevel;
      final levelState = studyState.levels[currentLevel]!;
      final lesson = levelState.lessons.firstWhere((l) => l.id == widget.lessonId);
      words = lesson.words;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5);

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: const Text(
          'Chi tiết từ vựng',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Quay lại danh sách từ vựng',
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: words.length,
        itemBuilder: (context, idx) {
          final word = words[idx];
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      // Visual Cluster Map Layout
                      ClusterMapWidget(
                        word: word,
                        onPlayWord: () {
                          VocabSpeechHelper.instance.speakJapanese(word.word, rate: 1);
                        },
                      ),
                      const SizedBox(height: 16),
                      // Interactive Contextual Section (includes Hiragana reading)
                      ContextExampleCard(
                        word: word,
                        onPlaySentence: () {
                          VocabSpeechHelper.instance.speakJapanese(word.exampleSentenceJa, rate: 1);
                        },
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// CONTEXTUAL EXAMPLE CARD
// ─────────────────────────────────────────────────────────────

class ContextExampleCard extends StatelessWidget {
  final VocabularyWord word;
  final VoidCallback onPlaySentence;

  const ContextExampleCard({
    super.key,
    required this.word,
    required this.onPlaySentence,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade100,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: Color(0xFFFF9800),
                size: 18,
              ),
              const SizedBox(width: 5),
              const Text(
                'Ví dụ thực tế',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                  fontFamily: 'Inter',
                ),
              ),
              const Spacer(),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: onPlaySentence,
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800).withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.volume_up,
                      color: Color(0xFFFF9800),
                      size: 18,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildHighlightedSentence(word.exampleSentenceJa, word.word, context),
          const SizedBox(height: 3),
          // Hiragana version of the example sentence for beginner/intermediate clarity
          Text(
            word.exampleSentenceJaHira,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white54 : Colors.grey.shade600,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            word.exampleSentenceVi,
            style: TextStyle(
              fontSize: 12,
              color: isDark ? Colors.white70 : Colors.grey.shade600,
              fontStyle: FontStyle.italic,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedSentence(String sentence, String target, BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseStyle = TextStyle(
      fontSize: 15,
      height: 1.4,
      fontWeight: FontWeight.w500,
      color: isDark ? Colors.white : Colors.black87,
      fontFamily: 'Inter',
    );
    final highlightStyle = const TextStyle(
      fontSize: 15,
      height: 1.4,
      fontWeight: FontWeight.bold,
      color: Color(0xFFFF9800), // Accent Orange
      fontFamily: 'Inter',
      decoration: TextDecoration.underline,
      decorationColor: Color(0xFFFF9800),
    );

    // Simple robust highlight logic
    if (target.isEmpty || !sentence.contains(target)) {
      return Text(sentence, style: baseStyle);
    }

    final parts = sentence.split(target);
    final spans = <TextSpan>[];

    for (int i = 0; i < parts.length; i++) {
      spans.add(TextSpan(text: parts[i], style: baseStyle));
      if (i < parts.length - 1) {
        spans.add(TextSpan(text: target, style: highlightStyle));
      }
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}


