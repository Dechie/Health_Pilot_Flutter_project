import 'package:healthpilot/core/database/chat_database.dart';
import 'package:healthpilot/features/chat/chat_models.dart';
import 'package:healthpilot/features/chatbot/chatbot_models.dart';
import 'package:sqflite/sqflite.dart';

/// Persists chat message history locally until backend sync is available.
class ChatLocalStore {
  ChatLocalStore(this._database);

  final ChatDatabase _database;

  static ChatLocalStore? _instance;
  static ChatLocalStore get instance =>
      _instance ??= ChatLocalStore(ChatDatabase.instance);

  // ── AI assistant ──────────────────────────────────────────────────────────

  Future<List<ChatMessage>> fetchAiMessages() async {
    final db = await _database.database;
    final rows = await db.query(
      'ai_messages',
      orderBy: 'sent_at ASC',
    );
    return rows.map(_aiMessageFromRow).toList();
  }

  Future<void> insertAiMessage(ChatMessage message) async {
    final db = await _database.database;
    await db.insert(
      'ai_messages',
      _aiMessageToRow(message),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> clearAiMessages() async {
    final db = await _database.database;
    await db.delete('ai_messages');
  }

  // ── Direct chat ───────────────────────────────────────────────────────────

  Future<List<DirectMessage>> fetchDirectMessages(String threadId) async {
    final db = await _database.database;
    final rows = await db.query(
      'direct_messages',
      where: 'thread_id = ?',
      whereArgs: [threadId],
      orderBy: 'timestamp ASC',
    );
    return rows.map(_directMessageFromRow).toList();
  }

  /// Loads SQLite history and merges in [apiMessages] that aren't already stored.
  Future<List<DirectMessage>> loadDirectMessages(
    String threadId,
    List<DirectMessage> apiMessages,
  ) async {
    final local = await fetchDirectMessages(threadId);
    if (apiMessages.isEmpty && local.isNotEmpty) return local;
    // Deduplicate by (timestamp, senderId, content)
    final seen = local
        .map((m) => '${m.timestamp}:${m.senderId}:${m.content}')
        .toSet();
    final merged = [
      ...local,
      for (final m in apiMessages)
        if (!seen.contains('${m.timestamp}:${m.senderId}:${m.content}')) m,
    ];
    for (final m in merged) {
      if (!seen.contains('${m.timestamp}:${m.senderId}:${m.content}')) {
        await insertDirectMessage(threadId, m);
      }
    }
    return merged;
  }

  Future<void> insertDirectMessage(
    String threadId,
    DirectMessage message,
  ) async {
    final db = await _database.database;
    await db.insert('direct_messages', {
      'thread_id': threadId,
      'sender_id': message.senderId,
      'content': message.content,
      'timestamp': message.timestamp.toIso8601String(),
      'is_delivered': message.isDelivered ? 1 : 0,
    });
  }

  Future<void> markDirectMessageDelivered(
    String threadId,
    DateTime timestamp,
  ) async {
    final db = await _database.database;
    await db.update(
      'direct_messages',
      {'is_delivered': 1},
      where: 'thread_id = ? AND timestamp = ? AND is_delivered = 0',
      whereArgs: [threadId, timestamp.toIso8601String()],
    );
  }

  // ── Group chat ──────────────────────────────────────────────────────────────

  Future<List<DirectMessage>> fetchGroupMessages(String threadId) async {
    final db = await _database.database;
    final rows = await db.query(
      'group_messages',
      where: 'thread_id = ?',
      whereArgs: [threadId],
      orderBy: 'timestamp ASC',
    );
    return rows.map(_directMessageFromRow).toList();
  }

  Future<List<DirectMessage>> loadGroupMessages(
    String threadId,
    List<DirectMessage> apiMessages,
  ) async {
    final local = await fetchGroupMessages(threadId);
    if (apiMessages.isEmpty && local.isNotEmpty) return local;
    final seen = local
        .map((m) => '${m.timestamp}:${m.senderId}:${m.content}')
        .toSet();
    final merged = [
      ...local,
      for (final m in apiMessages)
        if (!seen.contains('${m.timestamp}:${m.senderId}:${m.content}')) m,
    ];
    for (final m in merged) {
      if (!seen.contains('${m.timestamp}:${m.senderId}:${m.content}')) {
        await insertGroupMessage(threadId, m);
      }
    }
    return merged;
  }

  Future<void> insertGroupMessage(
      String threadId, DirectMessage message) async {
    final db = await _database.database;
    await db.insert('group_messages', {
      'thread_id': threadId,
      'sender_id': message.senderId,
      'content': message.content,
      'timestamp': message.timestamp.toIso8601String(),
      'is_delivered': message.isDelivered ? 1 : 0,
    });
  }

  Future<void> markGroupMessageDelivered(
    String threadId,
    DateTime timestamp,
  ) async {
    final db = await _database.database;
    await db.update(
      'group_messages',
      {'is_delivered': 1},
      where: 'thread_id = ? AND timestamp = ? AND is_delivered = 0',
      whereArgs: [threadId, timestamp.toIso8601String()],
    );
  }

  // ── Row mapping ─────────────────────────────────────────────────────────────

  Map<String, Object?> _aiMessageToRow(ChatMessage message) => {
        'id': message.id,
        'from_user': message.fromUser ? 1 : 0,
        'body': message.body,
        'sent_at': message.sentAt.toIso8601String(),
        'delivery_status': message.deliveryStatus.name,
      };

  ChatMessage _aiMessageFromRow(Map<String, Object?> row) => ChatMessage(
        id: row['id']! as String,
        fromUser: (row['from_user']! as int) == 1,
        body: row['body']! as String,
        sentAt: DateTime.parse(row['sent_at']! as String),
        deliveryStatus: OutgoingDeliveryStatus.values.byName(
          row['delivery_status']! as String,
        ),
      );

  DirectMessage _directMessageFromRow(Map<String, Object?> row) =>
      DirectMessage(
        senderId: row['sender_id']! as String,
        content: row['content']! as String,
        timestamp: DateTime.parse(row['timestamp']! as String),
        isDelivered: (row['is_delivered']! as int) == 1,
      );
}
