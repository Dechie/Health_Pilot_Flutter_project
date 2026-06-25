/// A promotional ad — `GET /ads/`. The backend has no published schema yet
/// (the endpoint returns `data: null` when empty), so this is tolerant: known
/// fields are mapped and the full payload is kept in [raw] for forward-compat.
class AdItem {
  const AdItem({
    required this.id,
    required this.title,
    this.body,
    this.imageUrl,
    this.targetUrl,
    this.raw = const {},
  });

  final int id;
  final String title;
  final String? body;
  final String? imageUrl;
  final String? targetUrl;
  final Map<String, dynamic> raw;

  factory AdItem.fromJson(Map<String, dynamic> json) => AdItem(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: (json['title'] ?? json['headline'] ?? json['name'] ?? '')
            as String,
        body: (json['body'] ?? json['description'] ?? json['text']) as String?,
        imageUrl: (json['image_url'] ?? json['image'] ?? json['banner'])
            as String?,
        targetUrl:
            (json['target_url'] ?? json['url'] ?? json['link']) as String?,
        raw: json,
      );
}
