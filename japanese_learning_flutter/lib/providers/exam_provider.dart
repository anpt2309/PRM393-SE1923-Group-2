import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/exam.dart';
import '../data/repository/exam_repository.dart';

// ─────────────────────────────────────────────────────────────
// REPOSITORY PROVIDER
// ─────────────────────────────────────────────────────────────

/// Cung cấp ExamRepository duy nhất cho toàn bộ module Exam.
/// Riverpod đảm bảo chỉ 1 instance được tạo ra.
final examRepositoryProvider = Provider<ExamRepository>((ref) {
  return ExamRepository();
});

// ─────────────────────────────────────────────────────────────
// STATE CLASS
// ─────────────────────────────────────────────────────────────

class ExamListState {
  final List<Exam> exams;
  final bool isLoading;
  final String? error;

  // Filter state
  final String selectedType;
  final String selectedJLPTLevel;
  final String selectedDifficulty;
  final String sortBy;
  final String searchQuery;
  final String minPrice;
  final String maxPrice;

  const ExamListState({
    this.exams = const [],
    this.isLoading = false,
    this.error,
    this.selectedType = 'Tất cả',
    this.selectedJLPTLevel = 'Tất cả',
    this.selectedDifficulty = 'Tất cả',
    this.sortBy = 'price_low_high',
    this.searchQuery = '',
    this.minPrice = '',
    this.maxPrice = '',
  });

  ExamListState copyWith({
    List<Exam>? exams,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? selectedType,
    String? selectedJLPTLevel,
    String? selectedDifficulty,
    String? sortBy,
    String? searchQuery,
    String? minPrice,
    String? maxPrice,
  }) {
    return ExamListState(
      exams: exams ?? this.exams,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedType: selectedType ?? this.selectedType,
      selectedJLPTLevel: selectedJLPTLevel ?? this.selectedJLPTLevel,
      selectedDifficulty: selectedDifficulty ?? this.selectedDifficulty,
      sortBy: sortBy ?? this.sortBy,
      searchQuery: searchQuery ?? this.searchQuery,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
    );
  }
}

// ─────────────────────────────────────────────────────────────
// NOTIFIER
// ─────────────────────────────────────────────────────────────

class ExamListNotifier extends Notifier<ExamListState> {
  // TextEditingControllers — vẫn cần giữ để các TextField trong UI bind vào
  final TextEditingController searchController = TextEditingController();
  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();

  @override
  ExamListState build() {
    // Tự động dọn dẹp controller khi provider bị dispose
    ref.onDispose(() {
      searchController.dispose();
      minPriceController.dispose();
      maxPriceController.dispose();
    });
    // Load danh sách đề thi khi khởi tạo
    Future.microtask(loadExams);
    return const ExamListState();
  }

  /// Tải danh sách đề thi từ repository
  Future<void> loadExams() async {
    final minPrice = double.tryParse(state.minPrice);
    final maxPrice = double.tryParse(state.maxPrice);

    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final exams = await ref.read(examRepositoryProvider).getExams(
            query: state.searchQuery,
            type: state.selectedType,
            jlptLevel: state.selectedJLPTLevel,
            difficulty: state.selectedDifficulty,
            minPrice: minPrice,
            maxPrice: maxPrice,
            sortBy: state.sortBy,
          );
      state = state.copyWith(exams: exams, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  /// Cập nhật filter và tải lại danh sách
  void setFilter({
    String? type,
    String? jlptLevel,
    String? difficulty,
    String? sortBy,
  }) {
    state = state.copyWith(
      selectedType: type,
      selectedJLPTLevel: jlptLevel,
      selectedDifficulty: difficulty,
      sortBy: sortBy,
    );
    loadExams();
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    loadExams();
  }

  void setPriceRange(String min, String max) {
    state = state.copyWith(minPrice: min, maxPrice: max);
    loadExams();
  }

  /// Đặt lại tất cả bộ lọc về mặc định
  void resetFilters() {
    searchController.clear();
    minPriceController.clear();
    maxPriceController.clear();
    state = const ExamListState();
    loadExams();
  }
}

// ─────────────────────────────────────────────────────────────
// PROVIDER DECLARATION
// ─────────────────────────────────────────────────────────────

/// Provider chính cho module Exam (danh sách đề thi).
/// Widget dùng: ref.watch(examListProvider) để lấy ExamListState
/// Widget dùng: ref.read(examListProvider.notifier) để gọi action
final examListProvider = NotifierProvider<ExamListNotifier, ExamListState>(
  ExamListNotifier.new,
);
