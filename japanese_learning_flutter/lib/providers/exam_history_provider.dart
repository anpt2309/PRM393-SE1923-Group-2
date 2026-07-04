import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/exam_history.dart';
import '../data/models/exam_history_detail.dart';
import '../data/models/comment_response.dart';
import '../data/repositories/exam_history_repository.dart';

// ─────────────────────────────────────────────────────────────
// REPOSITORY PROVIDER
// ─────────────────────────────────────────────────────────────

final examHistoryRepositoryProvider = Provider<ExamHistoryRepository>((ref) {
  return ExamHistoryRepository();
});

// ─────────────────────────────────────────────────────────────
// MODULE 3A: HISTORY LIST (ExamHistorySelectorScreen)
// ─────────────────────────────────────────────────────────────

class ExamHistoryListState {
  final List<ExamAttemptHistoryItem> items;
  final bool isLoading;
  final String? error;
  final String sortOrder; // 'highest' | 'lowest'

  const ExamHistoryListState({
    this.items = const [],
    this.isLoading = false,
    this.error,
    this.sortOrder = 'highest',
  });

  /// Danh sách đã được sắp xếp
  List<ExamAttemptHistoryItem> get sortedItems {
    final sorted = List<ExamAttemptHistoryItem>.from(items);
    if (sortOrder == 'highest') {
      sorted.sort((a, b) => b.score.compareTo(a.score));
    } else {
      sorted.sort((a, b) => a.score.compareTo(b.score));
    }
    return sorted;
  }

  ExamHistoryListState copyWith({
    List<ExamAttemptHistoryItem>? items,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? sortOrder,
  }) {
    return ExamHistoryListState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

class ExamHistoryListNotifier extends AutoDisposeNotifier<ExamHistoryListState> {
  @override
  ExamHistoryListState build() {
    Future.microtask(loadHistory);
    return const ExamHistoryListState();
  }

  Future<void> loadHistory() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // userId = 1 mặc định; thay bằng userId từ auth sau này
      final items =
          await ref.read(examHistoryRepositoryProvider).getExamHistory(1);
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  void setSortOrder(String order) {
    state = state.copyWith(sortOrder: order);
  }
}

/// Provider cho màn hình ExamHistorySelectorScreen
final examHistoryListProvider =
    NotifierProvider.autoDispose<ExamHistoryListNotifier, ExamHistoryListState>(
  ExamHistoryListNotifier.new,
);

// ─────────────────────────────────────────────────────────────
// MODULE 3B: HISTORY REVIEW (ExamHistoryReviewScreen)
// ─────────────────────────────────────────────────────────────

class ExamHistoryReviewState {
  final ExamHistoryDetail? detail;
  final bool isLoading;
  final String? error;

  // Trạng thái UI của review screen
  final Set<int> expandedExplanations;
  final Map<int, List<Map<String, String>>> dynamicComments;

  const ExamHistoryReviewState({
    this.detail,
    this.isLoading = false,
    this.error,
    this.expandedExplanations = const {},
    this.dynamicComments = const {},
  });

  ExamHistoryReviewState copyWith({
    ExamHistoryDetail? detail,
    bool? isLoading,
    String? error,
    bool clearError = false,
    Set<int>? expandedExplanations,
    Map<int, List<Map<String, String>>>? dynamicComments,
  }) {
    return ExamHistoryReviewState(
      detail: detail ?? this.detail,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      expandedExplanations:
          expandedExplanations ?? this.expandedExplanations,
      dynamicComments: dynamicComments ?? this.dynamicComments,
    );
  }
}

class ExamHistoryReviewNotifier
    extends AutoDisposeFamilyNotifier<ExamHistoryReviewState, int> {
  @override
  ExamHistoryReviewState build(int attemptId) {
    Future.microtask(() => loadDetail(attemptId));
    return const ExamHistoryReviewState(isLoading: true);
  }

  Future<void> loadDetail(int attemptId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final detail = await ref
          .read(examHistoryRepositoryProvider)
          .getExamHistoryDetail(attemptId);
      state = state.copyWith(detail: detail, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  // ── Explanation toggle ────────────────────────────────────

  void toggleExplanation(int index) {
    final updated = Set<int>.from(state.expandedExplanations);
    if (updated.contains(index)) {
      updated.remove(index);
    } else {
      updated.add(index);
    }
    state = state.copyWith(expandedExplanations: updated);
  }

  // ── Comment ───────────────────────────────────────────────

  /// Tải danh sách comment cho 1 câu hỏi và lưu vào state
  Future<List<CommentResponse>> fetchComments() async {
    return ref.read(examHistoryRepositoryProvider).getComments();
  }

  /// Thêm comment mới vào danh sách local (optimistic update)
  void addLocalComment(int questionIndex, String userName, String content) {
    final updated =
        Map<int, List<Map<String, String>>>.from(state.dynamicComments);
    updated.putIfAbsent(questionIndex, () => []);
    updated[questionIndex]!.add({'user': userName, 'content': content});
    state = state.copyWith(dynamicComments: updated);
  }

  /// Gửi comment lên server
  Future<CommentResponse> createComment(
      int userId, String content, int questionId) async {
    return ref
        .read(examHistoryRepositoryProvider)
        .createComment(userId, content, questionId);
  }

  // ── Report ────────────────────────────────────────────────

  /// Gửi báo cáo lỗi câu hỏi lên server
  Future<void> createReportQuestion(
      int userId, String content, int questionId) async {
    await ref
        .read(examHistoryRepositoryProvider)
        .createReportQuestion(userId, content, questionId);
  }

  // ── AI Tutor ──────────────────────────────────────────────

  /// Gửi tin nhắn đến AI Tutor
  Future<String> sendAiMessage(
      int userId, String message, int questionId) async {
    return ref
        .read(examHistoryRepositoryProvider)
        .sendAiMessage(userId, message, questionId);
  }
}

/// Provider cho màn hình ExamHistoryReviewScreen.
/// Parameterized bằng attemptId.
final examHistoryReviewProvider =
    NotifierProvider.autoDispose.family<ExamHistoryReviewNotifier, ExamHistoryReviewState,
        int>(
  ExamHistoryReviewNotifier.new,
);
