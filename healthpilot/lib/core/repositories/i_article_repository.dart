import 'package:healthpilot/features/articles/article_feed_item.dart';

abstract class IArticleRepository {
  Future<List<ArticleFeedItem>> fetchArticles();
  Future<ArticleFeedItem> likeArticle(String id);
}
