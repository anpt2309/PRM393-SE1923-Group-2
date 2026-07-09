# Japanese Learning Flutter App - Project Overview & Structure

Dự án này là một ứng dụng di động học tiếng Nhật toàn diện (luyện đề thi JLPT, học từ vựng, chữ Hán, ngữ pháp, flashcard, tin tức tiếng Nhật) được xây dựng bằng **Flutter**. Tài liệu này mô tả chi tiết cấu trúc thư mục, kiến trúc, các quy ước code thực tế và luồng hoạt động để AI/Developer nhanh chóng nắm bắt bối cảnh khi sửa lỗi hoặc phát triển tính năng mới **theo đúng phong cách đã có sẵn**.

---

## 1. Kiến Trúc Dự Án (Architecture Pattern)

Dự án tuân thủ kiến trúc **MVVM (Model - View - ViewModel)** kết hợp **Repository Pattern**, trong đó **Riverpod** đóng vai trò ViewModel:

```
View (ConsumerWidget/ConsumerStatefulWidget)
  └─► ref.watch(provider)       ← lắng nghe state
  └─► ref.read(provider.notifier).method()  ← gửi event

Provider / Notifier (ViewModel)  [lib/providers/]
  └─► _repository.getXxx()      ← gọi qua Repository

Repository  [lib/data/repositories/]
  └─► _service.fetchXxx()       ← gọi qua Service

Service  [lib/data/services/]
  └─► http.get/post(uri)        ← gọi REST API Spring Boot
```

- **Model**: Plain Dart class, có `factory Model.fromJson(Map<String,dynamic>)`. Không có logic nghiệp vụ.
- **View**: `ConsumerWidget` hoặc `ConsumerStatefulWidget`. Chỉ đọc state từ Provider, không gọi Service hay Repository trực tiếp.
- **Provider (ViewModel)**: Class `XxxNotifier extends Notifier<XxxState>`. Quản lý `XxxState` (immutable, dùng `copyWith`). Được đăng ký bằng `NotifierProvider<XxxNotifier, XxxState>(XxxNotifier.new)`.
- **Repository**: Lớp trung gian, khởi tạo Service bên trong (`final _service = XxxService()`). Bắt exception, trả về giá trị mặc định thay vì throw.
- **Service**: Gọi HTTP trực tiếp. Có `static String get baseUrl` tự động detect môi trường (Android emulator vs Web/iOS).

---

## 2. Cấu Trúc Thư Mục Chi Tiết (`/lib`) — Trạng Thái Thực Tế

