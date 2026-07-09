import 'package:flutter/material.dart';

class LevelSelector extends StatelessWidget {
  final String selectedLevel;
  final ValueChanged<String> onSelected;

  const LevelSelector({
    super.key,
    required this.selectedLevel,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final levels = ['N5', 'N4', 'N3', 'N2', 'N1'];

    return Container(
      height: 44,
      margin: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: levels.length,
        itemBuilder: (context, index) {
          final lvl = levels[index];
          final isSelected = lvl == selectedLevel;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => onSelected(lvl),
              borderRadius: BorderRadius.circular(22),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(horizontal: 22),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1A237E) : Colors.transparent,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF1A237E) : Colors.grey.shade300,
                    width: 1.5,
                  ),
                ),
                child: Text(
                  lvl,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? Colors.white : Colors.grey.shade600,
                    fontFamily: 'Inter',
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
