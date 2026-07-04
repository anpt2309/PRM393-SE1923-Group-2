import '../models/exam.dart';
import '../models/exam_detail.dart';
import '../service/exam_service.dart';

/// Repository danh sách và chi tiết đề thi.
/// Xử lý logic lọc/sắp xếp phía client và ủy thác HTTP call cho ExamService.
class ExamRepository {
  ExamRepository({ExamService? examService})
      : _examService = examService ?? ExamService();

  final ExamService _examService;

  /// Lấy danh sách đề thi với bộ lọc đầy đủ.
  Future<List<Exam>> getExams({
    String? query,
    String? type,
    String? jlptLevel,
    String? difficulty,
    double? minPrice,
    double? maxPrice,
    String? sortBy,
  }) async {
    // Ánh xạ cấp độ JLPT
    List<String>? levelExam;
    if (jlptLevel != null && jlptLevel != 'Tất cả') {
      levelExam = [jlptLevel];
    }

    // Ánh xạ độ khó từ chữ thành số (1: Dễ, 2: Trung bình, 3: Khó)
    List<int>? difficultyExam;
    if (difficulty != null && difficulty != 'Tất cả') {
      final diffMap = {'Dễ': 1, 'Trung bình': 2, 'Khó': 3};
      final diffNum = diffMap[difficulty];
      if (diffNum != null) difficultyExam = [diffNum];
    }

    // Ánh xạ sắp xếp sang Spring Pageable format
    String? sort;
    if (sortBy == 'price_low_high') {
      sort = 'price,asc';
    } else if (sortBy == 'price_high_low') {
      sort = 'price,desc';
    }

    List<Exam> exams = await _examService.fetchExams(
      levelExam: levelExam,
      difficultyExam: difficultyExam,
      priceFrom: minPrice,
      priceTo: maxPrice,
      sort: sort,
    );

    // Lọc phía client theo tên và loại đề thi
    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      exams = exams.where((e) => e.title.toLowerCase().contains(q)).toList();
    }
    if (type != null && type != 'Tất cả') {
      exams = exams.where((e) => e.examType == type).toList();
    }

    return exams;
  }

  /// Lấy thông tin chi tiết đề thi.
  Future<ExamDetail> getExamDetail(int examId) async {
    return _examService.fetchExamDetail(examId);
  }
}
