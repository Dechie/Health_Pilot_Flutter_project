import 'package:healthpilot/core/network/api_client.dart';
import 'package:healthpilot/core/network/api_constants.dart';
import 'package:healthpilot/core/repositories/i_article_repository.dart';
import 'package:healthpilot/features/articles/article_feed_item.dart';

class RemoteArticleRepository implements IArticleRepository {
  final ApiClient _api;
  RemoteArticleRepository(this._api);

  @override
  Future<List<ArticleFeedItem>> fetchArticles() async {
    final response = await _api.get('${ApiConstants.articlesBase}/');
    return (response.data['data'] as List<dynamic>)
        .map((e) => ArticleFeedItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<ArticleFeedItem> likeArticle(String id) async {
    final response = await _api.post('${ApiConstants.articlesBase}/$id/like/');
    return ArticleFeedItem.fromJson(
        response.data['data'] as Map<String, dynamic>);
  }
}
