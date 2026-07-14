import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/flashcard_provider.dart';
import '../../providers/app_setting_provider.dart';
import '../../data/models/flashcard_quiz_history.dart';

class HistoryFlashcardQuiz extends ConsumerStatefulWidget {
  final int userId;
  final int? setId;
  final String? setName;

  const HistoryFlashcardQuiz({
    super.key,
    required this.userId,
    this.setId,
    this.setName,
  });

  @override
  ConsumerState<HistoryFlashcardQuiz> createState() => _HistoryFlashcardQuizState();
}

class _HistoryFlashcardQuizState extends ConsumerState<HistoryFlashcardQuiz> {
  bool _isLoading = true;
  List<FlashcardQuizHistory> _history = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadHistory());
  }

  Future<void> _loadHistory() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    
    final provider = ref.read(flashcardProvider);
    await provider.loadQuizHistory(widget.userId);

    if (!mounted) return;

    final allHistory = provider.quizHistory;
    debugPrint("Total history items from provider: ${allHistory.length}");

    if (widget.setId != null) {
      final targetId = widget.setId.toString();
      debugPrint("Filtering for setId (String): $targetId");
      
      _history = allHistory.where((h) {
        final itemSetId = h.setId?.toString();
        // Log chi tiết để kiểm tra tại sao filter không khớp
        debugPrint("Checking item: HistoryID=${h.historyId}, ItemSetID=$itemSetId vs TargetID=$targetId");
        return itemSetId == targetId;
      }).toList();
      
      debugPrint("Items after filter: ${_history.length}");
    } else {
      _history = allHistory;
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Color _getColor(double percentage) {
    if (percentage >= 90) return Colors.green;
    if (percentage >= 70) return Colors.blue;
    if (percentage >= 50) return Colors.orange;
    return Colors.red;
  }

  String _getEmoji(double percentage) {
    if (percentage >= 90) return '🎉';
    if (percentage >= 70) return '👍';
    if (percentage >= 50) return '💪';
    return '📚';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingProvider);
    final isDark = settings.isDarkMode;

    final backgroundColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
    final appBarColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.setName != null && widget.setName!.isNotEmpty
              ? 'Lịch sử - ${widget.setName}'
              : 'Lịch sử làm bài',
          style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: appBarColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: isDark ? Colors.white70 : Colors.black54),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1E88E5)),
            onPressed: _loadHistory,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _history.isEmpty
          ? _buildEmptyState(isDark)
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _history.length,
              itemBuilder: (context, index) {
                final item = _history[index];
                final percentage = item.percentage;
                final color = _getColor(percentage);
                return _buildHistoryCard(item, color, percentage, isDark);
              },
            ),
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 80, color: isDark ? Colors.white10 : Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            widget.setId != null 
                ? 'Bộ thẻ này chưa có lịch sử làm bài' 
                : 'Chưa có dữ liệu lịch sử', 
            style: TextStyle(color: isDark ? Colors.white38 : Colors.grey, fontSize: 16)
          ),
          const SizedBox(height: 20),
          if (widget.setId != null)
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF1E88E5)),
              child: const Text('Quay lại làm bài', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(FlashcardQuizHistory item, Color color, double percentage, bool isDark) {
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showDetailDialog(item, isDark),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50, height: 50,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: Center(child: Text(_getEmoji(percentage), style: const TextStyle(fontSize: 24))),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.setName, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: textColor), maxLines: 1, overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text(_formatDate(item.createdAt ?? DateTime.now()), style: TextStyle(color: isDark ? Colors.white38 : Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('${item.correctAnswer}/${item.totalQuestions}', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 16)),
                    Text('${percentage.round()}%', style: TextStyle(color: color, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDetailDialog(FlashcardQuizHistory history, bool isDark) {
    final percentage = history.percentage;
    final color = _getColor(percentage);
    final textColor = isDark ? Colors.white : Colors.black87;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(history.setName, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem('Đúng', '${history.correctAnswer}', Colors.green, isDark),
                _buildStatItem('Tổng', '${history.totalQuestions}', Colors.blue, isDark),
                _buildStatItem('Tỉ lệ', '${percentage.round()}%', color, isDark),
              ],
            ),
            if (history.answers != null && history.answers!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Align(alignment: Alignment.centerLeft, child: Text('Chi tiết:', style: TextStyle(fontWeight: FontWeight.bold, color: textColor))),
              const SizedBox(height: 10),
              SizedBox(
                height: 150,
                width: double.maxFinite,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: history.answers!.length,
                  itemBuilder: (context, idx) {
                    final ans = history.answers![idx];
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(ans['isCorrect'] == true ? Icons.check_circle : Icons.cancel, 
                               color: ans['isCorrect'] == true ? Colors.green : Colors.red, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text('Câu ${idx+1}: ${ans['selected'] ?? 'Trống'}', style: TextStyle(fontSize: 13, color: isDark ? Colors.white70 : Colors.black87))),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color, bool isDark) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: TextStyle(fontSize: 12, color: isDark ? Colors.white38 : Colors.grey)),
      ],
    );
  }
}
