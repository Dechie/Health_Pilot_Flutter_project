import 'package:healthpilot/core/network/api_client.dart';
import 'package:healthpilot/core/network/api_constants.dart';
import 'package:healthpilot/core/repositories/i_notification_repository.dart';
import 'package:healthpilot/features/notifications/notification_models.dart';

class RemoteNotificationRepository implements INotificationRepository {
  final ApiClient _api;
  RemoteNotificationRepository(this._api);

  Future<List<dynamic>> _fetchAllPages(String path) async {
    final all = <dynamic>[];
    Map<String, dynamic>? query;
    final seen = <String>{};
    while (true) {
      final data = await _api.get(path, queryParameters: query);
      if (data is List) {
        all.addAll(data);
        break;
      }
      if (data is! Map) break;
      final results = data['results'];
      if (results is List) all.addAll(results);
      final next = data['next'];
      if (next is! String || next.isEmpty) break;
      final nextQuery = Uri.parse(next).queryParameters;
      final key = nextQuery.toString();
      if (nextQuery.isEmpty || !seen.add(key)) break;
      query = Map<String, dynamic>.from(nextQuery);
    }
    return all;
  }

  @override
  Future<List<AppNotification>> fetchNotifications() async {
    final raw = await _fetchAllPages('${ApiConstants.notificationsBase}/');
    return raw
        .map((e) => AppNotification.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<int> unreadCount() async {
    final data =
        await _api.get('${ApiConstants.notificationsBase}/unread-count/');
    if (data is Map) return (data['unread_count'] as num?)?.toInt() ?? 0;
    return 0;
  }

  @override
  Future<void> markRead({List<int>? ids}) async {
    await _api.post(
      '${ApiConstants.notificationsBase}/read/',
      data: ids == null ? <String, dynamic>{} : {'notification_ids': ids},
    );
  }

  @override
  Future<void> registerDevice(String token, {String? platform}) async {
    await _api.post(
      '${ApiConstants.notificationsBase}/device/register/',
      data: {'token': token, if (platform != null) 'platform': platform},
    );
  }
}
