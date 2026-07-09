import 'package:flutter/material.dart';

class GrammarBottomNav extends StatelessWidget {
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;
  final String progressText; // e.g. "1/3"

  const GrammarBottomNav({
    super.key,
    this.onPrevious,
    this.onNext,
    required this.progressText,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2F) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? Colors.white10 : Colors.grey.shade200,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end, // Align to right since left button is removed
          children: [
            // Middle/Right: Progress text and Navigation Chevrons
            Row(
              children: [
                Text(
                  progressText,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                    fontFamily: 'Inter',
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onPrevious,
                  icon: const Icon(Icons.chevron_left),
                  color: onPrevious != null
                      ? const Color(0xFF1A237E)
                      : (isDark ? Colors.white24 : Colors.grey.shade300),
                  tooltip: 'Cấu trúc trước',
                ),
                IconButton(
                  onPressed: onNext,
                  icon: const Icon(Icons.chevron_right),
                  color: onNext != null
                      ? const Color(0xFF1A237E)
                      : (isDark ? Colors.white24 : Colors.grey.shade300),
                  tooltip: 'Cấu trúc sau',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
