import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/app_setting_provider.dart';
import '../../providers/auth_provider.dart';
import 'japanese_search_screen.dart';

// --- CÁC MÀN HÌNH ĐÍch TẠM THỜI ---

class FlashcardScreenPlaceholder extends StatelessWidget {
  const FlashcardScreenPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Flashcard (Bộ thẻ)')),
    body: const Center(child: Text('Quản lý bộ thẻ tự học từ TABLE flashcard_sets')),
  );
}

class ExamListScreenPlaceholder extends StatelessWidget {
  const ExamListScreenPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Thi thử JLPT')),
    body: const Center(child: Text('Danh sách đề thi có sẵn từ TABLE exams')),
  );
}

class DictionaryScreenPlaceholder extends ConsumerWidget {
  final String title;
  const DictionaryScreenPlaceholder({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingProvider);
    final isCustomDark = settings.isDarkMode;
    final backgroundColor = isCustomDark ? const Color(0xFF161616) : const Color(0xFFF8F9FA);
    final textColor = isCustomDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(title, style: TextStyle(color: textColor)),
        backgroundColor: isCustomDark ? const Color(0xFF212121) : Colors.white,
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: Center(
        child: Text(
          'Dữ liệu tra cứu gốc từ kho dữ liệu hệ thống',
          style: TextStyle(color: textColor),
        ),
      ),
    );
  }
}

class RewardShopScreenPlaceholder extends StatelessWidget {
  const RewardShopScreenPlaceholder({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Cửa hàng đổi quà')),
    body: const Center(child: Text('Sử dụng coin để đổi thưởng từ TABLE rewards')),
  );
}

// --- MÀN HÌNH CHÍNH HOMESCREEN ---
// Đã chuyển sang ConsumerWidget để dùng appSettingProvider (Riverpod).
// Không còn phụ thuộc vào global singleton appSettings + ListenableBuilder.

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  void _navigateToFeature(BuildContext context, String featureType) {
    switch (featureType) {
      case 'news': context.push('/news'); break;
      case 'flashcard': context.push('/flashcards'); break;
      case 'sentences': context.push('/sentence'); break;
      case 'exams': context.push('/exams'); break;
      case 'vocab': context.push('/vocab'); break;
      case 'kanji': context.push('/kanji'); break;
      case 'grammar': context.push('/grammar'); break;
      case 'rewards': context.push('/rewards'); break;
      default: return;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingProvider);
    final isDarkMode = settings.isDarkMode;

    final backgroundColor = isDarkMode ? const Color(0xFF161616) : const Color(0xFFF4F6F9);
    final cardColor = isDarkMode ? const Color(0xFF212121) : Colors.white;
    final textColor = isDarkMode ? Colors.white.withValues(alpha: 0.9) : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildDbHeaderSection(context, ref, cardColor, textColor, subTextColor, isDarkMode),
            const SizedBox(height: 16),
            _buildDbGridMenuSection(context, cardColor, textColor),
            const SizedBox(height: 16),
            _buildStreakRewardBanner(context),
            const SizedBox(height: 16),
            _buildQuickAccessSection(context, cardColor, textColor),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // --- 1. KHỐI HEADER ---
  Widget _buildDbHeaderSection(BuildContext context, WidgetRef ref, Color cardColor, Color textColor, Color subTextColor, bool isDarkMode) {
    final authState = ref.watch(authProvider);
    final userPhoto = authState.photoUrl;
    final userName = authState.displayName ?? (authState.isSignedIn ? authState.email?.split('@')[0] : 'Người dùng');

    // Logic chào hỏi thông minh theo thời gian thực
    final now = DateTime.now();
    final hour = now.hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Chào buổi sáng 🌤️';
    } else if (hour < 18) {
      greeting = 'Chào buổi chiều ☀️';
    } else {
      greeting = 'Chào buổi tối 🌙';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 54, 16, 20),
      decoration: BoxDecoration(
        color: isDarkMode ? const Color(0xFF003F7F) : const Color(0xFF1E88E5),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => context.push('/profile'),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                  child: CircleAvatar(
                    radius: 22,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: userPhoto != null
                        ? NetworkImage('$userPhoto${userPhoto.contains('?') ? '&' : '?'}t=${authState.avatarTimestamp}')
                        : const NetworkImage('https://cdn-icons-png.flaticon.com/512/149/149071.png'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    userName ?? 'Người dùng',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(greeting, style: TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 13)),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push('/profile/settings'),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.settings, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const JapaneseSearchWidget(),
        ],
      ),
    );
  }

  // --- 2. GRID MENU ---
  Widget _buildDbGridMenuSection(BuildContext context, Color cardColor, Color textColor) {
    final List<Map<String, dynamic>> dbFeatures = [
      {'id': 'news', 'title': 'Tin tức', 'icon': Icons.newspaper, 'color': Colors.blue.shade600},
      {'id': 'flashcard', 'title': 'Flashcard', 'icon': Icons.style, 'color': Colors.teal.shade500},
      {'id': 'sentences', 'title': 'Luyện mẫu câu', 'icon': Icons.extension, 'color': Colors.orange.shade700},
      {'id': 'exams', 'title': 'Luyện thi JLPT', 'icon': Icons.assignment, 'color': Colors.purple.shade600},
      {'id': 'vocab', 'title': 'Từ vựng', 'icon': Icons.translate, 'color': Colors.green.shade600},
      {'id': 'kanji', 'title': 'Chữ Hán', 'icon': Icons.g_translate, 'color': Colors.indigo.shade500},
      {'id': 'grammar', 'title': 'Ngữ pháp', 'icon': Icons.menu_book, 'color': Colors.amber.shade800},
      {'id': 'rewards', 'title': 'Đổi quà', 'icon': Icons.card_giftcard, 'color': Colors.pink.shade500},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: dbFeatures.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              childAspectRatio: 1.2,
            ),
            itemBuilder: (context, index) {
              final feature = dbFeatures[index];
              return InkWell(
                onTap: () => _navigateToFeature(context, feature['id']),
                borderRadius: BorderRadius.circular(12),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: (feature['color'] as Color).withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(feature['icon'] as IconData, color: feature['color'] as Color, size: 26),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      feature['title'] as String,
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: textColor, height: 1.2),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // --- 3. BANNER STREAK ---
  Widget _buildStreakRewardBanner(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: InkWell(
        onTap: () => context.push('/profile/stats'),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(colors: [Color(0xFF0288D1), Color(0xFF0077C2)]),
          ),
          child: Row(
            children: [
              const Icon(Icons.analytics_outlined, color: Colors.white, size: 36),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Thống kê học tập cá nhân', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text('Xem lại biểu đồ chuỗi streak và tiến độ học', style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.white.withValues(alpha: 0.7), size: 16)
            ],
          ),
        ),
      ),
    );
  }

  // --- 4. QUICK ACCESS ---
  Widget _buildQuickAccessSection(BuildContext context, Color cardColor, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () => context.push('/profile/favorites'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 22),
                    const SizedBox(width: 10),
                    Text('Mục yêu thích', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: () => context.push('/profile/settings'),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(Icons.settings, color: Colors.blueGrey, size: 22),
                    const SizedBox(width: 10),
                    Text('Cấu hình UI app', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: textColor)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}