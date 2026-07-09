import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanese_learning/data/models/kanji.dart';
import 'package:japanese_learning/providers/kanji_provider.dart';
import 'widgets/kanji_stroke_canvas.dart';
import 'widgets/kanji_radical_decomposition.dart';
import 'widgets/kanji_readings_matrix.dart';
import 'widgets/kanji_bottom_nav.dart';

class KanjiSpeechHelper {
  static final KanjiSpeechHelper instance = KanjiSpeechHelper._();
  KanjiSpeechHelper._() {
    _initTts();
  }

  final FlutterTts _flutterTts = FlutterTts();
  bool _isReady = false;

  Future<void> _initTts() async {
    try {
      await _flutterTts.setLanguage("ja-JP");
      await _flutterTts.setSpeechRate(0.5); // 1X Speed
      await _flutterTts.setVolume(1.0);
      await _flutterTts.setPitch(1.0);
      _isReady = true;
    } catch (e) {
      debugPrint("Kanji TTS initialization failed: $e");
    }
  }

  Future<void> speak(String text) async {
    if (!_isReady) return;
    try {
      await _flutterTts.setLanguage("ja-JP");
      await _flutterTts.setSpeechRate(0.5); // 1X Speed
      await _flutterTts.speak(text);
    } catch (e) {
      debugPrint("Kanji TTS speaking error: $e");
    }
  }
}

class KanjiStudyScreen extends ConsumerStatefulWidget {
  const KanjiStudyScreen({super.key});

  @override
  ConsumerState<KanjiStudyScreen> createState() => _KanjiStudyScreenState();
}

class _KanjiStudyScreenState extends ConsumerState<KanjiStudyScreen> {
  int _activeStrokeIndex = -1; // -1 means show all strokes normally
  Timer? _strokeTimer;

  @override
  void dispose() {
    _strokeTimer?.cancel();
    super.dispose();
  }

