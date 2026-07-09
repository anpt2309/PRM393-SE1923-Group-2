import '../models/news.dart';
import '../services/news_service.dart';

class NewsRepository {
  final NewsService _newsService;

  NewsRepository({NewsService? newsService})
      : _newsService = newsService ?? NewsService();

  Future<List<NewsCategory>> getCategories() async {
    return _newsService.fetchCategories();
  }

  Future<List<NewsArticle>> getArticles(String categorySlug) async {
    return _newsService.fetchArticles(categorySlug);
  }

  Future<NewsArticle> getArticleById(int id) async {
    return _newsService.fetchArticleById(id);
  }

  Future<String> getNote(int userId, int articleId) async {
    return _newsService.fetchNote(userId, articleId);
  }

  Future<String> saveNote(int userId, int articleId, String content) async {
    return _newsService.saveNote(userId, articleId, content);
  }

  Future<List<int>> getFavoriteArticleIds(int userId) async {
    try {
      return await _newsService.fetchFavoriteArticleIds(userId);
    } catch (_) {
      return [];
    }
  }

  Future<bool> toggleFavoriteArticle(int userId, int articleId) async {
    try {
      return await _newsService.toggleFavoriteArticle(userId, articleId);
    } catch (_) {
      return false;
    }
  }

  Future<List<NewsArticle>> getFavoriteArticles(int userId) async {
    try {
      return await _newsService.fetchFavoriteArticles(userId);
    } catch (_) {
      return [];
    }
  }
}
