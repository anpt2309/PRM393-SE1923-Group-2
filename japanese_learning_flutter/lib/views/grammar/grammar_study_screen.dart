import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanese_learning/data/models/grammar.dart';
import 'package:japanese_learning/providers/grammar_provider.dart';
import 'widgets/grammar_formula_blueprint.dart';
import 'widgets/sentence_anatomy_map.dart';
import 'widgets/nuance_context_meter.dart';
import 'widgets/grammar_bottom_nav.dart';

// ─────────────────────────────────────────────────────────────
// GRAMMAR TTS SPEECH HELPER
// ─────────────────────────────────────────────────────────────
class GrammarSpeechHelper {
  static final GrammarSpeechHelper instance = GrammarSpeechHelper._();
  GrammarSpeechHelper._() {
    _initTts();
  }

  final FlutterTts _flutterTts = FlutterTts();
  bool _isReady = false;

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage("ja-JP");
      await _flutterTts.setSpeechRate(1); // 1X Speed
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      _isReady = true;
    } catch (e) {
      debugPrint("Grammar TTS initialization failed: $e");
    }
  }
// doc van ban bang giong noi
  Future<void> speak(String text) async {
    if (!_isReady) return;
    try {
      await _flutterTts.setLanguage("ja-JP");
      await _flutterTts.setSpeechRate(1); // 1X Speed
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint("Grammar TTS speaking error: $e");
    }
  }
}

// ─────────────────────────────────────────────────────────────
// GRAMMAR STUDY SCREEN
// ─────────────────────────────────────────────────────────────
class GrammarStudyScreen extends ConsumerStatefulWidget {
  const GrammarStudyScreen({super.key});

  @override
  ConsumerState<GrammarStudyScreen> createState() => _GrammarStudyScreenState();
}

