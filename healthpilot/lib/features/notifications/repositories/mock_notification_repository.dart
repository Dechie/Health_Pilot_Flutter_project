import 'package:healthpilot/core/repositories/i_notification_repository.dart';
import 'package:healthpilot/features/notifications/notification_models.dart';

class MockNotificationRepository implements INotificationRepository {
  final List<AppNotification> _items = [
    AppNotification(
      id: 1,
      title: 'Welcome to HealthPilot',
      body: 'Complete your profile to get personalised insights.',
      notifType: 'system',
      createdAt: DateTime(2026, 6, 20, 9),
    ),
    AppNotification(
      id: 2,
      title: 'New peer suggestion',
      body: 'We found someone with a similar health profile.',
      notifType: 'community',
      isRead: true,
      createdAt: DateTime(2026, 6, 19, 18),
    ),
  ];

  @override
  Future<List<AppNotification>> fetchNotifications() async => List.of(_items);

  @override
  Future<int> unreadCount() async => _items.where((n) => !n.isRead).length;

  @override
  Future<void> markRead({List<int>? ids}) async {
    for (var i = 0; i < _items.length; i++) {
      if (ids == null || ids.contains(_items[i].id)) {
        _items[i] = _items[i].copyWith(isRead: true);
      }
    }
  }

  @override
  Future<void> registerDevice(String token, {String? platform}) async {}
}
