import 'package:flutter/material.dart';
import 'package:healthpilot/features/notifications/notification_provider.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<NotificationProvider>().load();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final c = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          Consumer<NotificationProvider>(
            builder: (context, notif, _) {
              if (notif.items.isEmpty) return const SizedBox.shrink();
              return TextButton(
                onPressed: notif.markAllRead,
                child: const Text('Mark all read'),
              );
            },
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, notif, _) {
          if (notif.status == NotificationLoadStatus.loading &&
              notif.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (notif.items.isEmpty) {
            return Center(
              child: Text(
                'No notifications yet.',
                style: t.bodyLarge?.copyWith(color: c.onSurfaceVariant),
              ),
            );
          }
          return ListView.separated(
            itemCount: notif.items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = notif.items[index];
              return ListTile(
                leading: Icon(
                  item.isRead ? Icons.notifications_none : Icons.notifications,
                  color: item.isRead ? c.onSurfaceVariant : c.primary,
                ),
                title: Text(
                  item.title,
                  style: t.bodyMedium?.copyWith(
                    fontWeight: item.isRead ? FontWeight.w400 : FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  item.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: t.bodySmall,
                ),
                trailing: item.createdAt != null
                    ? Text(
                        _formatDate(item.createdAt!),
                        style: t.labelSmall?.copyWith(color: c.onSurfaceVariant),
                      )
                    : null,
                onTap: () => notif.markRead(item.id),
              );
            },
          );
        },
      ),
    );
  }

  static String _formatDate(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);
    if (diff.inDays > 365) return '${diff.inDays ~/ 365}y';
    if (diff.inDays > 30) return '${diff.inDays ~/ 30}mo';
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    return '${diff.inMinutes}m';
  }
}
