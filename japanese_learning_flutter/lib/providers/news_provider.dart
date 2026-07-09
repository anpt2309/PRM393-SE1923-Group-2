import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/news.dart';
import '../data/repositories/news_repository.dart';

class NewsState {
  final bool isLoading;
  final List<NewsCategory> categories;
  final List<NewsArticle> articles;
  final NewsCategory? selectedCategory;
  final NewsArticle? selectedArticle;
  final bool showDetail;
  final String currentSubTab;
  final Set<int> favoriteArticleIds;
  final Map<int, String> articleNotes;
  final Map<int, String> noteSavedTimes;

  NewsState({
    this.isLoading = false,
    this.categories = const [],
    this.articles = const [],
    this.selectedCategory,
    this.selectedArticle,
    this.showDetail = false,
    this.currentSubTab = 'Script',
    this.favoriteArticleIds = const {},
    this.articleNotes = const {},
    this.noteSavedTimes = const {},
  });

  NewsState copyWith({
    bool? isLoading,
    List<NewsCategory>? categories,
    List<NewsArticle>? articles,
    NewsCategory? selectedCategory,
    NewsArticle? selectedArticle,
    bool? showDetail,
    String? currentSubTab,
    Set<int>? favoriteArticleIds,
    Map<int, String>? articleNotes,
    Map<int, String>? noteSavedTimes,
  }) {
    return NewsState(
      isLoading: isLoading ?? this.isLoading,
      categories: categories ?? this.categories,
      articles: articles ?? this.articles,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedArticle: selectedArticle ?? this.selectedArticle,
      showDetail: showDetail ?? this.showDetail,
      currentSubTab: currentSubTab ?? this.currentSubTab,
      favoriteArticleIds: favoriteArticleIds ?? this.favoriteArticleIds,
      articleNotes: articleNotes ?? this.articleNotes,
      noteSavedTimes: noteSavedTimes ?? this.noteSavedTimes,
    );
  }
}

class NewsNotifier extends Notifier<NewsState> {
  final _repository = NewsRepository();

  @override
  NewsState build() {
    Future.microtask(() => loadFavoriteArticleIds());
    return NewsState();
  }

  Future<void> loadFavoriteArticleIds() async {
    try {
      final favoriteIds = await _repository.getFavoriteArticleIds(1);
      state = state.copyWith(favoriteArticleIds: favoriteIds.toSet());
    } catch (_) {}
  }

  Future<void> loadInitialData() async {
    state = state.copyWith(isLoading: true);
    try {
      final categories = await _repository.getCategories();
      if (categories.isNotEmpty) {
        final firstCategory = categories.first;
        final articles = await _repository.getArticles(firstCategory.categorySlug);
        state = state.copyWith(
          categories: categories,
          articles: articles,
          selectedCategory: firstCategory,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          categories: [],
          articles: [],
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> selectCategory(NewsCategory category) async {
    state = state.copyWith(isLoading: true, selectedCategory: category);
    try {
      final articles = await _repository.getArticles(category.categorySlug);
      state = state.copyWith(
        articles: articles,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadNoteForArticle(int articleId) async {
    try {
      final content = await _repository.getNote(1, articleId);
      final updatedNotes = Map<int, String>.from(state.articleNotes);
      updatedNotes[articleId] = content;
      state = state.copyWith(
        articleNotes: updatedNotes,
      );
    } catch (_) {}
  }

  Future<void> selectArticle(NewsArticle article) async {
    state = state.copyWith(
      selectedArticle: article,
      showDetail: true,
      currentSubTab: 'Script',
      isLoading: true,
    );
    try {
      final detailedArticle = await _repository.getArticleById(article.id);
      state = state.copyWith(
        selectedArticle: detailedArticle,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
    await loadNoteForArticle(article.id);
  }

  Future<void> selectArticleByMap(Map<String, String> target) async {
    final title = target['title'];
    final idStr = target['id'];
    if (idStr != null) {
      final id = int.tryParse(idStr);
      if (id != null) {
        state = state.copyWith(isLoading: true);
        try {
          final article = await _repository.getArticleById(id);
          state = state.copyWith(
            selectedArticle: article,
            showDetail: true,
            isLoading: false,
          );
          await loadNoteForArticle(article.id);
        } catch (_) {
          state = state.copyWith(isLoading: false);
        }
      }
    } else if (title != null) {
      if (state.articles.isEmpty) {
        state = state.copyWith(isLoading: true);
        try {
          final articles = await _repository.getArticles('all');
          state = state.copyWith(articles: articles, isLoading: false);
        } catch (_) {
          state = state.copyWith(isLoading: false);
        }
      }
      final match = state.articles.firstWhere(
        (a) => a.title == title,
        orElse: () => state.articles.isNotEmpty ? state.articles.first : NewsArticle(
          id: 0,
          categoryId: 0,
          categorySlug: '',
          title: title,
          description: '',
          imageUrl: '',
          audioUrl: '',
          contentKanjiScript: '',
          contentTranslation: '',
          vocabularies: [],
          spans: [],
        ),
      );
      state = state.copyWith(
        selectedArticle: match,
        showDetail: true,
      );
      if (match.id != 0) {
        state = state.copyWith(isLoading: true);
        try {
          final detailedArticle = await _repository.getArticleById(match.id);
          state = state.copyWith(
            selectedArticle: detailedArticle,
            isLoading: false,
          );
        } catch (_) {
          state = state.copyWith(isLoading: false);
        }
        await loadNoteForArticle(match.id);
      }
    }
  }

  void goBackToList() {
    state = state.copyWith(
      showDetail: false,
      selectedArticle: null,
    );
  }

  void changeSubTab(String subTab) {
    state = state.copyWith(currentSubTab: subTab);
  }

  Future<void> toggleFavorite(int articleId) async {
    final originalFavorites = state.favoriteArticleIds;
    final isCurrentlyFavorited = originalFavorites.contains(articleId);

    // Optimistic update
    final newFavorites = Set<int>.from(originalFavorites);
    if (isCurrentlyFavorited) {
      newFavorites.remove(articleId);
    } else {
      newFavorites.add(articleId);
    }
    state = state.copyWith(favoriteArticleIds: newFavorites);

    try {
      final serverState = await _repository.toggleFavoriteArticle(1, articleId);
      final finalFavorites = Set<int>.from(state.favoriteArticleIds);
      if (serverState) {
        finalFavorites.add(articleId);
      } else {
        finalFavorites.remove(articleId);
      }
      state = state.copyWith(favoriteArticleIds: finalFavorites);
    } catch (_) {
      state = state.copyWith(favoriteArticleIds: originalFavorites);
    }
  }

  Future<void> saveNote(int articleId, String content) async {
    try {
      final savedContent = await _repository.saveNote(1, articleId, content);
      final updatedNotes = Map<int, String>.from(state.articleNotes);
      final updatedSavedTimes = Map<int, String>.from(state.noteSavedTimes);

      updatedNotes[articleId] = savedContent;

      final now = DateTime.now();
      final timeStr = "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')} - ${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
      updatedSavedTimes[articleId] = timeStr;

      state = state.copyWith(
        articleNotes: updatedNotes,
        noteSavedTimes: updatedSavedTimes,
      );
    } catch (_) {}
  }
}

final newsProvider = NotifierProvider<NewsNotifier, NewsState>(
  NewsNotifier.new,
);
