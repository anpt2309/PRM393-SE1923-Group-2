import 'package:go_router/go_router.dart';
import 'package:japanese_learning/views/account/authen/login_screen.dart';
import 'package:japanese_learning/views/account/authen/register_screen.dart';
import 'package:japanese_learning/views/account/news/news_screen.dart';
import 'package:japanese_learning/views/account/profile/favorites_screen.dart';
import 'package:japanese_learning/views/account/profile/learning_stats_screen.dart';
import 'package:japanese_learning/views/account/profile/personal_info_screen.dart';
import 'package:japanese_learning/views/account/profile/profile_screen.dart';
import 'package:japanese_learning/views/account/profile/security_screen.dart';
import 'package:japanese_learning/views/account/profile/settings_screen.dart';
import 'package:japanese_learning/views/account/sample_sentence/sentence_screen.dart';
import 'package:japanese_learning/views/exam/exam_detail_screen.dart';
import 'package:japanese_learning/views/exam/exam_list_screen.dart';
import 'package:japanese_learning/views/exam_attempt/exam_attempt_screen.dart';
import 'package:japanese_learning/views/exam_history/exam_history_review_screen.dart';
import 'package:japanese_learning/views/exam_history/exam_history_selector_screen.dart';
import 'package:japanese_learning/views/flashcard/history_flashcard_quiz.dart';
import 'package:japanese_learning/views/flashcard/my_sets_screen.dart';
import 'package:japanese_learning/views/flashcard/quiz_screen.dart';
import 'package:japanese_learning/views/flashcard/study_set_screen.dart';
import 'package:japanese_learning/views/home/HomeScreen.dart';
import 'package:japanese_learning/views/payment/checkout_screen.dart';
import 'package:japanese_learning/views/payment/payment_history_screen.dart';
import 'package:japanese_learning/views/rewards/reward_shop_screen.dart';
import 'package:japanese_learning/views/rewards/streak_calendar_screen.dart';
import 'package:japanese_learning/views/flashcard/create_flashcard_screen.dart';
import 'package:japanese_learning/views/vocab_kanji_grammar/grammar_study_screen.dart';
import 'package:japanese_learning/views/vocab_kanji_grammar/japanese_search_screen.dart';
import 'package:japanese_learning/views/vocab_kanji_grammar/kanji_study_screen.dart';
import 'package:japanese_learning/views/vocab_kanji_grammar/vocab_study_screen.dart';
import 'package:japanese_learning/data/models/exam.dart';

/// Định nghĩa các đường dẫn route tập trung tại một nơi.
/// Dùng hằng số để tránh lỗi typo khi gọi điều hướng.
class AppRoutes {
  static const home = '/';
  static const login = '/login';
  static const register = '/register';

  // Exam
  static const exams = '/exams';
  static const examDetail = '/exams/:examId';
  static const examAttempt = '/exams/:examId/attempt';
  static const examHistory = '/exams/:examId/history';
  static const examHistoryReview = '/exams/:examId/history/review';

  // Flashcard
  static const flashcards = '/flashcards';
  static const flashcardCreate = '/flashcards/create';
  static const flashcardStudy = '/flashcards/:setId/study';
  static const flashcardQuiz = '/flashcards/:setId/quiz';
  static const flashcardQuizHistory = '/flashcards/:setId/quiz/history';

  // Profile
  static const profile = '/profile';
  static const profileInfo = '/profile/info';
  static const profileSecurity = '/profile/security';
  static const profileFavorites = '/profile/favorites';
  static const profileStats = '/profile/stats';
  static const profileSettings = '/profile/settings';

  // Others
  static const news = '/news';
  static const sentence = '/sentence';
  static const rewards = '/rewards';
  static const streak = '/streak';
  static const paymentCheckout = '/payment/checkout';
  static const paymentHistory = '/payment/history';
  static const search = '/search';
  static const vocab = '/vocab';
  static const kanji = '/kanji';
  static const grammar = '/grammar';
}

/// Hàm tiện ích: Build đường dẫn exam có tham số examId cụ thể.
String examDetailPath(String examId) => '/exams/$examId';
String examAttemptPath(String examId) => '/exams/$examId/attempt';
String examHistoryPath(String examId) => '/exams/$examId/history';
String examHistoryReviewPath(String examId) => '/exams/$examId/history/review';
String flashcardStudyPath(String setId) => '/flashcards/$setId/study';
String flashcardQuizPath(String setId) => '/flashcards/$setId/quiz';
String flashcardQuizHistoryPath(String setId) => '/flashcards/$setId/quiz/history';

