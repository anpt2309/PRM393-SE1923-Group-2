import 'package:flutter/material.dart';
import 'package:japanese_learning/data/models/kanji.dart';
import 'package:japanese_learning/providers/kanji_provider.dart';

class KanjiBottomNav extends StatelessWidget {
  final KanjiModel kanji;
  final KanjiStudyState state;
  final int totalCount;
  final bool isDark;
  final Color containerBg;
  final Color textPrimary;
  final Color accentOrange;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const KanjiBottomNav({
    super.key,
    required this.kanji,
    required this.state,
    required this.totalCount,
    required this.isDark,
    required this.containerBg,
    required this.textPrimary,
    required this.accentOrange,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final int displayIndex = state.currentKanjiIndex + 1;
    final bool hasPrevious = state.currentKanjiIndex > 0;
    final bool hasNext = state.currentKanjiIndex < totalCount - 1;

    return Container(
      decoration: BoxDecoration(
        color: containerBg,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
            width: 1.5,
          ),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            '$displayIndex / $totalCount Hán tự',
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.bold,
              color: textPrimary.withValues(alpha: 0.6),
              fontFamily: 'Inter',
            ),
          ),

          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                color: hasPrevious ? const Color(0xFF1A237E) : Colors.grey.shade400,
                onPressed: hasPrevious ? onPrevious : null,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                color: hasNext ? const Color(0xFF1A237E) : Colors.grey.shade400,
                onPressed: hasNext ? onNext : null,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
