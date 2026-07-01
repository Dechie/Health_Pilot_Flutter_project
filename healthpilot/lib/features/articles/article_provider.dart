import 'package:flutter/foundation.dart';
import 'package:healthpilot/core/repositories/i_article_repository.dart';
import 'package:healthpilot/features/articles/article_feed_item.dart';

enum ArticleLoadStatus { idle, loading, loaded, error }

class ArticleProvider extends ChangeNotifier {
  final IArticleRepository _repo;

  List<ArticleFeedItem> _articles = [];
  ArticleLoadStatus _status = ArticleLoadStatus.idle;
  bool _loadStarted = false;

  List<ArticleFeedItem> get articles => List.unmodifiable(_articles);
  ArticleLoadStatus get status => _status;

  ArticleProvider(this._repo);

  Future<void> load() async {
    if (_loadStarted) return;
    _loadStarted = true;
    _status = ArticleLoadStatus.loading;
    notifyListeners();
    try {
      _articles = await _repo.fetchArticles();
      _status = ArticleLoadStatus.loaded;
    } catch (_) {
      _status = ArticleLoadStatus.error;
    } finally {
      notifyListeners();
    }
  }

  // ── Feed extras ──────────────────────────────────────────────────────────────
  Future<List<ArticleFeedItem>> fetchRecommended() => _repo.fetchRecommended();

  Future<List<ArticleFeedItem>> fetchBookmarks() => _repo.fetchBookmarks();

  Future<ArticleFeedItem> fetchArticle(String id) => _repo.fetchArticle(id);

  // ── Interactions ─────────────────────────────────────────────────────────────
  Future<void> likeArticle(String id) async {
    final liked = await _repo.likeArticle(id);
    _articles = [
      for (final a in _articles)
        if (a.id == id)
          a.copyWith(likes: liked ? a.likes + 1 : a.likes - 1)
        else
          a,
    ];
    notifyListeners();
  }

  Future<bool> toggleBookmark(String id) => _repo.toggleBookmark(id);

  // ── Comments ─────────────────────────────────────────────────────────────────
  Future<List<ArticleComment>> fetchComments(String id) =>
      _repo.fetchComments(id);

  Future<ArticleComment> addComment(String id, String text) =>
      _repo.addComment(id, text);
}
