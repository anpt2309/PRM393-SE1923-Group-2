import 'package:flutter/material.dart';

class SearchAndFilterRow extends StatefulWidget {
  final ValueChanged<String> onQueryChanged;
  final ValueChanged<String> onFilterChanged;

  const SearchAndFilterRow({
    super.key,
    required this.onQueryChanged,
    required this.onFilterChanged,
  });

  @override
  State<SearchAndFilterRow> createState() => _SearchAndFilterRowState();
}

class _SearchAndFilterRowState extends State<SearchAndFilterRow> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          // Search Bar
          TextField(
            controller: _searchController,
            onChanged: widget.onQueryChanged,
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontFamily: 'Inter',
              fontSize: 14,
            ),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm từ vựng, Hiragana, ý nghĩa...',
              hintStyle: TextStyle(
                color: isDark ? Colors.white38 : Colors.grey.shade400,
                fontSize: 13,
                fontFamily: 'Inter',
              ),
              prefixIcon: Icon(Icons.search, color: isDark ? Colors.white54 : Colors.grey.shade500, size: 20),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        widget.onQueryChanged('');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E1E2F) : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade300, width: 1),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200, width: 1),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF1A237E), width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
