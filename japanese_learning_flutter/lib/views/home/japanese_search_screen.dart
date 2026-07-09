import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:japanese_learning/providers/japanese_search_provider.dart';

// ─────────────────────────────────────────────────────────────
// MAIN SEARCH SCREEN WRAPPER (For router compatibility)
// ─────────────────────────────────────────────────────────────
class JapaneseSearchScreen extends StatelessWidget {
  const JapaneseSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tra cứu từ vựng',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: const SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: JapaneseSearchWidget(),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// EMBEDDABLE JAPANESE SEARCH WIDGET
// ─────────────────────────────────────────────────────────────
class JapaneseSearchWidget extends ConsumerStatefulWidget {
  const JapaneseSearchWidget({super.key});

  @override
  ConsumerState<JapaneseSearchWidget> createState() => _JapaneseSearchWidgetState();
}

class _JapaneseSearchWidgetState extends ConsumerState<JapaneseSearchWidget> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;
    await ref.read(japaneseSearchProvider.notifier).performSearch(query, context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF2D2D2D) : Colors.white;

    final searchState = ref.watch(japaneseSearchProvider);
    final recentSearches = searchState.recentSearches;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Search Bar Widget
          Stack(
            alignment: Alignment.centerRight,
            children: [
              MainSearchBar(
                controller: _searchController,
                onSubmitted: _performSearch,
              ),
              if (searchState.isLoading)
                const Padding(
                  padding: EdgeInsets.only(right: 12.0),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Color(0xFF1A237E),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // Recent Searches section
          Text(
            'Tra cứu gần đây:',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
          const SizedBox(height: 6),
          if (recentSearches.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(
                'Chưa có lịch sử tra cứu',
                style: TextStyle(
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                  color: isDark ? Colors.white38 : Colors.black38,
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: recentSearches.map((item) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ActionChip(
                      visualDensity: VisualDensity.compact,
                      backgroundColor: isDark ? Colors.white10 : Colors.grey.shade100,
                      side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300),
                      label: Text(
                        '${item.word} (${item.vietnameseMeaning})',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white.withValues(alpha: 0.8) : Colors.black87,
                        ),
                      ),
                      onPressed: () {
                        _searchController.text = item.word;
                        ref.read(japaneseSearchProvider.notifier).selectRecentSearch(item, context);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// DECOUPLED WIDGETS
// ─────────────────────────────────────────────────────────────

class MainSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onSubmitted;

  const MainSearchBar({
    super.key,
    required this.controller,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF1F3F6),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: isDark ? Colors.white54 : Colors.black38, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 15),
              decoration: const InputDecoration(
                hintText: '日本, nihon, Nhật Bản,...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
                isDense: true,
              ),
              textInputAction: TextInputAction.search,
              onSubmitted: onSubmitted,
            ),
          ),
        ],
      ),
    );
  }
}
