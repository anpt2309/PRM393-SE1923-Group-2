import 'package:flutter/material.dart';
import 'package:japanese_learning/data/models/grammar.dart';

class SentenceAnatomyMap extends StatelessWidget {
  final List<SentenceToken> anatomy;
  final String translation;
  final VoidCallback onPlayAudio;

  const SentenceAnatomyMap({
    super.key,
    required this.anatomy,
    required this.translation,
    required this.onPlayAudio,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.analytics_outlined,
                    color: Color(0xFF1A237E),
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Giải phẫu câu mẫu',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPlayAudio,
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9800).withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.volume_up,
                      color: Color(0xFFFF9800),
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Horizontal Anatomy Mapping
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: anatomy.map((token) {
                  final isTarget = token.isTargetPattern;
                  return Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Word Chunk
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isTarget
                                ? const Color(0xFFFF9800)
                                : (isDark ? const Color(0xFF2D2D3F) : const Color(0xFFF0F4F8)),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: isTarget
                                ? [
                                    BoxShadow(
                                      color: const Color(0xFFFF9800).withValues(alpha: 0.3),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    )
                                  ]
                                : null,
                          ),
                          child: Text(
                            token.text,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isTarget
                                  ? Colors.white
                                  : (isDark ? Colors.white : const Color(0xFF1A237E)),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                        // Pointer Line
                        Container(
                          height: 14,
                          width: 2,
                          color: isTarget
                              ? const Color(0xFFFF9800).withValues(alpha: 0.5)
                              : (isDark ? Colors.white24 : Colors.grey.shade300),
                        ),
                        // Label badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isTarget
                                ? const Color(0xFFFF9800).withValues(alpha: 0.08)
                                : (isDark ? Colors.white10 : Colors.grey.shade100),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: isTarget
                                  ? const Color(0xFFFF9800).withValues(alpha: 0.4)
                                  : Colors.transparent,
                              width: 1,
                            ),
                          ),
                          child: Text(
                            token.grammaticalRole,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isTarget
                                  ? const Color(0xFFFF9800)
                                  : (isDark ? Colors.white54 : Colors.grey.shade600),
                              fontFamily: 'Inter',
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Vietnamese Translation
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF161622) : const Color(0xFFF9F9F9),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? Colors.white10 : Colors.grey.shade100,
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ý nghĩa câu mẫu:',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white30 : Colors.grey.shade400,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  translation,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white70 : Colors.grey.shade700,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
