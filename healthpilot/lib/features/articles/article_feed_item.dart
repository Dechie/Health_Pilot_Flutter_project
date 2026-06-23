import 'package:intl/intl.dart';

/// One article row for the feed + detail route.
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

  ArticleFeedItem copyWith({int? likes, int? commentsCount}) => ArticleFeedItem(
        id: id,
        title: title,
        body: body,
        imageUrl: imageUrl,
        author: author,
        publishedAt: publishedAt,
        readMinutes: readMinutes,
        likes: likes ?? this.likes,
        commentsCount: commentsCount ?? this.commentsCount,
      );

  /// Live API uses `{id:int, headline, summary|body, image_url,
  /// read_time_minutes}`; older shape used `{title, body, read_minutes}`.
  factory ArticleFeedItem.fromJson(Map<String, dynamic> json) =>
      ArticleFeedItem(
        id: json['id'].toString(),
        title: (json['title'] ?? json['headline'] ?? '') as String,
        body: (json['body'] ?? json['summary'] ?? '') as String? ?? '',
        imageUrl: json['image_url'] as String? ?? 'assets/images/old_woman.png',
        author: json['author'] as String? ?? '',
        publishedAt:
            DateTime.tryParse(json['published_at'] as String? ?? '') ??
                DateTime(1970),
        readMinutes: ((json['read_minutes'] ?? json['read_time_minutes'])
                    as num?)
                ?.toInt() ??
            0,
        likes: (json['likes'] as num?)?.toInt() ?? 0,
        commentsCount: (json['comments_count'] as num?)?.toInt() ?? 0,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'image_url': imageUrl,
        'author': author,
        'published_at': publishedAt.toIso8601String(),
        'read_minutes': readMinutes,
        'likes': likes,
        'comments_count': commentsCount,
      };

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

/// A comment on an article — `/articles/{id}/comments/`.
class ArticleComment {
  const ArticleComment({
    required this.id,
    required this.authorName,
    required this.text,
    this.createdAt,
    this.parentId,
  });

  final int id;
  final String authorName;
  final String text;
  final DateTime? createdAt;
  final int? parentId;

  factory ArticleComment.fromJson(Map<String, dynamic> json) => ArticleComment(
        id: (json['id'] as num?)?.toInt() ?? 0,
        authorName: json['author_name'] as String? ?? '',
        text: json['text'] as String? ?? '',
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
        parentId: (json['parent'] as num?)?.toInt(),
      );
}
