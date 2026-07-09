import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanese_learning/data/models/vocabulary.dart';
import 'package:japanese_learning/providers/vocab_provider.dart';
import 'package:japanese_learning/views/vocab/vocab_detail_screen.dart';
import 'package:japanese_learning/views/vocab/widgets/level_selector.dart';
import 'package:japanese_learning/views/vocab/widgets/search_filter_row.dart';

// ─────────────────────────────────────────────────────────────
// VOCAB STUDY SCREEN (JLPT Vocabulary - Lessons / Words Selector)
// ─────────────────────────────────────────────────────────────

class VocabStudyScreen extends ConsumerStatefulWidget {
  const VocabStudyScreen({super.key});

  @override
  ConsumerState<VocabStudyScreen> createState() => _VocabStudyScreenState();
}

class _VocabStudyScreenState extends ConsumerState<VocabStudyScreen> {
  String _searchQuery = '';
  String _filterStatus = 'all'; // 'all', 'unmastered', 'mastered'

  @override
  Widget build(BuildContext context) {
    final studyState = ref.watch(vocabStudyProvider);
    final currentLevel = studyState.selectedLevel;
    final levelState = studyState.levels[currentLevel]!;
    final lessons = levelState.lessons;
    final selectedLessonId = levelState.selectedLessonId;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5);

    // Get selected lesson
    final VocabularyLesson? selectedLesson = selectedLessonId != null
        ? lessons.firstWhere((l) => l.id == selectedLessonId)
        : null;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: const Text(
          'Từ Vựng JLPT',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ─── Level Selector (N5 - N1 Tabs) ───
          if (selectedLesson == null)
            LevelSelector(
              selectedLevel: currentLevel,
              onSelected: (lvl) {
                ref.read(vocabStudyProvider.notifier).selectLevel(lvl);
                ref.read(vocabStudyProvider.notifier).clearLessonSelection();
              },
            ),

          // If NO lesson selected, show Lessons list
          if (selectedLesson == null)
            Expanded(
              child: levelState.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF9800),
                      ),
                    )
                  : lessons.isEmpty
                      ? Center(
                          child: Text(
                            'Không có bài học nào cho cấp độ này.',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              color: isDark ? Colors.white60 : Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          physics: const BouncingScrollPhysics(),
                          itemCount: lessons.length,
                          itemBuilder: (context, index) {
                            final lesson = lessons[index];
                            // Calculate lesson progress
                            final masteredCount = lesson.words.where((w) => w.isMastered).length;
                            final totalCount = lesson.words.length;
                            final progressPercent = totalCount > 0 ? masteredCount / totalCount : 0.0;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: isDark ? Colors.white10 : Colors.grey.shade200,
                                  width: 1,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                onTap: () {
                                  ref.read(vocabStudyProvider.notifier).selectLesson(lesson.id);
                                },
                                leading: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A237E).withValues(alpha: 0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.import_contacts,
                                    color: Color(0xFF1A237E),
                                    size: 24,
                                  ),
                                ),
                                title: Text(
                                  lesson.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? Colors.white : const Color(0xFF1A237E),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ClipRRect(
                                            borderRadius: BorderRadius.circular(3),
                                            child: LinearProgressIndicator(
                                              value: progressPercent,
                                              backgroundColor: isDark ? Colors.white12 : Colors.grey.shade200,
                                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFF9800)),
                                              minHeight: 5,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          '$masteredCount/$totalCount đã thuộc',
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                            color: isDark ? Colors.white60 : Colors.grey.shade600,
                                            fontFamily: 'Inter',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Icon(
                                  Icons.chevron_right,
                                  color: isDark ? Colors.white30 : Colors.grey.shade400,
                                ),
                              ),
                            );
                          },
                        ),
            )
          else ...[
            // ─── Header: Lesson Title & Back to Lessons list ───
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      ref.read(vocabStudyProvider.notifier).clearLessonSelection();
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white10 : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        size: 16,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      selectedLesson.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF1A237E),
                        fontFamily: 'Inter',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),

            // ─── Search Bar & Filter Row ───
            SearchAndFilterRow(
              onQueryChanged: (query) {
                setState(() {
                  _searchQuery = query;
                });
              },
              onFilterChanged: (filter) {
                setState(() {
                  _filterStatus = filter;
                });
              },
            ),

            // ─── Vocabulary ListView ───
            Expanded(
              child: levelState.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFFFF9800),
                      ),
                    )
                  : _buildVocabularyList(selectedLesson, isDark),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVocabularyList(VocabularyLesson lesson, bool isDark) {
    final allWords = lesson.words;

    // Filter words based on search query and status chip
    final filteredWords = allWords.where((w) {
      final matchesQuery = _searchQuery.isEmpty ||
          w.word.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          w.hiragana.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          w.romaji.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          w.vietnameseMeaning.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesStatus = _filterStatus == 'all' ||
          (_filterStatus == 'mastered' && w.isMastered) ||
          (_filterStatus == 'unmastered' && !w.isMastered);

      return matchesQuery && matchesStatus;
    }).toList();

    if (filteredWords.isEmpty) {
      return Center(
        child: Text(
          'Không tìm thấy từ vựng nào.',
          style: TextStyle(
            fontFamily: 'Inter',
            color: isDark ? Colors.white60 : Colors.grey.shade600,
            fontSize: 14,
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 20, top: 4),
      physics: const BouncingScrollPhysics(),
      itemCount: filteredWords.length,
      itemBuilder: (context, idx) {
        final word = filteredWords[idx];
        final originalIndex = allWords.indexOf(word);

        return VocabularyCard(
          word: word,
          index: originalIndex,
          onTap: () {
            // Navigate to Vocabulary Detail Screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VocabDetailScreen(
                  lessonId: lesson.id,
                  initialIndex: originalIndex,
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────
// VOCABULARY CARD LIST ITEM
// ─────────────────────────────────────────────────────────────

class VocabularyCard extends ConsumerWidget {
  final VocabularyWord word;
  final int index;
  final VoidCallback onTap;

  const VocabularyCard({
    super.key,
    required this.word,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isFavorited = ref.watch(vocabStudyProvider).favoriteVocabIds.contains(word.id);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Left side: Vocabulary word + Hiragana/Romaji underneath
                Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        word.word,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1A237E),
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${word.hiragana} / ${word.romaji}',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white60 : Colors.grey.shade500,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ],
                  ),
                ),
                // Center side: Brief meaning
                Expanded(
                  flex: 3,
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      word.vietnameseMeaning,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white.withValues(alpha: 0.9) : Colors.black87,
                        fontFamily: 'Inter',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
                // Right side: Navigation arrow or favorite star
                Expanded(
                  flex: 2,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(
                        isFavorited ? Icons.star : Icons.star_border,
                        color: isFavorited ? Colors.amber : (isDark ? Colors.white30 : Colors.grey.shade400),
                        size: 28,
                      ),
                      onPressed: () {
                        ref.read(vocabStudyProvider.notifier).toggleFavorite(word.id);
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
