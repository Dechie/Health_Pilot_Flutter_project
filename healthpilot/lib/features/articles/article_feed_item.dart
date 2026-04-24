import 'package:intl/intl.dart';

/// One article row for the feed + detail route (local seed until API exists).
class ArticleFeedItem {
  const ArticleFeedItem({
    required this.id,
    required this.title,
    required this.body,
    required this.imageUrl,
    required this.author,
    required this.publishedAt,
    required this.readMinutes,
    required this.likes,
    required this.commentsCount,
  });

  final String id;
  final String title;
  final String body;
  final String imageUrl;
  final String author;
  final DateTime publishedAt;
  final int readMinutes;
  final int likes;
  final int commentsCount;

  String get formattedPublishedDate =>
      DateFormat.yMMMMd('en_US').format(publishedAt);

  /// Legacy route used `List<Map>` with `title` / `detail` keys.
  factory ArticleFeedItem.fromLegacyArguments(List<Map<String, dynamic>> raw) {
    final title = (raw.isNotEmpty ? raw[0]['title'] : null) as String? ?? '';
    final body = (raw.length > 1 ? raw[1]['detail'] : null) as String? ?? '';
    return ArticleFeedItem(
      id: 'legacy-${title.hashCode}',
      title: title,
      body: body,
      imageUrl: 'assets/images/old_woman.png',
      author: 'HealthPilot Team',
      publishedAt: DateTime(2022, 10, 23),
      readMinutes: 5,
      likes: 23,
      commentsCount: 12,
    );
  }
}
