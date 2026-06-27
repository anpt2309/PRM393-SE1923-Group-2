import 'package:flutter/material.dart';
import '../constants/colors.dart';

class OptionsList extends StatelessWidget {
  final List<String> options;
  final int? selectedOptionIndex;
  final ValueChanged<int> onSelectOption;

  const OptionsList({
    super.key,
    required this.options,
    required this.selectedOptionIndex,
    required this.onSelectOption,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Chọn một đáp án:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textDark)),
        const SizedBox(height: 10),
        Column(
          children: List.generate(options.length, (idx) {
            final optionText = options[idx];
            final isSelected = selectedOptionIndex == idx;

            return Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: InkWell(
                onTap: () => onSelectOption(idx),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? primaryCobalt.withValues(alpha: 0.04) : Colors.white,
                    border: Border.all(
                      color: isSelected ? primaryCobalt : Colors.grey.shade200,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      // Selected Radio circle
                      Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: isSelected ? primaryCobalt : Colors.transparent,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected ? primaryCobalt : Colors.grey.shade400,
                            width: 1.5,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(Icons.circle, size: 8, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          optionText,
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected ? primaryCobalt : textDark,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
