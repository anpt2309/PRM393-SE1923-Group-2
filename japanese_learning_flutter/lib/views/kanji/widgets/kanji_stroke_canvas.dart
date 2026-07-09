import 'package:flutter/material.dart';
import 'package:japanese_learning/data/models/kanji.dart';
import 'kanji_grid_painter.dart';

class KanjiStrokeCanvas extends StatelessWidget {
  final KanjiModel kanji;
  final bool isDark;
  final Color containerBg;
  final Color textPrimary;
  final Color accentOrange;
  final int activeStrokeIndex;

  const KanjiStrokeCanvas({
    super.key,
    required this.kanji,
    required this.isDark,
    required this.containerBg,
    required this.textPrimary,
    required this.accentOrange,
    required this.activeStrokeIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 220,
      decoration: BoxDecoration(
        color: containerBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: CustomPaint(
          painter: KanjiGridPainter(
            color: isDark ? Colors.white24 : Colors.grey.shade300,
          ),
          child: Stack(
            children: [
              // Faint Background Kanji Character
              Center(
                child: Text(
                  kanji.kanji,
                  style: TextStyle(
                    fontSize: 130,
                    fontFamily: 'Sawarabi Mincho',
                    color: isDark ? Colors.white12 : Colors.grey.shade100,
                  ),
                ),
              ),

              // Animated or Main Display Kanji
              Center(
                child: Text(
                  kanji.kanji,
                  style: TextStyle(
                    fontSize: 130,
                    fontFamily: 'Sawarabi Mincho',
                    color: textPrimary.withValues(
                      alpha: activeStrokeIndex != -1 ? 0.35 : 1.0,
                    ),
                  ),
                ),
              ),

              // Superimpose stroke order numbered badges
              ...List.generate(kanji.strokeBadges.length, (index) {
                final badge = kanji.strokeBadges[index];
                
                final bool isHighlighted = activeStrokeIndex == -1 || activeStrokeIndex == index;
                final double opacity = activeStrokeIndex == -1 
                    ? 1.0 
                    : (activeStrokeIndex >= index ? 1.0 : 0.15);

                return Positioned.fill(
                  child: Align(
                    alignment: Alignment(
                      (badge.x * 2) - 1.0,
                      (badge.y * 2) - 1.0,
                    ),
                    child: Opacity(
                      opacity: opacity,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: isHighlighted ? accentOrange : Colors.grey.shade400,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 3,
                              offset: const Offset(0, 1),
                            )
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          badge.number.toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
              
              // JLPT tag overlay
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A237E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    kanji.jlptLevel,
                    style: const TextStyle(
                      color: Color(0xFF1A237E),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                      fontFamily: 'Inter',
                    ),
                  ),
                ),
              ),
              
              // Han-Viet / Meaning overlay
              Positioned(
                top: 12,
                right: 12,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      kanji.hanViet,
                      style: TextStyle(
                        color: textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.0,
                        fontFamily: 'Inter',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      kanji.meaning,
                      style: TextStyle(
                        color: textPrimary.withValues(alpha: 0.7),
                        fontSize: 11,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
