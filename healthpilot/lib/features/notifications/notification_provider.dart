import 'package:flutter/foundation.dart';
import 'package:healthpilot/core/repositories/i_notification_repository.dart';
import 'package:healthpilot/features/notifications/notification_models.dart';

enum NotificationLoadStatus { idle, loading, loaded, error }

class NotificationProvider extends ChangeNotifier {
  final INotificationRepository _repo;

  List<AppNotification> _items = [];
  int _unreadCount = 0;
  NotificationLoadStatus _status = NotificationLoadStatus.idle;
  bool _loadStarted = false;

  List<AppNotification> get items => List.unmodifiable(_items);
  int get unreadCount => _unreadCount;
  NotificationLoadStatus get status => _status;

  NotificationProvider(this._repo);

  Future<void> load() async {
    if (_loadStarted) return;
    _loadStarted = true;
    await refresh();
  }

  Future<void> refresh() async {
    _status = NotificationLoadStatus.loading;
    notifyListeners();
    try {
      _items = await _repo.fetchNotifications();
      _unreadCount = await _repo.unreadCount();
      _status = NotificationLoadStatus.loaded;
    } catch (_) {
      _status = NotificationLoadStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> markAllRead() async {
    await _repo.markRead();
    _items = [for (final n in _items) n.copyWith(isRead: true)];
    _unreadCount = 0;
    notifyListeners();
  }

  Future<void> markRead(int id) async {
    await _repo.markRead(ids: [id]);
    _items = [
      for (final n in _items) if (n.id == id) n.copyWith(isRead: true) else n,
    ];
    _unreadCount = _items.where((n) => !n.isRead).length;
    notifyListeners();
  }

  Future<void> registerDevice(String token, {String? platform}) =>
      _repo.registerDevice(token, platform: platform);
}
