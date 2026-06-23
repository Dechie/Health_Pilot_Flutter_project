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

  final Set<String> _bookmarks = {};
  final Map<String, List<ArticleComment>> _comments = {};
  int _nextCommentId = 1;

  @override
  Future<List<ArticleFeedItem>> fetchArticles() async => List.of(_articles);

  @override
  Future<List<ArticleFeedItem>> fetchRecommended() async =>
      _articles.take(2).toList();

  @override
  Future<List<ArticleFeedItem>> fetchBookmarks() async =>
      _articles.where((a) => _bookmarks.contains(a.id)).toList();

  @override
  Future<ArticleFeedItem> fetchArticle(String id) async =>
      _articles.firstWhere((a) => a.id == id);

  @override
  Future<bool> likeArticle(String id) async {
    final idx = _articles.indexWhere((a) => a.id == id);
    if (idx == -1) return false;
    _articles[idx] = _articles[idx].copyWith(likes: _articles[idx].likes + 1);
    return true;
  }

  @override
  Future<bool> toggleBookmark(String id) async {
    if (_bookmarks.contains(id)) {
      _bookmarks.remove(id);
      return false;
    }
    _bookmarks.add(id);
    return true;
  }

  @override
  Future<List<ArticleComment>> fetchComments(String id) async =>
      List.of(_comments[id] ?? const []);

  @override
  Future<ArticleComment> addComment(String id, String text) async {
    final comment = ArticleComment(
      id: _nextCommentId++,
      authorName: 'You',
      text: text,
      createdAt: DateTime(2026, 6, 21),
    );
    (_comments[id] ??= []).add(comment);
    return comment;
  }
}
