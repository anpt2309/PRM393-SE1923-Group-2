class Exam {
  final String id;
  final String title;
  final String description;
  final String type; // "JLPT", "Kanji", "Ngữ pháp", "Từ vựng"
  final String jlptLevel; // "N5", "N4", "N3", "N2", "N1"
  final String difficulty; // "Dễ", "Trung bình", "Khó"
  final double price; // 0.0 means Free
  final int durationMinutes;
  final int questionsCount;
  final int enrolledCount;
  final double rating;

  const Exam({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.jlptLevel,
    required this.difficulty,
    required this.price,
    required this.durationMinutes,
    required this.questionsCount,
    required this.enrolledCount,
    required this.rating,
  });

  bool get isFree => price == 0.0;
}

class ExamService {
  // Mock Database
  final List<Exam> _mockExams = [
    const Exam(
      id: 'exam_1',
      title: 'Đề thi thử JLPT N3 - Đầy đủ các phần',
      description: 'Đề thi thử chuẩn cấu trúc JLPT N3 bao gồm Từ vựng, Chữ Hán, Ngữ pháp, Đọc hiểu và Nghe hiểu. Phù hợp cho các bạn chuẩn bị thi thật.',
      type: 'JLPT',
      jlptLevel: 'N3',
      difficulty: 'Trung bình',
      price: 0.0,
      durationMinutes: 140,
      questionsCount: 95,
      enrolledCount: 3420,
      rating: 4.8,
    ),
    const Exam(
      id: 'exam_2',
      title: 'Luyện tập Kanji N5 - 100 chữ cơ bản',
      description: 'Bài kiểm tra nhanh đánh giá khả năng nhận diện mặt chữ, âm ôn, âm kun của 100 chữ Kanji cơ bản nhất trong chương trình N5.',
      type: 'Kanji',
      jlptLevel: 'N5',
      difficulty: 'Dễ',
      price: 0.0,
      durationMinutes: 30,
      questionsCount: 50,
      enrolledCount: 5200,
      rating: 4.9,
    ),
    const Exam(
      id: 'exam_3',
      title: 'Tổng ôn Ngữ pháp JLPT N2 - Đề số 1',
      description: 'Tuyển tập các câu hỏi trắc nghiệm ngữ pháp khó của trình độ N2. Giúp củng cố các cấu trúc dễ nhầm lẫn.',
      type: 'Ngữ pháp',
      jlptLevel: 'N2',
      difficulty: 'Khó',
      price: 99000.0,
      durationMinutes: 60,
      questionsCount: 40,
      enrolledCount: 850,
      rating: 4.7,
    ),
    const Exam(
      id: 'exam_4',
      title: 'Từ vựng thông dụng JLPT N4',
      description: 'Kiểm tra vốn từ vựng trình độ N4 thường xuất hiện trong các kỳ thi JLPT gần đây. Bao gồm cả phần điền từ vào chỗ trống.',
      type: 'Từ vựng',
      jlptLevel: 'N4',
      difficulty: 'Dễ',
      price: 49000.0,
      durationMinutes: 45,
      questionsCount: 60,
      enrolledCount: 1540,
      rating: 4.6,
    ),
    const Exam(
      id: 'exam_5',
      title: 'Đề thi thử JLPT N1 - Đọc hiểu & Nghe hiểu chuyên sâu',
      description: 'Đề thi thử thách cực đại dành cho các bạn muốn chinh phục đỉnh cao N1. Tập trung vào các bài đọc dài khó và nghe hiểu tốc độ cao.',
      type: 'JLPT',
      jlptLevel: 'N1',
      difficulty: 'Khó',
      price: 199000.0,
      durationMinutes: 170,
      questionsCount: 70,
      enrolledCount: 310,
      rating: 4.9,
    ),
    const Exam(
      id: 'exam_6',
      title: 'Luyện dịch câu và Ngữ pháp JLPT N3',
      description: 'Đề luyện tập chuyên sâu về cấu trúc ngữ pháp N3 và kỹ năng dịch câu từ tiếng Nhật sang tiếng Việt chính xác.',
      type: 'Ngữ pháp',
      jlptLevel: 'N3',
      difficulty: 'Trung bình',
      price: 59000.0,
      durationMinutes: 50,
      questionsCount: 45,
      enrolledCount: 1200,
      rating: 4.5,
    ),
    const Exam(
      id: 'exam_7',
      title: 'Đề kiểm tra Chữ Hán N2 - 250 Kanji nâng cao',
      description: 'Bài kiểm tra chuyên sâu về chữ Hán cấp độ N2, giúp bạn làm quen với các từ ghép phức tạp và các âm đọc đặc biệt.',
      type: 'Kanji',
      jlptLevel: 'N2',
      difficulty: 'Trung bình',
      price: 0.0,
      durationMinutes: 40,
      questionsCount: 50,
      enrolledCount: 1980,
      rating: 4.7,
    ),
    const Exam(
      id: 'exam_8',
      title: 'Đề thi thử JLPT N5 - Làm quen cấu trúc đề',
      description: 'Đề thi thử sơ cấp N5 dành cho các bạn mới học. Giúp giải tỏa áp lực thi cử và làm quen với phiếu trả lời trắc nghiệm.',
      type: 'JLPT',
      jlptLevel: 'N5',
      difficulty: 'Dễ',
      price: 0.0,
      durationMinutes: 90,
      questionsCount: 60,
      enrolledCount: 6700,
      rating: 4.8,
    ),
    const Exam(
      id: 'exam_9',
      title: 'Ngữ pháp N1 - Ôn luyện thần tốc',
      description: 'Tổng hợp tất cả các mẫu ngữ pháp N1 khó nhằn nhất, có kèm lời giải chi tiết giúp bạn tự tin vượt qua phần thi kiến thức ngôn ngữ.',
      type: 'Ngữ pháp',
      jlptLevel: 'N1',
      difficulty: 'Khó',
      price: 149000.0,
      durationMinutes: 60,
      questionsCount: 50,
      enrolledCount: 430,
      rating: 4.8,
    ),
    const Exam(
      id: 'exam_10',
      title: 'Siêu từ vựng N3 - Nâng tầm giao tiếp',
      description: 'Bộ đề thi đánh giá từ vựng thực tế đời sống của người Nhật ở trình độ N3, nâng cao khả năng giao tiếp và xem phim không cần sub.',
      type: 'Từ vựng',
      jlptLevel: 'N3',
      difficulty: 'Trung bình',
      price: 79000.0,
      durationMinutes: 45,
      questionsCount: 50,
      enrolledCount: 1100,
      rating: 4.6,
    ),
  ];

