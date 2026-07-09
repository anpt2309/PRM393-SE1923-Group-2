import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanese_learning/data/models/vocabulary.dart';
import 'package:japanese_learning/providers/vocab_provider.dart';

class VocabSearchDetailScreen extends ConsumerWidget {
  final VocabularyWord word;

  const VocabSearchDetailScreen({super.key, required this.word});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF121212) : const Color(0xFFF4F6F9);
    final cardBg = isDark ? const Color(0xFF1E1E2F) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    final speechHelper = ref.read(vocabSpeechHelperProvider);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // 1. Sleek Gradient Hero AppBar
          SliverAppBar(
            expandedHeight: 200.0,
            pinned: true,
            backgroundColor: const Color(0xFF1A237E),
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF1A237E), Color(0xFF283593), Color(0xFF3F51B5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 24),
                      // Japanese Word
                      Text(
                        word.word,
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontFamily: 'Inter',
                          shadows: [
                            Shadow(
                              color: Colors.black26,
                              offset: Offset(0, 2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Pronunciation
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${word.hiragana} | ${word.romaji}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.volume_up, size: 28),
                color: const Color(0xFFFF9800),
                onPressed: () {
                  speechHelper.speakJapanese(word.word, rate: 1);
                },
              ),
              const SizedBox(width: 8),
            ],
          ),

          // 2. Main Content List
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Badges (Word Type / Accent) ---
                    Row(
                      children: [
                        if (word.wordType.isNotEmpty)
                          _buildBadge(
                            word.wordType,
                            const Color(0xFF1A237E),
                            isDark,
                          ),
                        const SizedBox(width: 8),
                        if (word.pitchAccent.isNotEmpty)
                          _buildBadge(
                            word.pitchAccent,
                            const Color(0xFFFF9800),
                            isDark,
                          ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- Definition Card ---
                    _buildSectionHeader('Ý NGHĨA TIẾNG VIỆT', Icons.translate, isDark),
                    const SizedBox(height: 8),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          if (!isDark)
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.03),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                        ],
                      ),
                      child: Text(
                        word.vietnameseMeaning,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isDark ? const Color(0xFFFFB74D) : const Color(0xFFE65100),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- Collocations / Phrases ---
                    if (word.collocations.isNotEmpty) ...[
                      _buildSectionHeader('CỤM TỪ ĐI KÈM (COLLOCATIONS)', Icons.layers_outlined, isDark),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            if (!isDark)
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: Column(
                          children: word.collocations.map((item) {
                            final parts = item.split('(');
                            final jaPart = parts[0].trim();
                            final viPart = parts.length > 1 ? parts[1].replaceAll(')', '').trim() : '';

                            return InkWell(
                              onTap: () {
                                speechHelper.speakJapanese(jaPart, rate: 1);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                      color: isDark ? Colors.white10 : Colors.grey.shade100,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.volume_up, size: 18, color: Colors.grey),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            jaPart,
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: textColor,
                                            ),
                                          ),
                                          if (viPart.isNotEmpty) ...[
                                            const SizedBox(height: 4),
                                            Text(
                                              viPart,
                                              style: TextStyle(
                                                fontSize: 13,
                                                color: isDark ? Colors.white60 : Colors.black54,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // --- Context Example ---
                    if (word.exampleSentenceJa.isNotEmpty) ...[
                      _buildSectionHeader('VÍ DỤ NGỮ CẢNH (CONTEXT EXAMPLE)', Icons.notes_outlined, isDark),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            if (!isDark)
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.03),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: _highlightSentence(
                                    word.exampleSentenceJa,
                                    word.word,
                                    isDark ? Colors.white : Colors.black87,
                                    const Color(0xFFFF9800),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.volume_up, color: Color(0xFF1A237E)),
                                  onPressed: () {
                                    speechHelper.speakJapanese(word.exampleSentenceJa, rate: 1);
                                  },
                                ),
                              ],
                            ),
                            if (word.exampleSentenceJaHira.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                word.exampleSentenceJaHira,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                            const Divider(height: 24),
                            Text(
                              word.exampleSentenceVi,
                              style: TextStyle(
                                fontSize: 14,
                                color: isDark ? Colors.white70 : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF1A237E)),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
      ],
    );
  }

  Widget _buildBadge(String text, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? color.withValues(alpha: 0.15) : color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? color.withValues(alpha: 0.3) : color.withValues(alpha: 0.2),
        ),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isDark ? color.withValues(alpha: 0.9) : color,
        ),
      ),
    );
  }

  Widget _highlightSentence(String sentence, String target, Color baseColor, Color highlightColor) {
    final baseStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: baseColor,
      height: 1.4,
    );
    final highlightStyle = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: highlightColor,
      decoration: TextDecoration.underline,
      height: 1.4,
    );

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