```
lib/
├── data/
│   ├── models/
│   │   ├── auth_exception.dart
│   │   ├── comment_response.dart
│   │   ├── exam.dart
│   │   ├── exam_attempt.dart
│   │   ├── exam_detail.dart
│   │   ├── exam_history.dart
│   │   ├── exam_history_detail.dart
│   │   ├── grammar.dart            ← Model ngữ pháp (GrammarLesson, GrammarWord)
│   │   ├── kanji.dart              ← Model chữ Hán (KanjiLesson, KanjiWord)
│   │   ├── news.dart               ← Model tin tức (NewsCategory, NewsArticle, NewsSpan)
│   │   ├── sentence_group.dart
│   │   ├── sentence_item.dart
│   │   ├── sentence_part.dart
│   │   └── vocabulary.dart         ← Model từ vựng (VocabularyLesson, VocabularyWord)
│   │
│   ├── repositories/
│   │   ├── auth_repository.dart
│   │   ├── exam_attempt_repository.dart
│   │   ├── exam_history_repository.dart
│   │   ├── exam_repository.dart
│   │   ├── grammar_repository.dart     ← Repository ngữ pháp
│   │   ├── kanji_repository.dart       ← Repository chữ Hán
│   │   ├── news_repository.dart        ← Repository tin tức & yêu thích bài viết
│   │   ├── notification_repository.dart← Repository thông báo push
│   │   ├── sentence_repository.dart
│   │   └── vocab_repository.dart       ← Repository từ vựng & yêu thích từ
│   │
│   └── services/
│       ├── auth_error_mapper.dart
│       ├── auth_exception.dart
│       ├── auth_service.dart           ← Firebase Auth + Firebase Storage
│       ├── exam_attempt_service.dart
│       ├── exam_history_service.dart
│       ├── exam_service.dart
│       ├── grammar_service.dart        ← API ngữ pháp
│       ├── kanji_service.dart          ← API chữ Hán
│       ├── news_service.dart           ← API tin tức, ghi chú, yêu thích bài viết
│       ├── notification_service.dart   ← Firebase Messaging + local notifications
│       ├── sentence_service.dart
│       └── vocab_service.dart          ← API từ vựng & yêu thích từ vựng
│
├── providers/
│   ├── app_setting_provider.dart   ← isDarkMode, textScaleFactor (dùng SharedPreferences)
│   ├── auth_provider.dart          ← Xác thực, thông tin user, Google Sign-In
│   ├── exam_attempt_provider.dart  ← Tiến trình làm bài thi (câu trả lời, timer, audio)
│   ├── exam_history_provider.dart  ← Lịch sử bài thi, bình luận, AI Tutor
│   ├── exam_provider.dart          ← Danh sách & bộ lọc đề thi
│   ├── grammar_provider.dart       ← Dữ liệu & trạng thái màn hình ngữ pháp
│   ├── japanese_search_provider.dart ← Tra cứu từ điển tích hợp
│   ├── kanji_provider.dart         ← Dữ liệu & trạng thái màn hình chữ Hán
│   ├── news_provider.dart          ← Tin tức, tab category, ghi chú, yêu thích bài viết
│   ├── sentence_provider.dart      ← Mẫu câu & trạng thái quiz ghép câu
│   ├── streak_provider.dart        ← Điểm danh hàng ngày, coin, shop quà
│   └── vocab_provider.dart         ← Từ vựng theo cấp độ JLPT & yêu thích từ
│
├── routes/
│   └── app_router.dart             ← GoRouter config + class AppRoutes (hằng số route)
│
├── views/
│   ├── account/
│   │   ├── authen/                 ← login_screen.dart, register_screen.dart, forgot_password_screen.dart
│   │   └── profile/
│   │       ├── edit_info_user_screen.dart  ← Màn hình chỉnh sửa thông tin (tách riêng khỏi personal_info)
│   │       ├── favorites_screen.dart       ← Danh sách yêu thích (bài viết, từ vựng, ...)
│   │       ├── learning_stats_screen.dart  ← Thống kê học tập
│   │       ├── personal_info_screen.dart   ← Xem & chỉnh thông tin cá nhân
│   │       ├── profile_screen.dart         ← Trang hồ sơ chính (hub điều hướng)
│   │       ├── security_screen.dart        ← Đổi mật khẩu, bảo mật tài khoản
│   │       └── settings_screen.dart        ← Cài đặt ứng dụng (font, dark mode, ...)
│   │
│   ├── exam/
│   │   ├── exam_detail_screen.dart
│   │   └── exam_list_screen.dart
│   │
│   ├── exam_attempt/
│   │   └── exam_attempt_screen.dart
│   │
│   ├── exam_history/
│   │   ├── exam_history_review_screen.dart
│   │   └── exam_history_selector_screen.dart
│   │
│   ├── flashcard/
│   │   ├── create_flashcard_screen.dart    ← Tạo bộ thẻ (nhập tay hoặc import Excel/CSV)
│   │   ├── history_flashcard_quiz.dart     ← Lịch sử kết quả quiz flashcard
│   │   ├── my_sets_screen.dart
│   │   ├── quiz_screen.dart
│   │   └── study_set_screen.dart
│   │
│   ├── grammar/
│   │   └── grammar_study_screen.dart       ← Học ngữ pháp (thay vì vocab_kanji_grammar/)
│   │
│   ├── home/
│   │   ├── home_screen.dart
│   │   └── japanese_search_screen.dart     ← Tra cứu từ điển (đặt trong home/, không phải vocab_kanji_grammar/)
│   │
│   ├── kanji/
│   │   └── kanji_study_screen.dart         ← Học chữ Hán
│   │
│   ├── news/
│   │   └── news_screen.dart                ← Tin tức (đặt tại views/news/, KHÔNG phải views/account/news/)
│   │
│   ├── payment/
│   │   ├── checkout_screen.dart
│   │   └── payment_history_screen.dart
│   │
│   ├── rewards/
│   │   ├── reward_shop_screen.dart
│   │   └── streak_calendar_screen.dart
│   │
│   ├── sample_sentence/
│   │   └── sentence_screen.dart
│   │
│   └── vocab/
│       └── vocab_study_screen.dart         ← Học từ vựng theo JLPT
│
├── widgets/
│   ├── add_menu_button.dart    ← GlobalAddMenuButton: nút menu nổi (cài đặt nhanh)
│   ├── app_bar.dart            ← Custom AppBar đồng bộ theme
│   └── app_setting.dart        ← Bottom sheet chỉnh font size & dark mode nhanh
│
├── firebase_options.dart
└── main.dart
```

