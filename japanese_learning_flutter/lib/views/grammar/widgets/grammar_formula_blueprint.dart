import 'package:flutter/material.dart';
import 'package:japanese_learning/data/models/grammar.dart';

class GrammarFormulaBlueprint extends StatelessWidget {
  final List<GrammarFormulaBlock> formula;
  final String meaning;

  const GrammarFormulaBlueprint({
    super.key,
    required this.formula,
    required this.meaning,
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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'CẤU TRÚC NGỮ PHÁP',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: Color(0xFFFF9800), // Accent Orange
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: formula.map((block) {
              if (block.text == '→') {
                return const Icon(
                  Icons.arrow_forward,
                  color: Colors.grey,
                  size: 20,
                );
              }

              final bool isTarget = block.isTarget;
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isTarget
                      ? const Color(0xFF1A237E).withValues(alpha: 0.08)
                      : (isDark ? Colors.white12 : Colors.grey.shade100),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isTarget ? const Color(0xFF1A237E) : Colors.transparent,
                    width: isTarget ? 1.8 : 1,
                  ),
                ),
                child: Text(
                  block.text,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isTarget ? FontWeight.bold : FontWeight.w600,
                    color: isTarget
                        ? const Color(0xFF1A237E)
                        : (isDark ? Colors.white70 : Colors.grey.shade800),
                    fontFamily: 'Inter',
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFFF9800).withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              meaning,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A237E),
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