  // Get all exams
  List<Exam> getAllExams() {
    return List.from(_mockExams);
  }

  // Filter & Search & Sort logic
  List<Exam> getFilteredExams({
    String? query,
    String? type,
    String? jlptLevel, // "Tất cả", "N5", "N4", "N3", "N2", "N1"
    String? difficulty, // "Tất cả", "Dễ", "Trung bình", "Khó"
    double? minPrice,
    double? maxPrice,
    String? sortBy, // "price_low_high", "price_high_low"
  }) {
    List<Exam> filtered = List.from(_mockExams);

    // 1. Search by title
    if (query != null && query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      filtered = filtered.where((exam) => exam.title.toLowerCase().contains(q)).toList();
    }

    // 2. Filter by type
    if (type != null && type != 'Tất cả') {
      filtered = filtered.where((exam) => exam.type == type).toList();
    }

    // 3. Filter by JLPT level
    if (jlptLevel != null && jlptLevel != 'Tất cả') {
      filtered = filtered.where((exam) => exam.jlptLevel == jlptLevel).toList();
    }

    // 4. Filter by difficulty
    if (difficulty != null && difficulty != 'Tất cả') {
      filtered = filtered.where((exam) => exam.difficulty == difficulty).toList();
    }

    // 5. Filter by price range
    if (minPrice != null) {
      filtered = filtered.where((exam) => exam.price >= minPrice).toList();
    }
    if (maxPrice != null) {
      filtered = filtered.where((exam) => exam.price <= maxPrice).toList();
    }

    // 6. Sort by price
    if (sortBy != null) {
      if (sortBy == 'price_low_high') {
        filtered.sort((a, b) => a.price.compareTo(b.price));
      } else if (sortBy == 'price_high_low') {
        filtered.sort((a, b) => b.price.compareTo(a.price));
      }
    }

    return filtered;
  }
}
