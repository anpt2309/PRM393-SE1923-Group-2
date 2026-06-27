import 'package:flutter/material.dart';
import '../../../data/models/exam_attempt.dart';
import '../constants/colors.dart';

class QuestionGridBottomSheet extends StatelessWidget {
  final List<ExamPartInfo> partsInfo;
  final int activeQuestionIndex;
  final Map<int, int> selectedAnswers;
  final ValueChanged<int> onSelectQuestion;

  const QuestionGridBottomSheet({
    super.key,
    required this.partsInfo,
    required this.activeQuestionIndex,
    required this.selectedAnswers,
    required this.onSelectQuestion,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.85,
      minChildSize: 0.5,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Pull Indicator / Title Row
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Danh sách câu hỏi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: primaryCobalt),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: textLight),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),
              const Divider(),
              const SizedBox(height: 12),

              // Dynamic Parts
              ...partsInfo.map((partInfo) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionLabel('${partInfo.name} (Q${partInfo.startIndex + 1} - Q${partInfo.endIndex})'),
                    const SizedBox(height: 8),
                    _buildQuestionGrid(context, partInfo.startIndex, partInfo.endIndex),
                    const SizedBox(height: 20),
                  ],
                );
              }),

              // Legend
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildLegendItem(primaryCobalt, 'Đã làm', isBordered: false),
                  _buildLegendItem(Colors.white, 'Đang chọn', isBordered: true),
                  _buildLegendItem(Colors.grey.shade200, 'Chưa làm', isBordered: false),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark),
    );
  }

  Widget _buildLegendItem(Color color, String text, {required bool isBordered}) {
    return Row(
      children: [
        Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: isBordered ? Border.all(color: primaryCobalt, width: 2) : Border.all(color: Colors.transparent),
          ),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12, color: textLight)),
      ],
    );
  }

  Widget _buildQuestionGrid(BuildContext context, int startIdx, int endIdx) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(endIdx - startIdx, (index) {
        final qIdx = startIdx + index;
        final questionNumber = qIdx + 1;
        final isAnswered = selectedAnswers.containsKey(qIdx);
        final isActive = activeQuestionIndex == qIdx;

        Color bgCol = Colors.grey.shade200;
        Color textCol = textDark;
        Color borderCol = Colors.transparent;

        if (isActive) {
          bgCol = Colors.white;
          textCol = primaryCobalt;
          borderCol = primaryCobalt;
        } else if (isAnswered) {
          bgCol = primaryCobalt;
          textCol = Colors.white;
        }

        return InkWell(
          onTap: () {
            onSelectQuestion(qIdx);
            Navigator.pop(context); // Close bottom sheet
          },
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: bgCol,
              shape: BoxShape.circle,
              border: Border.all(color: borderCol, width: isActive ? 2.5 : 0),
            ),
            alignment: Alignment.center,
            child: Text(
              '$questionNumber',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: textCol,
              ),
            ),
          ),
        );
      }),
    );
  }
}
