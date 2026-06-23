import 'package:healthpilot/core/network/api_client.dart';
import 'package:healthpilot/core/network/api_constants.dart';
import 'package:healthpilot/core/repositories/i_article_repository.dart';
import 'package:healthpilot/features/articles/article_feed_item.dart';

class RemoteArticleRepository implements IArticleRepository {
  final ApiClient _api;
  RemoteArticleRepository(this._api);

  /// Follows DRF `next` pages and returns the concatenated `results`. Tolerates
  /// a bare list, the `{results}` envelope, or an empty `{}`.
  Future<List<dynamic>> _fetchAllPages(String path) async {
    final all = <dynamic>[];
    Map<String, dynamic>? query;
    final seen = <String>{};
    while (true) {
      final data = await _api.get(path, queryParameters: query);
      if (data is List) {
        all.addAll(data);
        break;
      }
      if (data is! Map) break;
      final results = data['results'];
      if (results is List) all.addAll(results);
      final next = data['next'];
      if (next is! String || next.isEmpty) break;
      final nextQuery = Uri.parse(next).queryParameters;
      final key = nextQuery.toString();
      if (nextQuery.isEmpty || !seen.add(key)) break;
      query = Map<String, dynamic>.from(nextQuery);
    }
    return all;
  }

  List<ArticleFeedItem> _articles(List<dynamic> raw) => raw
      .map((e) => ArticleFeedItem.fromJson(e as Map<String, dynamic>))
      .toList();

  @override
  Future<List<ArticleFeedItem>> fetchArticles() async =>
      _articles(await _fetchAllPages('${ApiConstants.articlesBase}/'));

  @override
  Future<List<ArticleFeedItem>> fetchRecommended() async => _articles(
      await _fetchAllPages('${ApiConstants.articlesBase}/recommended/'));

  @override
  Future<List<ArticleFeedItem>> fetchBookmarks() async =>
      _articles(await _fetchAllPages('${ApiConstants.articlesBase}/bookmarks/'));

  @override
  Future<ArticleFeedItem> fetchArticle(String id) async {
    final data = await _api.get('${ApiConstants.articlesBase}/$id/');
    return ArticleFeedItem.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<bool> likeArticle(String id) async {
    final data = await _api.post('${ApiConstants.articlesBase}/$id/like/');
    return data is Map && data['liked'] == true;
  }

  @override
  Future<bool> toggleBookmark(String id) async {
    final data = await _api.post('${ApiConstants.articlesBase}/$id/bookmark/');
    return data is Map && (data['bookmarked'] == true || data['liked'] == true);
  }

  @override
  Future<List<ArticleComment>> fetchComments(String id) async {
    final raw =
        await _fetchAllPages('${ApiConstants.articlesBase}/$id/comments/');
    return raw
        .map((e) => ArticleComment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ArticleComment> addComment(String id, String text) async {
    final data = await _api.post(
      '${ApiConstants.articlesBase}/$id/comments/',
      data: {'text': text},
    );
    return ArticleComment.fromJson(data as Map<String, dynamic>);
  }
}
