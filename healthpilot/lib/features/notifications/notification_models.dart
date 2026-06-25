/// An in-app notification — `/notifications/`.
class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.notifType = '',
    this.data = const {},
    this.isRead = false,
    this.createdAt,
  });

  final int id;
  final String title;
  final String body;
  final String notifType;
  final Map<String, dynamic> data;
  final bool isRead;
  final DateTime? createdAt;

  AppNotification copyWith({bool? isRead}) => AppNotification(
        id: id,
        title: title,
        body: body,
        notifType: notifType,
        data: data,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );

  factory AppNotification.fromJson(Map<String, dynamic> json) =>
      AppNotification(
        id: (json['id'] as num?)?.toInt() ?? 0,
        title: json['title'] as String? ?? '',
        body: json['body'] as String? ?? '',
        notifType: json['notif_type'] as String? ?? '',
        data: (json['data'] as Map?)?.cast<String, dynamic>() ?? const {},
        isRead: json['is_read'] as bool? ?? false,
        createdAt: DateTime.tryParse(json['created_at'] as String? ?? ''),
      );
}