  void _startStrokeAnimation(List<KanjiStrokeBadge> badges) {
    _strokeTimer?.cancel();
    ref.read(kanjiStudyProvider.notifier).setPlayingAnimation(true);
    setState(() {
      _activeStrokeIndex = 0;
    });

    _strokeTimer = Timer.periodic(const Duration(milliseconds: 700), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      if (_activeStrokeIndex < badges.length - 1) {
        setState(() {
          _activeStrokeIndex++;
        });
      } else {
        timer.cancel();
        ref.read(kanjiStudyProvider.notifier).setPlayingAnimation(false);
        setState(() {
          _activeStrokeIndex = -1; // Reset to normal
        });
      }
    });
  }

  void _stopStrokeAnimation() {
    _strokeTimer?.cancel();
    ref.read(kanjiStudyProvider.notifier).setPlayingAnimation(false);
    setState(() {
      _activeStrokeIndex = -1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(kanjiStudyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // Curated color palette
    const cobaltBlue = Color(0xFF1A237E);
    const accentOrange = Color(0xFFFF9800);
    final scaffoldBg = isDark ? const Color(0xFF12121A) : const Color(0xFFF7F8FC);
    final cardBg = isDark ? const Color(0xFF1E1E2F) : Colors.white;
    final textPrimary = isDark ? Colors.white : const Color(0xFF1A237E);
    final textSecondary = isDark ? Colors.white60 : Colors.grey.shade700;

    final showDetail = state.selectedKanjiChar != null;
    final kanji = state.currentKanji;
    final levelKanji = state.currentLevelKanji;

    return Scaffold(
      backgroundColor: scaffoldBg,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (showDetail) {
              ref.read(kanjiStudyProvider.notifier).clearSelectedKanji();
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        title: Text(
          showDetail ? 'Chi tiết chữ Hán' : 'Học Chữ Hán JLPT',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontFamily: 'Inter',
          ),
        ),
        backgroundColor: cobaltBlue,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ─── Level Selector Pill Tabs (Only show on Grid View) ───
          if (!showDetail)
            _buildLevelSelector(state, cobaltBlue, isDark),

          // ─── Main Content Area ───
          Expanded(
            child: state.isLoading && levelKanji.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(
                      color: cobaltBlue,
                    ),
                  )
                : (state.errorMessage != null && levelKanji.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_off, size: 48, color: Colors.grey.shade400),
                              const SizedBox(height: 12),
                              Text(
                                state.errorMessage!,
                                style: TextStyle(color: textSecondary, fontFamily: 'Inter'),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: cobaltBlue,
                                  foregroundColor: Colors.white,
                                ),
                                onPressed: () {
                                  ref.read(kanjiStudyProvider.notifier).loadKanjiForLevel(state.selectedLevel);
                                },
                                child: const Text('Thử lại', style: TextStyle(fontFamily: 'Inter')),
                              ),
                            ],
                          ),
                        ),
                      )
                    : (!showDetail
                        ? _buildKanjiGrid(levelKanji, isDark, cardBg, textPrimary, textSecondary, accentOrange)
                        : (kanji == null
                            ? Center(
                                child: Text(
                                  'Không tìm thấy thông tin chữ Hán.',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    color: textSecondary,
                                  ),
                                ),
                              )
                            : SingleChildScrollView(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    // ─── Kanji Stroke Canvas & Controls ───
                                    KanjiStrokeCanvas(
                                      kanji: kanji,
                                      isDark: isDark,
                                      containerBg: cardBg,
                                      textPrimary: textPrimary,
                                      accentOrange: accentOrange,
                                      activeStrokeIndex: _activeStrokeIndex,
                                    ),
                                    const SizedBox(height: 12),
                                    _buildCanvasControls(kanji, state, accentOrange, isDark),
                                    const SizedBox(height: 20),

                                    // ─── Radical Decomposition Section ───
                                    KanjiRadicalDecomposition(
                                      kanji: kanji,
                                      isDark: isDark,
                                      cardBg: cardBg,
                                      textPrimary: textPrimary,
                                      textSecondary: textSecondary,
                                    ),
                                    const SizedBox(height: 20),

                                    // ─── Onyomi & Kunyomi Reading Matrix ───
                                    KanjiReadingsMatrix(
                                      kanji: kanji,
                                      isDark: isDark,
                                      cardBg: cardBg,
                                      textPrimary: textPrimary,
                                      textSecondary: textSecondary,
                                    ),
                                    const SizedBox(height: 24),
                                  ],
                                ),
                              )))),
          ),

          // ─── Bottom Navigation Panel (Only show on Detail View) ───
          if (showDetail && kanji != null)
            KanjiBottomNav(
              kanji: kanji,
              state: state,
              totalCount: levelKanji.length,
              isDark: isDark,
              containerBg: cardBg,
              textPrimary: textPrimary,
              accentOrange: accentOrange,
              onPrevious: () {
                _stopStrokeAnimation();
                ref.read(kanjiStudyProvider.notifier).previousKanji();
              },
              onNext: () {
                _stopStrokeAnimation();
                ref.read(kanjiStudyProvider.notifier).nextKanji();
              },
            ),
        ],
      ),
    );
  }

  // ─── WIDGET BUILDERS ───

  Widget _buildLevelSelector(KanjiStudyState state, Color activeColor, bool isDark) {
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
                    _stopStrokeAnimation();
                    ref.read(kanjiStudyProvider.notifier).selectLevel(lvl);
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildKanjiGrid(
    List<KanjiModel> kanjiList,
    bool isDark,
    Color cardBg,
    Color textPrimary,
    Color textSecondary,
    Color accentOrange,
  ) {
    if (kanjiList.isEmpty) {
      return Center(
        child: Text(
          'Không có chữ Hán nào cho cấp độ này.',
          style: TextStyle(
            fontFamily: 'Inter',
            color: textSecondary,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: kanjiList.length,
      itemBuilder: (context, index) {
        final item = kanjiList[index];
        return InkWell(
          onTap: () {
            ref.read(kanjiStudyProvider.notifier).selectKanji(item.kanji);
            KanjiSpeechHelper.instance.speak(item.kanji);
          },
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.grey.shade200,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 6,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                if (item.isMastered)
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Icon(
                      Icons.check_circle,
                      color: accentOrange,
                      size: 14,
                    ),
                  ),
                Align(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        item.kanji,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: textPrimary,
                          fontFamily: 'Sawarabi Mincho',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.hanViet,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: textSecondary,
                          fontFamily: 'Inter',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCanvasControls(
    KanjiModel kanji,
    KanjiStudyState state,
    Color activeColor,
    bool isDark,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Play Stroke Animation Button
        _buildFloatingActionButton(
          icon: state.isPlayingAnimation ? Icons.stop_circle : Icons.play_circle_outline,
          label: state.isPlayingAnimation ? 'Dừng' : 'Vẽ nét',
          color: activeColor,
          isDark: isDark,
          onPressed: () {
            if (state.isPlayingAnimation) {
              _stopStrokeAnimation();
            } else {
              _startStrokeAnimation(kanji.strokeBadges);
            }
          },
        ),
        const SizedBox(width: 16),
        // Text-to-Speech Audio Button
        _buildFloatingActionButton(
          icon: Icons.volume_up,
          label: 'Phát âm',
          color: const Color(0xFF1A237E),
          isDark: isDark,
          onPressed: () {
            KanjiSpeechHelper.instance.speak(kanji.kanji);
          },
        ),
      ],
    );
  }

  Widget _buildFloatingActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required bool isDark,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        elevation: 1,
        backgroundColor: isDark ? const Color(0xFF2A2A3E) : Colors.white,
        foregroundColor: color,
        side: BorderSide(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
      icon: Icon(icon, size: 20, color: color),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}
