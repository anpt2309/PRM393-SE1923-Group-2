import 'package:flutter/material.dart';
import '../data/models/exam.dart';
import '../data/repository/exam_repository.dart';

/// ViewModel danh sách đề thi: quản lý toàn bộ trạng thái bộ lọc,
/// tải dữ liệu và hiển thị cho ExamListScreen.
class ExamListViewModel extends ChangeNotifier {
  ExamListViewModel({ExamRepository? repository})
      : _repository = repository ?? ExamRepository();

  final ExamRepository _repository;

  // Controllers cho các ô nhập liệu
  final TextEditingController searchController = TextEditingController();
  final TextEditingController minPriceController = TextEditingController();
  final TextEditingController maxPriceController = TextEditingController();

  // Trạng thái bộ lọc
  String selectedType = 'Tất cả';
  String selectedJLPTLevel = 'Tất cả';
  String selectedDifficulty = 'Tất cả';
  String sortBy = 'price_low_high';

  // Trạng thái dữ liệu
  List<Exam> displayedExams = [];
  bool isLoading = false;
  String? errorMessage;

  /// Tải danh sách đề thi từ repository (API → DB)
  Future<void> loadExams() async {
    final double? minPrice = double.tryParse(minPriceController.text.trim());
    final double? maxPrice = double.tryParse(maxPriceController.text.trim());

    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      displayedExams = await _repository.getExams(
        query: searchController.text,
        type: selectedType,
        jlptLevel: selectedJLPTLevel,
        difficulty: selectedDifficulty,
        minPrice: minPrice,
        maxPrice: maxPrice,
        sortBy: sortBy,
      );
      isLoading = false;
    } catch (e) {
      errorMessage = e.toString();
      isLoading = false;
    }
    notifyListeners();
  }

  /// Đặt lại tất cả bộ lọc về mặc định và tải lại dữ liệu
  void resetFilters() {
    searchController.clear();
    minPriceController.clear();
    maxPriceController.clear();
    selectedType = 'Tất cả';
    selectedJLPTLevel = 'Tất cả';
    selectedDifficulty = 'Tất cả';
    sortBy = 'price_low_high';
    errorMessage = null;
    loadExams();
  }

  @override
  void dispose() {
    searchController.dispose();
    minPriceController.dispose();
    maxPriceController.dispose();
    super.dispose();
  }
}
