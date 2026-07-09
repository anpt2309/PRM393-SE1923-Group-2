import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../providers/app_setting_provider.dart';
import '../../../widgets/app_bar.dart';
import 'package:japanese_learning/views/news/news_screen.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  String selectedFilter = 'news';
  List<Map<String, String>> favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites(selectedFilter);
  }

  void _loadFavorites(String type) {
    setState(() {
      favorites = type == 'news'
          ? [
        {
          'title': '「下着ユニバ」騒動 女性インスタグラマーが「聖地巡礼」',
          'subtitle': 'ネット衝撃「メンタル強すぎ」',
          'image': 'https://picsum.photos/id/101/200/200',
          'is_favorite': '1',
          'audio_url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3'
        },
        {
          'title': '日本の桜、今年は例年より早く開花するか',
          'subtitle': '気象庁の最新予測データ発表',
          'image': 'https://picsum.photos/id/102/200/200',
          'is_favorite': '1',
          'audio_url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3'
        },
        {
          'title': 'JLPT N5 読解対策：毎日の練習問題集',
          'subtitle': '基礎から学ぶ日本語読解のコツ',
          'image': 'https://picsum.photos/id/103/200/200',
          'is_favorite': '1',
          'audio_url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3'
        }
      ]
          : [
        {
          'title': '勉強 (Học tập)',
          'subtitle': 'Từ vựng thông dụng - Cấp độ N5',
          'type': 'vocabulary'
        },
        {
          'title': '学 (Học)',
          'subtitle': 'Kanji cơ bản - 8 nét',
          'type': 'kanji'
        },
        {
          'title': 'Ngữ pháp N5: ～から～まで',
          'subtitle': 'Video bài giảng thời lượng 5 phút',
          'type': 'video'
        },
      ];
    });
  }

  void _deleteFavorite(int index) {
    final removedItem = favorites[index]['title'] ?? '';
    setState(() {
      favorites.removeAt(index);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã xoá "$removedItem" khỏi danh sách yêu thích.'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _viewFavoriteDetail(Map<String, String> item, Color blockColor, Color textColor, Color subTextColor) {
    if (selectedFilter == 'news') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => NewsScreen(
            targetArticle: item,
          ),
        ),
      );
    } else {
      showModalBottomSheet(
        context: context,
        backgroundColor: blockColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: (context) => Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                item['title'] ?? '',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 4),
              Text(
                item['subtitle'] ?? '',
                style: TextStyle(fontSize: 13, color: subTextColor),
              ),
              const SizedBox(height: 12),
              Text(
                'Đây là nội dung chi tiết của mục yêu thích. Bạn có thể xem chi tiết từ vựng, hán tự chữ cứng hoặc liên kết video tương ứng cấu hình trong hệ thống học tập.',
                style: TextStyle(color: subTextColor.withValues(alpha: 0.8), height: 1.4, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, size: 18),
                label: const Text('Đóng'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final appSettings = ref.watch(appSettingProvider);
    final isDarkMode = appSettings.isDarkMode;
    final double scale = appSettings.textScaleFactor;

    final backgroundColor = isDarkMode ? const Color(0xFF121212) : const Color(0xFFF8F9FA);
    final blockColor = isDarkMode ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black87;
    final subTextColor = isDarkMode ? Colors.white60 : Colors.black54;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: const CustomAppBar(
        title: 'Yêu thích',
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              color: blockColor,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Row(
                  children: [
                    Icon(Icons.filter_list, color: subTextColor, size: 20 * scale),
                    const SizedBox(width: 12),
                    Text(
                      'Lọc theo loại:',
                      style: TextStyle(fontWeight: FontWeight.w500, color: subTextColor, fontSize: 14),
                    ),
                    const Spacer(),
                    DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedFilter,
                        dropdownColor: blockColor,
                        icon: Icon(Icons.keyboard_arrow_down, color: subTextColor),
                        style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 15),
                        items: const [
                          DropdownMenuItem(value: 'news', child: Text('Tin tức')),
                          DropdownMenuItem(value: 'items', child: Text('Từ vựng & Kanji')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedFilter = value);
                            _loadFavorites(value);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: favorites.isEmpty
                ? Center(
              child: Text(
                'Chưa có mục yêu thích nào.',
                style: TextStyle(color: subTextColor.withValues(alpha: 0.6), fontSize: 15),
              ),
            )
                : ListView.builder(
              itemCount: favorites.length,
              padding: const EdgeInsets.only(bottom: 16),
              itemBuilder: (context, index) {
                final item = favorites[index];
                return Card(
                  color: blockColor,
                  elevation: 0,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (isDarkMode ? Colors.white : Colors.black).withValues(alpha: 0.05),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        selectedFilter == 'news'
                            ? Icons.article_outlined
                            : Icons.favorite_outline,
                        color: subTextColor.withValues(alpha: 0.7),
                        size: 22 * scale,
                      ),
                    ),
                    title: Text(
                      item['title'] ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: textColor),
                    ),
                    subtitle: item['subtitle'] != null
                        ? Text(
                      item['subtitle']!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: subTextColor.withValues(alpha: 0.7)),
                    )
                        : null,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.visibility_outlined, color: Colors.blueAccent, size: 22 * scale),
                          onPressed: () => _viewFavoriteDetail(item, blockColor, textColor, subTextColor),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete_outline, color: subTextColor.withValues(alpha: 0.6), size: 22 * scale),
                          onPressed: () => _deleteFavorite(index),
                        ),
                      ],
                    ),
                    onTap: () => _viewFavoriteDetail(item, blockColor, textColor, subTextColor),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
