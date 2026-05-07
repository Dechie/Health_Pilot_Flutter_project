import 'package:healthpilot/core/repositories/i_article_repository.dart';
import 'package:healthpilot/features/articles/article_feed_item.dart';

class MockArticleRepository implements IArticleRepository {
  static final _seed = [
    ArticleFeedItem(
      id: '1',
      title: 'Why are we growing old?',
      body:
          'Lorem ipsum dolor sit amet consectetur. Donec ultrices enim purus at nisl morbi pretium elit. Sit aliquam tempus felis porttitor arcu. Placerat viverra feugiat tristique etiam volutpat. Mi faucibus in arcu integer ipsum. Iaculis cursus orci nunc laoreet sed et tortor mollis id. Dolor pulvinar turpis aenean facilisi dignissim. Proin mi nullam nibh adipiscing mauris facilisi aliquam urna adipiscing.',
      imageUrl: 'assets/images/old_woman.png',
      author: 'HealthPilot Team',
      publishedAt: DateTime(2022, 10, 23),
      readMinutes: 5,
      likes: 23,
      commentsCount: 12,
    ),
    ArticleFeedItem(
      id: '2',
      title: 'Why old',
      body:
          'Lorem ipsum dolor sit amet consectetur. Donec ultrices enim purus at nisl morbi pretium elit. Sit aliquam tempus felis porttitor arcu. Placerat viverra feugiat tristique etiam volutpat.',
      imageUrl: 'assets/images/old_woman.png',
      author: 'HealthPilot Team',
      publishedAt: DateTime(2023, 1, 8),
      readMinutes: 4,
      likes: 18,
      commentsCount: 6,
    ),
    ArticleFeedItem(
      id: '3',
      title: 'Why get old',
      body:
          'Lorem ipsum dolor sit amet consectetur. Donec ultrices enim purus at nisl morbi pretium elit. Sit aliquam tempus felis porttitor arcu. Placerat viverra feugiat tristique etiam volutpat. Mi faucibus in arcu integer ipsum.',
      imageUrl: 'assets/images/old_woman.png',
      author: 'Contributor',
      publishedAt: DateTime(2023, 3, 15),
      readMinutes: 7,
      likes: 41,
      commentsCount: 9,
    ),
  ];

  final List<ArticleFeedItem> _articles = List.of(_seed);

  @override
  Future<List<ArticleFeedItem>> fetchArticles() async => List.of(_articles);

  @override
  Future<ArticleFeedItem> likeArticle(String id) async {
    final idx = _articles.indexWhere((a) => a.id == id);
    if (idx == -1) throw StateError('Article $id not found');
    final updated = ArticleFeedItem(
      id: _articles[idx].id,
      title: _articles[idx].title,
      body: _articles[idx].body,
      imageUrl: _articles[idx].imageUrl,
      author: _articles[idx].author,
      publishedAt: _articles[idx].publishedAt,
      readMinutes: _articles[idx].readMinutes,
      likes: _articles[idx].likes + 1,
      commentsCount: _articles[idx].commentsCount,
    );
    _articles[idx] = updated;
    return updated;
  }
}
