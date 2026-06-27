import 'package:flutter/material.dart';
import '../../../data/models/exam_attempt.dart';
import '../constants/colors.dart';

class QuestionCard extends StatelessWidget {
  final ExamQuestion question;
  final bool isAudioPlaying;
  final double audioProgress;
  final int audioCurrentSeconds;
  final int audioTotalSeconds;
  final VoidCallback onToggleAudio;

  const QuestionCard({
    super.key,
    required this.question,
    required this.isAudioPlaying,
    required this.audioProgress,
    required this.audioCurrentSeconds,
    required this.audioTotalSeconds,
    required this.onToggleAudio,
  });

  String _formatAudioTime(int seconds) {
    int mins = seconds ~/ 60;
    int secs = seconds % 60;
    return '$mins:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question Text
          Text(
            question.questionText,
            style: const TextStyle(fontSize: 15, color: textDark, height: 1.5, fontWeight: FontWeight.w500),
          ),

          // Math support formatting (if present)
          if (question.formulaText != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
              decoration: BoxDecoration(
                color: bgLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              alignment: Alignment.center,
              child: Text(
                question.formulaText!,
                style: const TextStyle(
                  fontSize: 14,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.bold,
                  color: primaryCobalt,
                ),
              ),
            ),
          ],

          // Audio Playback simulation for listening
          if (question.isListening) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: bgLight,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      isAudioPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                      color: primaryCobalt,
                      size: 32,
                    ),
                    onPressed: onToggleAudio,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LinearProgressIndicator(
                          value: audioProgress,
                          backgroundColor: Colors.grey.shade300,
                          color: primaryCobalt,
                          minHeight: 4,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatAudioTime(audioCurrentSeconds),
                              style: const TextStyle(fontSize: 10, color: textLight),
                            ),
                            Text(
                              _formatAudioTime(audioTotalSeconds),
                              style: const TextStyle(fontSize: 10, color: textLight),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