> **Lưu ý quan trọng về vị trí file:** `news_screen.dart` nằm tại `views/news/`, KHÔNG phải `views/account/news/`. Các màn hình học tập (`grammar`, `kanji`, `vocab`) mỗi loại có thư mục riêng, KHÔNG gộp vào `vocab_kanji_grammar/`.

---

## 3. Hệ Thống Điều Hướng (Routing)

Tất cả route được định nghĩa tập trung trong `lib/routes/app_router.dart`.

### Hằng số route (`AppRoutes`):
| Hằng số | Đường dẫn | Màn hình |
|---|---|---|
| `home` | `/` | `HomeScreen` |
| `login` | `/login` | `LoginScreen` (query: `?email=`) |
| `register` | `/register` | `RegisterScreen` (extra: `{email, password}`) |
| `forgotPassword` | `/forgot-password` | `ForgotPasswordScreen` |
| `exams` | `/exams` | `ExamListScreen` |
| `examDetail` | `/exams/:examId` | `ExamDetailScreen` (extra: `Exam` object) |
| `examAttempt` | `/exams/:examId/attempt` | `ExamAttemptScreen` |
| `examHistory` | `/exams/:examId/history` | `ExamHistorySelectorScreen` |
| `examHistoryReview` | `/exams/:examId/history/review` | `ExamHistoryReviewScreen` (extra: `int? attemptId`) |
| `flashcards` | `/flashcards` | `MySetsScreen` |
| `flashcardCreate` | `/flashcards/create` | `CreateSetScreen` |
| `flashcardStudy` | `/flashcards/:setId/study` | `StudySetScreen` (extra: `{setName, cardCount}`) |
| `flashcardQuiz` | `/flashcards/:setId/quiz` | `QuizScreen` (extra: `{setName, cards}`) |
| `flashcardQuizHistory` | `/flashcards/:setId/quiz/history` | `HistoryFlashcardQuiz` (extra: `String setName`) |
| `profile` | `/profile` | `ProfileScreen` |
| `profileInfo` | `/profile/info` | `PersonalInfoScreen` |
| `profileSecurity` | `/profile/security` | `SecurityScreen` |
| `profileFavorites` | `/profile/favorites` | `FavoritesScreen` |
| `profileStats` | `/profile/stats` | `LearningStatsScreen` |
| `profileSettings` | `/profile/settings` | `SettingsScreen` |
| `news` | `/news` | `NewsScreen` (extra: `Map<String,String>?` targetArticle) |
| `sentence` | `/sentence` | `SentenceScreen` |
| `rewards` | `/rewards` | `RewardShopScreen` (extra: `int` coins) |
| `streak` | `/streak` | `StreakCalendarScreen` |
| `paymentCheckout` | `/payment/checkout` | `CheckoutScreen` (extra: `{currentCoins, onCoinsUpdated, selectedVoucher}`) |
| `paymentHistory` | `/payment/history` | `PaymentHistoryScreen` (extra: `int` coins) |
| `search` | `/search` | `JapaneseSearchScreen` |
| `vocab` | `/vocab` | `VocabStudyScreen` |
| `kanji` | `/kanji` | `KanjiStudyScreen` |
| `grammar` | `/grammar` | `GrammarStudyScreen` |