/// Cấu hình GoRouter chính của toàn bộ ứng dụng.
final appRouter = GoRouter(
  initialLocation: AppRoutes.home,
  routes: [
    // ─── Trang chủ ───────────────────────────────────────────
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomeScreen(),
    ),

    // ─── Xác thực ────────────────────────────────────────────
    GoRoute(
      path: AppRoutes.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      builder: (context, state) => const RegisterScreen(),
    ),

    // ─── Đề thi (Exam) ────────────────────────────────────────
    GoRoute(
      path: AppRoutes.exams,
      builder: (context, state) => const ExamListScreen(),
      routes: [
        GoRoute(
          path: ':examId',
          builder: (context, state) {
            // Nhận đối tượng Exam được truyền qua 'extra'
            final exam = state.extra as Exam;
            return ExamDetailScreen(exam: exam);
          },
          routes: [
            GoRoute(
              path: 'attempt',
              builder: (context, state) => const ExamAttemptScreen(),
            ),
            GoRoute(
              path: 'history',
              builder: (context, state) => const ExamHistorySelectorScreen(),
              routes: [
                GoRoute(
                  path: 'review',
                  builder: (context, state) => const ExamHistoryReviewScreen(),
                ),
              ],
            ),
          ],
        ),
      ],
    ),

    // ─── Flashcard ───────────────────────────────────────────
    GoRoute(
      path: AppRoutes.flashcards,
      builder: (context, state) => const MySetsScreen(),
      routes: [
        GoRoute(
          path: 'create',
          builder: (context, state) => const CreateSetScreen(),
        ),
        GoRoute(
          path: ':setId/study',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return StudySetScreen(
              setName: extra['setName'] as String,
              cardCount: extra['cardCount'] as int,
            );
          },
        ),
        GoRoute(
          path: ':setId/quiz',
          builder: (context, state) {
            final extra = state.extra as Map<String, dynamic>;
            return QuizScreen(
              setName: extra['setName'] as String,
              cards: extra['cards'] as List<Map<String, String>>,
            );
          },
        ),
        GoRoute(
          path: ':setId/quiz/history',
          builder: (context, state) {
            final setName = state.extra as String;
            return HistoryFlashcardQuiz(setName: setName);
          },
        ),
      ],
    ),

    // ─── Hồ sơ (Profile) ──────────────────────────────────────
    GoRoute(
      path: AppRoutes.profile,
      builder: (context, state) => const ProfileScreen(),
      routes: [
        GoRoute(
          path: 'info',
          builder: (context, state) => const PersonalInfoScreen(),
        ),
        GoRoute(
          path: 'security',
          builder: (context, state) => const SecurityScreen(),
        ),
        GoRoute(
          path: 'favorites',
          builder: (context, state) => const FavoritesScreen(),
        ),
        GoRoute(
          path: 'stats',
          builder: (context, state) => const LearningStatsScreen(),
        ),
        GoRoute(
          path: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),

    // ─── Tin tức / Câu mẫu ────────────────────────────────────
    GoRoute(
      path: AppRoutes.news,
      builder: (context, state) {
        // Hỗ trợ truyền targetArticle từ FavoritesScreen qua extra
        final article = state.extra is Map<String, String>
            ? state.extra as Map<String, String>
            : null;
        return NewsScreen(targetArticle: article);
      },
    ),
    GoRoute(
      path: AppRoutes.sentence,
      builder: (context, state) => const SentenceScreen(),
    ),

    // ─── Phần thưởng / Chuỗi ngày ────────────────────────────
    GoRoute(
      path: AppRoutes.rewards,
      builder: (context, state) {
        // Hỗ trợ truyền số coin từ StreakCalendarScreen qua extra
        final coins = state.extra is int ? state.extra as int : 0;
        return RewardShopScreen(currentCoins: coins);
      },
    ),
    GoRoute(
      path: AppRoutes.streak,
      builder: (context, state) => const StreakCalendarScreen(),
    ),

    // ─── Thanh toán ───────────────────────────────────────────
    GoRoute(
      path: AppRoutes.paymentCheckout,
      builder: (context, state) {
        final extra = state.extra as Map<String, dynamic>?;
        return CheckoutScreen(
          currentCoins: extra?['currentCoins'] as int? ?? 0,
          onCoinsUpdated: extra?['onCoinsUpdated'] as Function(int)?,
          selectedVoucher: extra?['selectedVoucher'] as Map<String, dynamic>?,
        );
      },
    ),
    GoRoute(
      path: AppRoutes.paymentHistory,
      builder: (context, state) {
        final coins = state.extra is int ? state.extra as int : 0;
        return PaymentHistoryScreen(currentCoins: coins);
      },
    ),
    GoRoute(
      path: AppRoutes.search,
      builder: (context, state) => const JapaneseSearchScreen(),
    ),
    GoRoute(
      path: AppRoutes.vocab,
      builder: (context, state) => const VocabStudyScreen(),
    ),
    GoRoute(
      path: AppRoutes.kanji,
      builder: (context, state) => const KanjiStudyScreen(),
    ),
    GoRoute(
      path: AppRoutes.grammar,
      builder: (context, state) => const GrammarStudyScreen(),
    ),
  ],
);