class _GrammarStudyScreenState extends ConsumerState<GrammarStudyScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(grammarStudyProvider);
    final levelGrammars = state.currentLevelGrammars;
    final activeGrammar = state.selectedGrammar;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5);
    final cardBg = isDark ? const Color(0xFF1E1E2F) : Colors.white;

    final Color primaryCobalt = const Color(0xFF1A237E);

    final showDetail = activeGrammar != null;

    Widget bodyContent;
    if (state.isLoading && levelGrammars.isEmpty) {
      bodyContent = const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF1A237E),
        ),
      );
    } else if (state.errorMessage != null && levelGrammars.isEmpty) {
      bodyContent = Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                state.errorMessage!,
                style: TextStyle(
                  color: isDark ? Colors.white60 : Colors.grey.shade700,
                  fontFamily: 'Inter',
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1A237E),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  ref.read(grammarStudyProvider.notifier).loadGrammarForLevel(state.selectedLevel);
                },
                child: const Text('Thử lại', style: TextStyle(fontFamily: 'Inter')),
              ),
            ],
          ),
        ),
      );
    } else if (levelGrammars.isEmpty) {
      bodyContent = _buildEmptyState(isDark);
    } else if (!showDetail) {
      bodyContent = _buildGrammarListView(levelGrammars, cardBg, isDark, primaryCobalt);
    } else {
      bodyContent = SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            const SizedBox(height: 12),
            // Grammar Pattern Info Box
            _buildPatternHeaderCard(activeGrammar, cardBg, isDark, primaryCobalt),

            // Grammar Formula Blueprint Widget
            GrammarFormulaBlueprint(
              formula: activeGrammar.formula,
              meaning: activeGrammar.meaning,
            ),

            // Sentence Anatomy Map Widget
            SentenceAnatomyMap(
              anatomy: activeGrammar.exampleAnatomy,
              translation: activeGrammar.translation,
              onPlayAudio: () {
                GrammarSpeechHelper.instance.speak(activeGrammar.exampleSentence);
              },
            ),

            // Nuance Context Meter Widget
            NuanceContextMeter(
              nuance: activeGrammar.formalityNuance,
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        title: Text(
          showDetail ? activeGrammar.pattern : 'Ngữ Pháp JLPT',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: showDetail
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  ref.read(grammarStudyProvider.notifier).clearGrammarSelection();
                },
              )
            : null,
        backgroundColor: primaryCobalt,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (showDetail && levelGrammars.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.format_list_bulleted),
              tooltip: 'Danh sách cấu trúc',
              onPressed: () {
                _scaffoldKey.currentState?.openEndDrawer();
              },
            ),
        ],
      ),
      endDrawer: showDetail
          ? _buildGrammarListDrawer(state, levelGrammars, cardBg, isDark, primaryCobalt)
          : null,
      body: Column(
        children: [
          // ─── Level Pill Tabs (Only show in List View) ───
          if (!showDetail)
            _buildLevelSelector(state, primaryCobalt, isDark),

          // ─── Main Content ───
          Expanded(
            child: bodyContent,
          ),

          // ─── Bottom Navigation Panel ───
          if (showDetail && levelGrammars.isNotEmpty)
            GrammarBottomNav(
              onPrevious: state.selectedGrammarIndex > 0
                  ? () => ref.read(grammarStudyProvider.notifier).previousGrammar()
                  : null,
              onNext: state.selectedGrammarIndex < levelGrammars.length - 1
                  ? () => ref.read(grammarStudyProvider.notifier).nextGrammar()
                  : null,
              progressText: '${state.selectedGrammarIndex + 1}/${levelGrammars.length}',
            ),
        ],
      ),
    );
  }

  Widget _buildGrammarListView(
    List<GrammarModel> levelGrammars,
    Color cardBg,
    bool isDark,
    Color primaryCobalt,
  ) {
    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: levelGrammars.length,
      itemBuilder: (context, index) {
        final grammar = levelGrammars[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.white10 : Colors.grey.shade200,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                ref.read(grammarStudyProvider.notifier).selectGrammar(grammar.id);
                GrammarSpeechHelper.instance.speak(grammar.pattern);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    // Level badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: primaryCobalt.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        grammar.level,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: primaryCobalt,
                          fontFamily: 'Inter',
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Pattern and meaning
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            grammar.pattern,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : const Color(0xFF1C1C28),
                              fontFamily: 'Inter',
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            grammar.meaning,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white54 : Colors.grey.shade600,
                              fontFamily: 'Inter',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Trailing icon
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (grammar.isMastered)
                          const Icon(
                            Icons.star,
                            color: Color(0xFFFF9800),
                            size: 20,
                          ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.chevron_right,
                          color: isDark ? Colors.white30 : Colors.grey.shade400,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── UI COMPONENTS ───

  Widget _buildLevelSelector(GrammarStudyState state, Color activeColor, bool isDark) {
    final levels = ['N5', 'N4', 'N3', 'N2', 'N1'];
    return Container(
      width: double.infinity,
      color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: levels.map((lvl) {
            final isActive = state.selectedLevel == lvl;
            return Container(
              margin: const EdgeInsets.only(right: 10),
              child: ChoiceChip(
                label: Text(
                  lvl,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Inter',
                    color: isActive ? Colors.white : (isDark ? Colors.white70 : activeColor),
                  ),
                ),
                selected: isActive,
                onSelected: (selected) {
                  if (selected) {
                    ref.read(grammarStudyProvider.notifier).selectLevel(lvl);
                  }
                },
                selectedColor: activeColor,
                backgroundColor: isDark ? const Color(0xFF2A2A3E) : Colors.grey.shade100,
                checkmarkColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isActive ? activeColor : (isDark ? Colors.white10 : Colors.grey.shade300),
                    width: 1,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildPatternHeaderCard(GrammarModel activeGrammar, Color cardBg, bool isDark, Color cobalt) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A237E).withValues(alpha: 0.6), const Color(0xFF1E1E2F)]
              : [const Color(0xFF1A237E), const Color(0xFF283593)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  activeGrammar.level,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              if (activeGrammar.isMastered)
                const Icon(
                  Icons.star,
                  color: Color(0xFFFF9800),
                  size: 24,
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            activeGrammar.pattern,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ý nghĩa: ${activeGrammar.meaning}',
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.9),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.menu_book,
            size: 64,
            color: isDark ? Colors.white24 : Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'Không có cấu trúc ngữ pháp nào.',
            style: TextStyle(
              fontSize: 15,
              color: isDark ? Colors.white60 : Colors.grey.shade600,
              fontFamily: 'Inter',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrammarListDrawer(
    GrammarStudyState state,
    List<GrammarModel> grammars,
    Color cardBg,
    bool isDark,
    Color primaryColor,
  ) {
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF5F5F5),
      child: Column(
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: primaryColor,
            ),
            child: const Center(
              child: Text(
                'Danh Sách Cấu Trúc',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: grammars.length,
              itemBuilder: (context, index) {
                final grammar = grammars[index];
                final isSelected = state.selectedGrammarId == grammar.id ||
                    (state.selectedGrammarId == null && index == 0);

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? primaryColor.withValues(alpha: 0.08)
                        : (isDark ? const Color(0xFF1E1E2F) : Colors.white),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected ? primaryColor : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  child: ListTile(
                    title: Text(
                      grammar.pattern,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Inter',
                        color: isSelected
                            ? primaryColor
                            : (isDark ? Colors.white : Colors.black87),
                      ),
                    ),
                    subtitle: Text(
                      grammar.meaning,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        color: isDark ? Colors.white54 : Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    trailing: grammar.isMastered
                        ? const Icon(Icons.star, color: Color(0xFFFF9800), size: 20)
                        : null,
                    onTap: () {
                      ref.read(grammarStudyProvider.notifier).selectGrammar(grammar.id);
                      Navigator.of(context).pop(); // Close drawer
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