### Hàm helper điều hướng có param:
```dart
examDetailPath(String examId)         // '/exams/$examId'
examAttemptPath(String examId)
examHistoryPath(String examId)
examHistoryReviewPath(String examId)
flashcardStudyPath(String setId)
flashcardQuizPath(String setId)
flashcardQuizHistoryPath(String setId)
```

---

## 4. Công Nghệ & Thư Viện (Tech Stack)

| Thư viện | Phiên bản | Mục đích |
|---|---|---|
| `flutter_riverpod` | ^2.6.1 | State management duy nhất (ViewModel) |
| `go_router` | ^14.8.1 | Điều hướng màn hình |
| `http` | ^1.6.0 | Gọi REST API Spring Boot |
| `firebase_core` | ^4.9.0 | Firebase khởi tạo |
| `firebase_auth` | ^6.5.1 | Xác thực người dùng |
| `firebase_storage` | ^13.4.1 | Lưu trữ hình ảnh người dùng |
| `firebase_messaging` | ^16.4.1 | Push notifications |
| `cloud_firestore` | ^6.0.0 | Lưu trữ Firestore (flashcard data) |
| `google_sign_in` | ^6.2.1 | Đăng nhập Google |
| `shared_preferences` | ^2.5.5 | Lưu cài đặt cục bộ (dark mode, font size) |
| `audioplayers` | ^5.2.1 | Phát audio bài thi nghe & tin tức |
| `flutter_tts` | ^4.1.1 | Text-to-speech |
| `image_picker` | ^1.1.2 | Chọn ảnh đại diện |
| `intl` | ^0.19.0 | Định dạng ngày giờ |

**Môi trường:**
- Flutter SDK: `3.41.9`  
- Dart SDK: `^3.11.5`
- Package name: `japanese_learning` (dùng trong import: `package:japanese_learning/...`)

**Backend:** Spring Boot REST API chạy tại port `8080`.  
Base URL tự động detect trong mỗi Service:
```dart
static String get baseUrl {
  if (kIsWeb) return 'http://localhost:8080';
  try {
    return Platform.isAndroid ? 'http://10.0.2.2:8080' : 'http://localhost:8080';
  } catch (_) {
    return 'http://localhost:8080';
  }
}
```

**Response format chuẩn của Backend:**
```json
{ "data": <payload> }
```
Mọi Service đều parse theo dạng: `json.decode(utf8.decode(response.bodyBytes))` → lấy `decodedData['data']`.

---

## 5. Các Pattern Code Thực Tế Trong Dự Án

### Pattern Model
```dart
class XxxModel {
  final int id;
  final String name;

  XxxModel({required this.id, required this.name});

  factory XxxModel.fromJson(Map<String, dynamic> json) {
    return XxxModel(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
    );
  }
}
```

### Pattern Service
```dart
class XxxService {
  static String get baseUrl { /* detect Android/Web */ }

  Future<List<XxxModel>> fetchXxx() async {
    final uri = Uri.parse('$baseUrl/xxx');
    final response = await http.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode == 200) {
      final decodedData = json.decode(utf8.decode(response.bodyBytes));
      if (decodedData is Map<String, dynamic> && decodedData.containsKey('data')) {
        final dataField = decodedData['data'];
        if (dataField is List) {
          return dataField.map((item) => XxxModel.fromJson(item)).toList();
        }
      }
    }
    throw Exception('Server error: ${response.statusCode}');
  }
}
```

### Pattern Repository
```dart
class XxxRepository {
  final XxxService _service;
  XxxRepository({XxxService? service}) : _service = service ?? XxxService();

  Future<List<XxxModel>> getXxx() async {
    try {
      return await _service.fetchXxx();
    } catch (_) {
      return []; // Trả về giá trị mặc định thay vì rethrow
    }
  }
}
```

