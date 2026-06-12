import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite database for on-device chat history (AI, direct, and group).
class ChatDatabase {
  ChatDatabase._(this._database);

  Database? _database;

  static final ChatDatabase instance = ChatDatabase._(null);

  Future<Database> get database async {
    if (_database != null) return _database!;
    final dir = await getApplicationDocumentsDirectory();
    final path = join(dir.path, 'healthpilot_chat.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: onCreate,
    );
    return _database!;
  }

  /// In-memory database for widget/unit tests.
  static Future<ChatDatabase> openInMemory() async {
    final db = await openDatabase(
      inMemoryDatabasePath,
      version: 1,
      onCreate: onCreate,
    );
    return ChatDatabase._(db);
  }

  static Future<void> onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE ai_messages (
        id TEXT PRIMARY KEY,
        from_user INTEGER NOT NULL,
        body TEXT NOT NULL,
        sent_at TEXT NOT NULL,
        delivery_status TEXT NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE direct_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        thread_id TEXT NOT NULL,
        sender_id TEXT NOT NULL,
        content TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        is_delivered INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_direct_thread ON direct_messages(thread_id, timestamp)',
    );
    await db.execute('''
      CREATE TABLE group_messages (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        thread_id TEXT NOT NULL,
        sender_id TEXT NOT NULL,
        content TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        is_delivered INTEGER NOT NULL DEFAULT 1
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_group_thread ON group_messages(thread_id, timestamp)',
    );
  }

  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
