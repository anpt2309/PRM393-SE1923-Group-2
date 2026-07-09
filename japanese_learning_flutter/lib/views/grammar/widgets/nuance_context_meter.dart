import 'package:flutter/material.dart';

class NuanceContextMeter extends StatelessWidget {
  final double nuance; // value between 0.0 (Casual) and 1.0 (Formal)

  const NuanceContextMeter({
    super.key,
    required this.nuance,
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
          const Row(
            children: [
              Icon(
                Icons.tune,
                color: Color(0xFF1A237E),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Sắc thái ngữ pháp',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A237E),
                  fontFamily: 'Inter',
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Nuance Scale Track
          LayoutBuilder(
            builder: (context, constraints) {
              final trackWidth = constraints.maxWidth;
              final indicatorOffset = nuance * trackWidth;

              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // Track
                  Container(
                    height: 8,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF9800), // Casual (Orange)
                          Color(0xFF1A237E), // Formal (Cobalt)
                        ],
                      ),
                    ),
                  ),
                  // Current indicator dot
                  Positioned(
                    left: (indicatorOffset - 8).clamp(0.0, trackWidth - 16),
                    top: -4,
                    child: Container(
                      height: 16,
                      width: 16,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Color.lerp(
                            const Color(0xFFFF9800),
                            const Color(0xFF1A237E),
                            nuance,
                          )!,
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 14),
          // Labels
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Suồng sã',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF9800),
                      fontFamily: 'Inter',
                    ),
                  ),
                  Text(
                    '(Casual)',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white30 : Colors.grey.shade400,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Color.lerp(
                    const Color(0xFFFF9800).withValues(alpha: 0.1),
                    const Color(0xFF1A237E).withValues(alpha: 0.1),
                    nuance,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${(nuance * 100).toInt()}% Trang trọng',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Color.lerp(
                      const Color(0xFFFF9800),
                      const Color(0xFF1A237E),
                      nuance,
                    ),
                    fontFamily: 'Inter',
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Trang trọng',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A237E),
                      fontFamily: 'Inter',
                    ),
                  ),
                  Text(
                    '(Formal)',
                    style: TextStyle(
                      fontSize: 10,
                      color: isDark ? Colors.white30 : Colors.grey.shade400,
                      fontFamily: 'Inter',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