### Pattern State (Immutable + copyWith)
```dart
class XxxState {
  final bool isLoading;
  final List<XxxModel> items;
  final String? error;

  XxxState({this.isLoading = false, this.items = const [], this.error});

  XxxState copyWith({bool? isLoading, List<XxxModel>? items, String? error}) {
    return XxxState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: error ?? this.error,
    );
  }
}
```

### Pattern Provider (Notifier)
```dart
class XxxNotifier extends Notifier<XxxState> {
  final _repository = XxxRepository();

  @override
  XxxState build() {
    Future.microtask(() => loadXxx()); // Tải dữ liệu ngay khi khởi tạo
    return XxxState();
  }

  Future<void> loadXxx() async {
    state = state.copyWith(isLoading: true);
    try {
      final items = await _repository.getXxx();
      state = state.copyWith(items: items, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final xxxProvider = NotifierProvider<XxxNotifier, XxxState>(XxxNotifier.new);
```

### Pattern View (ConsumerStatefulWidget)
```dart
class XxxScreen extends ConsumerStatefulWidget {
  const XxxScreen({super.key});
  @override
  ConsumerState<XxxScreen> createState() => _XxxScreenState();
}

class _XxxScreenState extends ConsumerState<XxxScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(xxxProvider.notifier).loadXxx());
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(xxxProvider);
    // build UI từ state
  }
}
```

---

## 6. Provider đặc biệt: `appSettingProvider`

`appSettingProvider` dùng `SharedPreferences` để lưu cài đặt. Được override trong `main.dart`:
```dart
ProviderScope(
  overrides: [sharedPreferencesProvider.overrideWithValue(sharedPreferences)],
  child: const MyApp(),
)
```

Cách đọc settings trong bất kỳ Widget nào:
```dart
final settings = ref.watch(appSettingProvider);
final isDark = settings.isDarkMode;
final scale = settings.textScaleFactor;
```

`MyApp` dùng `ConsumerWidget` để lắng nghe `appSettingProvider` và áp dụng `ThemeData` toàn app.

---

## 7. Hướng Dẫn Dành Cho AI Khi Hỗ Trợ Fix Bug / Viết Code

### Quy tắc bắt buộc:
1. **Tuân thủ luồng MVVM**: Service → Repository → Provider/Notifier → View. Tuyệt đối không gọi Service từ View.
2. **State phải immutable**: Mọi thay đổi state dùng `copyWith`, không mutate trực tiếp.
3. **Dùng GoRouter**: Điều hướng bằng `context.push()`, `context.go()`, `context.pop()`. Không dùng `Navigator.push()` (ngoại lệ: một số màn hình cũ vẫn dùng `Navigator.pop()` để quay lại).
4. **Truyền data qua route**: Dùng `state.extra` (object) hoặc `state.uri.queryParameters` (string), không dùng `state.pathParameters` cho data phức tạp.
5. **Naming convention**: File dùng `snake_case`. Class dùng `PascalCase`. Provider đặt tên `xxxProvider`, Notifier đặt tên `XxxNotifier`, State đặt tên `XxxState`.
6. **Import path**: Luôn dùng relative import trong cùng package (ví dụ: `import '../../../providers/news_provider.dart'`).
7. **Timeout HTTP**: Tất cả request đều có `.timeout(const Duration(seconds: 8))`.
8. **Decode UTF-8**: Luôn dùng `utf8.decode(response.bodyBytes)` thay vì `response.body` để tránh lỗi tiếng Nhật/Việt.
9. **Yêu thích (Favorites)**: Pattern "optimistic update" — cập nhật UI trước, đồng bộ server sau, rollback nếu lỗi (xem `news_provider.dart` → `toggleFavorite`).
10. **Thêm màn hình mới**: (1) Tạo model → (2) Tạo service → (3) Tạo repository → (4) Tạo provider + state → (5) Tạo screen → (6) Đăng ký route trong `app_router.dart` + thêm hằng số vào `AppRoutes`.
