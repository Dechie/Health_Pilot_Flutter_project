import 'package:healthpilot/features/notifications/notification_models.dart';

abstract class INotificationRepository {
  /// All notifications, newest first — `GET /notifications/`.
  Future<List<AppNotification>> fetchNotifications();

  /// Unread count — `GET /notifications/unread-count/`.
  Future<int> unreadCount();

  /// Mark notifications read — `POST /notifications/read/`.
  /// Pass `ids` to mark specific ones, or omit to mark all.
  Future<void> markRead({List<int>? ids});

  /// Register a push device token — `POST /notifications/device/register/`.
  Future<void> registerDevice(String token, {String? platform});
}
