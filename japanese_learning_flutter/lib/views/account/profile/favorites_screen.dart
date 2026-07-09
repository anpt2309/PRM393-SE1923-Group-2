import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/news.dart';
import '../../../data/models/vocabulary.dart';
import '../../../data/repositories/news_repository.dart';
import '../../../data/repositories/vocab_repository.dart';
import '../../../providers/app_setting_provider.dart';
import '../../../providers/news_provider.dart';
import '../../../providers/vocab_provider.dart';
import '../../../widgets/app_bar.dart';
import '../../news/news_screen.dart';
import '../../vocab/vocab_detail_screen.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  String selectedFilter = 'news';
  bool _isLoading = false;
  List<NewsArticle> _newsFavorites = [];
  List<VocabularyWord> _vocabFavorites = [];

  final NewsRepository _newsRepository = NewsRepository();
  final VocabRepository _vocabRepository = VocabRepository();

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  Future<void> _fetchFavorites() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
    });

    try {
      if (selectedFilter == 'news') {
        final list = await _newsRepository.getFavoriteArticles(1);
        if (mounted) {
          setState(() {
            _newsFavorites = list;
            _isLoading = false;
          });
        }
      } else {
        final list = await _vocabRepository.getFavoriteVocabs(1);
        if (mounted) {
          setState(() {
            _vocabFavorites = list;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint("Error fetching favorites: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteFavoriteNews(NewsArticle article) async {
    try {
      setState(() {
        _newsFavorites.removeWhere((item) => item.id == article.id);
      });
      await _newsRepository.toggleFavoriteArticle(1, article.id);
      ref.read(newsProvider.notifier).loadFavoriteArticleIds();
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xoá "${article.title}" khỏi danh sách yêu thích.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      debugPrint("Error deleting favorite news: $e");
    }
  }

  Future<void> _deleteFavoriteVocab(VocabularyWord word) async {
    try {
      setState(() {
        _vocabFavorites.removeWhere((item) => item.id == word.id);
      });
      await _vocabRepository.toggleFavoriteVocab(1, word.id);
      ref.read(vocabStudyProvider.notifier).loadFavoriteVocabIds();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã xoá "${word.word}" khỏi danh sách yêu thích.'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (e) {
      debugPrint("Error deleting favorite vocab: $e");
    }
  }

  void _viewNewsDetail(NewsArticle article) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NewsScreen(
          targetArticle: {
            'id': article.id.toString(),
            'title': article.title,
          },
        ),
      ),
    ).then((_) {
      // Reload on returning in case they unfavorited inside the screen
      _fetchFavorites();
    });
  }

  void _viewVocabDetail(VocabularyWord word) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VocabDetailScreen(
          singleWord: word,
        ),
      ),
    ).then((_) {
      // Reload on returning in case they unfavorited inside the screen
      _fetchFavorites();
    });
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

    final hasItems = selectedFilter == 'news' ? _newsFavorites.isNotEmpty : _vocabFavorites.isNotEmpty;

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
                          DropdownMenuItem(value: 'items', child: Text('Từ vựng')),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => selectedFilter = value);
                            _fetchFavorites();
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
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.blueAccent,
                    ),
                  )
                : !hasItems
                    ? Center(
                        child: Text(
                          'Chưa có mục yêu thích nào.',
                          style: TextStyle(color: subTextColor.withValues(alpha: 0.6), fontSize: 15),
                        ),
                      )
                    : selectedFilter == 'news'
                        ? ListView.builder(
                            itemCount: _newsFavorites.length,
                            padding: const EdgeInsets.only(bottom: 16),
                            itemBuilder: (context, index) {
                              final article = _newsFavorites[index];
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
                                      Icons.article_outlined,
                                      color: subTextColor.withValues(alpha: 0.7),
                                      size: 22 * scale,
                                    ),
                                  ),
                                  title: Text(
                                    article.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: textColor),
                                  ),
                                  subtitle: article.description != null && article.description!.isNotEmpty
                                      ? Text(
                                          article.description!,
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
                                        onPressed: () => _viewNewsDetail(article),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete_outline, color: subTextColor.withValues(alpha: 0.6), size: 22 * scale),
                                        onPressed: () => _deleteFavoriteNews(article),
                                      ),
                                    ],
                                  ),
                                  onTap: () => _viewNewsDetail(article),
                                ),
                              );
                            },
                          )
                        : ListView.builder(
                            itemCount: _vocabFavorites.length,
                            padding: const EdgeInsets.only(bottom: 16),
                            itemBuilder: (context, index) {
                              final word = _vocabFavorites[index];
                              final subTitleText = '${word.hiragana} - ${word.vietnameseMeaning}';
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
                                      Icons.favorite_outline,
                                      color: subTextColor.withValues(alpha: 0.7),
                                      size: 22 * scale,
                                    ),
                                  ),
                                  title: Text(
                                    word.word,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: textColor),
                                  ),
                                  subtitle: Text(
                                    subTitleText,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 12, color: subTextColor.withValues(alpha: 0.7)),
                                  ),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.visibility_outlined, color: Colors.blueAccent, size: 22 * scale),
                                        onPressed: () => _viewVocabDetail(word),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete_outline, color: subTextColor.withValues(alpha: 0.6), size: 22 * scale),
                                        onPressed: () => _deleteFavoriteVocab(word),
                                      ),
                                    ],
                                  ),
                                  onTap: () => _viewVocabDetail(word),
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
