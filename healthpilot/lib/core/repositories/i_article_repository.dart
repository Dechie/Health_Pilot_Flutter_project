import 'package:healthpilot/features/articles/article_feed_item.dart';

abstract class IArticleRepository {
  Future<List<ArticleFeedItem>> fetchArticles();

  /// Personalised feed — `GET /articles/recommended/`.
  Future<List<ArticleFeedItem>> fetchRecommended();

  /// The user's bookmarked articles — `GET /articles/bookmarks/`.
  Future<List<ArticleFeedItem>> fetchBookmarks();

  /// A single article with full body — `GET /articles/{id}/`.
  Future<ArticleFeedItem> fetchArticle(String id);

  /// Toggle like — `POST /articles/{id}/like/`; returns the new liked state.
  Future<bool> likeArticle(String id);

  /// Toggle bookmark — `POST /articles/{id}/bookmark/`; returns bookmarked state.
  Future<bool> toggleBookmark(String id);

  /// Comments for an article — `GET /articles/{id}/comments/`.
  Future<List<ArticleComment>> fetchComments(String id);

  /// Post a comment — `POST /articles/{id}/comments/` with `{text}`.
  Future<ArticleComment> addComment(String id, String text);
}
