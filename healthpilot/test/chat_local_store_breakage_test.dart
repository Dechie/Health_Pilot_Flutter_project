import 'package:flutter_test/flutter_test.dart';
import 'package:healthpilot/features/chat/chat_models.dart';
import 'package:healthpilot/features/chat/data/chat_local_store.dart';
import 'helpers/chat_local_store_test_helper.dart';

int _tid = 0;

/// Returns a unique thread ID per call (avoid shared in-memory SQLite).
String _nextTid() => 't${_tid++}';

void main() {
  late ChatLocalStore store;

  setUp(() async {
    store = await createTestChatLocalStore();
  });

  group('ChatLocalStore.loadDirectMessages dedup edge cases', () {
    test('empty API + empty local returns empty', () async {
      final result = await store.loadDirectMessages(_nextTid(), []);
      expect(result, isEmpty);
    });

    test('API messages with sub-second timestamp differences are NOT deduped', () async {
      final tid = _nextTid();
      // Insert client version with microsecond precision
      await store.insertDirectMessage(
        tid,
        DirectMessage(
          senderId: '123',
          content: 'hello',
          timestamp: DateTime(2026, 6, 15, 12, 0, 0, 0, 123),
          isDelivered: false,
        ),
      );

      // API returns same content but with a different (truncated) timestamp
      final apiVariant = DirectMessage(
        senderId: '123',
        content: 'hello',
        timestamp: DateTime(2026, 6, 15, 12, 0, 0, 0, 0),
      );

      final result =
          await store.loadDirectMessages(tid, [apiVariant]);

      // Dedup key differs: "2026-06-15 12:00:00.000123:123:hello"
      //                     "2026-06-15 12:00:00.000000:123:hello"
      expect(result, hasLength(2));
    });

    test('same message from API dedup works when timestamps match', () async {
      final tid = _nextTid();
      final msg = DirectMessage(
        senderId: '123',
        content: 'hello',
        timestamp: DateTime(2026, 6, 15, 12),
      );

      await store.insertDirectMessage(tid, msg);
      final result = await store.loadDirectMessages(tid, [msg]);

      expect(result, hasLength(1));
    });

    test('same timestamp, different sender — not deduped', () async {
      final tid = _nextTid();
      final ts = DateTime(2026, 6, 15, 12);
      await store.insertDirectMessage(
        tid,
        DirectMessage(senderId: '123', content: 'hello', timestamp: ts),
      );

      final result = await store.loadDirectMessages(tid, [
        DirectMessage(senderId: '456', content: 'hello', timestamp: ts),
      ]);

      expect(result, hasLength(2));
    });

    test('same timestamp+sender, different content — not deduped', () async {
      final tid = _nextTid();
      final ts = DateTime(2026, 6, 15, 12);
      await store.insertDirectMessage(
        tid,
        DirectMessage(senderId: '123', content: 'first', timestamp: ts),
      );

      final result = await store.loadDirectMessages(tid, [
        DirectMessage(senderId: '123', content: 'second', timestamp: ts),
      ]);

      expect(result, hasLength(2));
    });

    test('insertDirectMessage + loadDirectMessages with same message creates duplicate', () async {
      final tid = _nextTid();
      final msg = DirectMessage(
        senderId: '123',
        content: 'hello',
        timestamp: DateTime(2026, 6, 15, 12),
      );

      // loadDirectMessages inserts msg from API into local store
      await store.loadDirectMessages(tid, [msg]);
      // sendDirect separately inserts the same-looking msg into local store
      await store.insertDirectMessage(tid, msg);

      final loaded = await store.fetchDirectMessages(tid);
      // There is no UNIQUE constraint in SQLite — duplicate row is allowed!
      expect(loaded, hasLength(2));
    });

    test('multiple consecutive loadDirectMessages with same API messages', () async {
      final tid = _nextTid();
      final msg = DirectMessage(
        senderId: '123',
        content: 'hello',
        timestamp: DateTime(2026, 6, 15, 12),
      );

      final first = await store.loadDirectMessages(tid, [msg]);
      expect(first, hasLength(1));

      final second = await store.loadDirectMessages(tid, [msg]);
      expect(second, hasLength(1));

      final third = await store.loadDirectMessages(tid, [msg]);
      expect(third, hasLength(1));
    });
  });

  group('ChatLocalStore markDelivered edge cases', () {
    test('markDelivered for non-existent message is a no-op', () async {
      await store.markDirectMessageDelivered(
          _nextTid(), DateTime(2020, 1, 1));
    });

    test('markDelivered twice is idempotent', () async {
      final tid = _nextTid();
      final ts = DateTime(2026, 6, 15, 12);
      await store.insertDirectMessage(
        tid,
        DirectMessage(
          senderId: '123',
          content: 'hello',
          timestamp: ts,
          isDelivered: false,
        ),
      );

      await store.markDirectMessageDelivered(tid, ts);
      await store.markDirectMessageDelivered(tid, ts);

      final loaded = await store.fetchDirectMessages(tid);
      expect(loaded.single.isDelivered, isTrue);
    });
  });

  group('ChatLocalStore cross-thread isolation', () {
    test('messages in different threads do not interfere', () async {
      final tA = _nextTid();
      final tB = _nextTid();
      await store.insertDirectMessage(
        tA,
        DirectMessage(
          senderId: '123',
          content: 'msg for A',
          timestamp: DateTime(2026, 6, 15, 12),
        ),
      );
      await store.insertDirectMessage(
        tB,
        DirectMessage(
          senderId: '123',
          content: 'msg for B',
          timestamp: DateTime(2026, 6, 15, 13),
        ),
      );

      final a = await store.fetchDirectMessages(tA);
      final b = await store.fetchDirectMessages(tB);

      expect(a, hasLength(1));
      expect(a.first.content, 'msg for A');
      expect(b, hasLength(1));
      expect(b.first.content, 'msg for B');
    });

    test('markDelivered only affects the target thread', () async {
      final tA = _nextTid();
      final tB = _nextTid();
      final ts = DateTime(2026, 6, 15, 12);
      await store.insertDirectMessage(
        tA,
        DirectMessage(
          senderId: '123',
          content: 'not delivered',
          timestamp: ts,
          isDelivered: false,
        ),
      );
      await store.insertDirectMessage(
        tB,
        DirectMessage(
          senderId: '123',
          content: 'not delivered either',
          timestamp: ts,
          isDelivered: false,
        ),
      );

      await store.markDirectMessageDelivered(tA, ts);

      final a = await store.fetchDirectMessages(tA);
      final b = await store.fetchDirectMessages(tB);
      expect(a.single.isDelivered, isTrue);
      expect(b.single.isDelivered, isFalse);
    });
  });

  group('ChatLocalStore edge content types', () {
    test('empty content string is accepted', () async {
      final tid = _nextTid();
      await store.insertDirectMessage(
        tid,
        DirectMessage(
          senderId: '123',
          content: '',
          timestamp: DateTime(2026, 6, 15, 12),
        ),
      );

      final loaded = await store.fetchDirectMessages(tid);
      expect(loaded.single.content, '');
    });

    test('very long content (100k) is stored and retrieved', () async {
      final tid = _nextTid();
      final longContent = 'x' * 100000;
      await store.insertDirectMessage(
        tid,
        DirectMessage(
          senderId: '123',
          content: longContent,
          timestamp: DateTime(2026, 6, 15, 12),
        ),
      );

      final loaded = await store.fetchDirectMessages(tid);
      expect(loaded.single.content, longContent);
    });

    test('SQL injection content is stored safely', () async {
      final tid = _nextTid();
      await store.insertDirectMessage(
        tid,
        DirectMessage(
          senderId: '123',
          content: "'; DROP TABLE direct_messages; --",
          timestamp: DateTime(2026, 6, 15, 12),
        ),
      );
      await store.insertDirectMessage(
        tid,
        DirectMessage(
          senderId: '456',
          content: '\' OR 1=1 --',
          timestamp: DateTime(2026, 6, 15, 13),
        ),
      );

      final loaded = await store.fetchDirectMessages(tid);
      expect(loaded, hasLength(2));
    });
  });

  group('ChatLocalStore loadGroupMessages edge cases', () {
    test('empty API + empty local returns empty', () async {
      final result = await store.loadGroupMessages(_nextTid(), []);
      expect(result, isEmpty);
    });

    test('loadGroupMessages with same message from API and local dedup works', () async {
      final tid = _nextTid();
      final msg = DirectMessage(
        senderId: '123',
        content: 'group hello',
        timestamp: DateTime(2026, 6, 15, 12),
      );

      await store.insertGroupMessage(tid, msg);
      final result = await store.loadGroupMessages(tid, [msg]);
      expect(result, hasLength(1));
    });

    test('loadGroupMessages with different timestamps bypass dedup', () async {
      final tid = _nextTid();
      final ts1 = DateTime(2026, 6, 15, 12, 0, 0, 0, 123);
      final ts2 = DateTime(2026, 6, 15, 12, 0, 0, 0, 456);

      await store.insertGroupMessage(tid,
          DirectMessage(senderId: '123', content: 'hello', timestamp: ts1));

      final result = await store.loadGroupMessages(tid, [
        DirectMessage(senderId: '123', content: 'hello', timestamp: ts2),
      ]);

      expect(result, hasLength(2));
    });
  });

  group('ChatLocalStore reentrancy / concurrent access', () {
    test('concurrent inserts to same thread do not lose data', () async {
      final tid = _nextTid();
      final ts = DateTime(2026, 6, 15, 12);

      await Future.wait([
        store.insertDirectMessage(
          tid,
          DirectMessage(senderId: '1', content: 'A', timestamp: ts.add(const Duration(seconds: 1))),
        ),
        store.insertDirectMessage(
          tid,
          DirectMessage(senderId: '2', content: 'B', timestamp: ts.add(const Duration(seconds: 2))),
        ),
        store.insertDirectMessage(
          tid,
          DirectMessage(senderId: '3', content: 'C', timestamp: ts.add(const Duration(seconds: 3))),
        ),
        store.insertDirectMessage(
          tid,
          DirectMessage(senderId: '4', content: 'D', timestamp: ts.add(const Duration(seconds: 4))),
        ),
      ]);

      final loaded = await store.fetchDirectMessages(tid);
      expect(loaded, hasLength(4));
    });

    test('loadDirectMessages race with concurrent insert — eventual consistency', () async {
      final tid = _nextTid();
      final ts = DateTime(2026, 6, 15, 12);

      // Start a load while a concurrent insert is in flight
      final loadFuture = store.loadDirectMessages(tid, []);

      await store.insertDirectMessage(
        tid,
        DirectMessage(senderId: '123', content: 'concurrent', timestamp: ts),
      );

      // load may or may not see the concurrent insert
      await loadFuture;

      // After the dust settles, the message must be retrievable
      final finalLoad = await store.loadDirectMessages(tid, []);
      expect(finalLoad.any((m) => m.content == 'concurrent'), isTrue);
    });
  });
}
