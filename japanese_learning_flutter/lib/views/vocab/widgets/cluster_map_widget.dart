import 'package:flutter/material.dart';
import 'package:japanese_learning/data/models/vocabulary.dart';

class ClusterMapWidget extends StatelessWidget {
  final VocabularyWord word;
  final VoidCallback onPlayWord;

  const ClusterMapWidget({
    super.key,
    required this.word,
    required this.onPlayWord,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: 290,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double w = constraints.maxWidth;
          final double h = constraints.maxHeight;

          final double cx = w / 2;
          final double cy = h / 2;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              // Connecting lines in the background
              Positioned.fill(
                child: CustomPaint(
                  painter: ClusterLinePainter(
                    isDark: isDark,
                    w: w,
                    h: h,
                  ),
                ),
              ),

              // 1. Center Word Card (Target Vocabulary)
              Positioned(
                left: cx - 65,
                top: cy - 40,
                child: CenterWordCard(
                  word: word.word,
                  romaji: word.romaji,
                  onPlay: onPlayWord,
                  width: 130,
                  height: 80,
                ),
              ),

              // 2. Box 1 (Top-Left): Từ loại & Trọng âm
              Positioned(
                left: w * 0.01,
                top: h * 0.04,
                child: BubbleNode(
                  title: 'Từ loại & Trọng âm',
                  content: '${word.wordType}\n${word.pitchAccent}',
                  subtitle: word.kanji.isNotEmpty ? 'Hán tự: ${word.kanji}' : null,
                  icon: Icons.g_translate,
                  color: const Color(0xFF1A237E),
                  width: w * 0.45,
                ),
              ),

              // 3. Box 2 (Top-Right): Hiragana
              Positioned(
                right: w * 0.01,
                top: h * 0.04,
                child: BubbleNode(
                  title: 'Cách đọc / Hiragana',
                  content: '${word.hiragana}\n(${word.romaji})',
                  icon: Icons.hearing,
                  color: const Color(0xFFFF9800),
                  width: w * 0.45,
                ),
              ),

              // 4. Box 3 (Bottom-Left): Ý nghĩa
              Positioned(
                left: w * 0.01,
                bottom: h * 0.04,
                child: BubbleNode(
                  title: 'Ý nghĩa',
                  content: '${word.vietnameseMeaning}\n(${word.englishMeaning})',
                  icon: Icons.translate,
                  color: Colors.green.shade700,
                  width: w * 0.45,
                ),
              ),

              // 5. Box 4 (Bottom-Right): Đi kèm / Collocation
              Positioned(
                right: w * 0.01,
                bottom: h * 0.04,
                child: BubbleNode(
                  title: 'Đi kèm / Collocation',
                  content: word.collocations.join('\n'),
                  icon: Icons.join_inner,
                  color: Colors.purple.shade700,
                  width: w * 0.45,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ClusterLinePainter extends CustomPainter {
  final bool isDark;
  final double w;
  final double h;

  ClusterLinePainter({
    required this.isDark,
    required this.w,
    required this.h,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark ? Colors.blue.withValues(alpha: 0.35) : const Color(0xFF1A237E).withValues(alpha: 0.2)
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(w / 2, h / 2);

    final topLeftDest = Offset(w * 0.01 + (w * 0.45) / 2, h * 0.04 + 30);
    final topRightDest = Offset(w - w * 0.01 - (w * 0.45) / 2, h * 0.04 + 30);
    final bottomLeftDest = Offset(w * 0.01 + (w * 0.45) / 2, h - h * 0.04 - 30);
    final bottomRightDest = Offset(w - w * 0.01 - (w * 0.45) / 2, h - h * 0.04 - 30);

    canvas.drawLine(center, topLeftDest, paint);
    canvas.drawLine(center, topRightDest, paint);
    canvas.drawLine(center, bottomLeftDest, paint);
    canvas.drawLine(center, bottomRightDest, paint);

    final accentPaint = Paint()
      ..color = const Color(0xFFFF9800)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, 4, accentPaint);
    canvas.drawCircle(topLeftDest, 3.5, accentPaint);
    canvas.drawCircle(topRightDest, 3.5, accentPaint);
    canvas.drawCircle(bottomLeftDest, 3.5, accentPaint);
    canvas.drawCircle(bottomRightDest, 3.5, accentPaint);
  }

  @override
  bool shouldRepaint(covariant ClusterLinePainter oldDelegate) {
    return oldDelegate.isDark != isDark || oldDelegate.w != w || oldDelegate.h != h;
  }
}

class CenterWordCard extends StatefulWidget {
  final String word;
  final String romaji;
  final VoidCallback onPlay;
  final double width;
  final double height;

  const CenterWordCard({
    super.key,
    required this.word,
    required this.romaji,
    required this.onPlay,
    required this.width,
    required this.height,
  });

  @override
  State<CenterWordCard> createState() => _CenterWordCardState();
}

class _CenterWordCardState extends State<CenterWordCard> with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ScaleTransition(
      scale: _scaleAnimation,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF1A237E),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF1A237E).withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(13),
            onTap: () async {
              _animController.forward().then((_) => _animController.reverse());
              widget.onPlay();
            },
            child: Stack(
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        widget.word,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1A237E),
                          fontFamily: 'Inter',
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.romaji,
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white70 : Colors.grey.shade500,
                          fontFamily: 'Inter',
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                const Positioned(
                  right: 4,
                  bottom: 4,
                  child: Icon(
                    Icons.volume_up,
                    color: Color(0xFFFF9800),
                    size: 16,
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

class BubbleNode extends StatelessWidget {
  final String title;
  final String content;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final double width;

  const BubbleNode({
    super.key,
    required this.title,
    required this.content,
    this.subtitle,
    required this.icon,
    required this.color,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: width,
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF222232) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 12,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white70 : Colors.grey.shade500,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                    fontFamily: 'Inter',
                    height: 1.2,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 8.5,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white54 : Colors.grey.shade600,
                      fontFamily: 'Inter',
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
