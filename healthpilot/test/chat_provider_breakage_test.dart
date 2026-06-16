import 'package:flutter_test/flutter_test.dart';
import 'package:healthpilot/features/chat/chat_models.dart';
import 'package:healthpilot/features/chat/chat_provider.dart';
import 'package:healthpilot/features/chat/data/chat_local_store.dart';
import 'package:healthpilot/features/chat/repositories/mock_chat_repository.dart';
import 'package:healthpilot/features/community/community_models.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'helpers/chat_local_store_test_helper.dart';

void main() {
  late ChatLocalStore store;
  late MockChatRepository repo;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = await createTestChatLocalStore();
    repo = MockChatRepository();
  });

  group('ChatProvider.sendDirect crash vectors', () {
    test('non-existent targetUserId returns silently instead of crashing', () async {
      final p = ChatProvider(repo, localStore: store);
      // _users is empty — should not throw
      await p.sendDirect('non-existent', '123', 'hello');
      expect(p.users, isEmpty);
    });

    test('non-numeric targetUserId without chatId returns silently (int.tryParse)', () async {
      final p = ChatProvider(repo, localStore: store);
      await p.load();
      // User 'abc' doesn't exist, but even if it did, int.tryParse would fail silently
      await p.sendDirect('abc', '123', 'hello');
    });

    test('empty content does not crash', () async {
      final p = ChatProvider(repo, localStore: store);
      await p.load();
      await p.sendDirect('1', '123', '');
      final user = p.findUser('1');
      expect(user!.chatHistory, hasLength(6)); // 5 seed + 1 empty
    });

    test('whitespace-only content is accepted (not validated)', () async {
      final p = ChatProvider(repo, localStore: store);
      await p.load();
      await p.sendDirect('1', '123', '   ');
      final user = p.findUser('1');
      expect(user!.chatHistory.last.content, '   ');
    });

    test('very long content (100k chars) does not crash', () async {
      final p = ChatProvider(repo, localStore: store);
      await p.load();
      final long = 'x' * 100000;
      await p.sendDirect('1', '123', long);
      final user = p.findUser('1');
      expect(user!.chatHistory.last.content, long);
    });

    test('unicode, emoji, and special characters survive round-trip', () async {
      final p = ChatProvider(repo, localStore: store);
      await p.load();
      await p.sendDirect('1', '123', 'Hello 🌍 Café ñöü 100% \$100 \n\t\r');
      final user = p.findUser('1');
      expect(user!.chatHistory.last.content,
          'Hello 🌍 Café ñöü 100% \$100 \n\t\r');
    });

    test('self-message (currentUserId == targetUserId) proceeds without crash', () async {
      final p = ChatProvider(repo, localStore: store);
      await p.load();
      // user '123' does not exist as a target — but sendDirect handles -1 index
      await p.sendDirect('123', '123', 'Hello self');
    });

    test('sendDirect before load() — empty _users, silent no-op', () async {
      final p = ChatProvider(repo, localStore: store);
      // no load() call
      await p.sendDirect('1', '123', 'should be dropped');
      expect(p.users, isEmpty);
    });

    test('sendDirect with null/special content text', () async {
      final p = ChatProvider(repo, localStore: store);
      await p.load();
      await p.sendDirect('1', '123', 'null');
      await p.sendDirect('1', '123', 'undefined');
      await p.sendDirect('1', '123', '<script>alert("xss")</script>');
      await p.sendDirect('1', '123', '../../etc/passwd');
      final user = p.findUser('1');
      expect(user!.chatHistory, hasLength(9)); // 5 seed + 4
    });

    test('message with SQL injection content', () async {
      final p = ChatProvider(repo, localStore: store);
      await p.load();
      await p.sendDirect('1', '123', "'; DROP TABLE direct_messages; --");
      await p.sendDirect('1', '123', '\' OR 1=1 --');
      // Should still be able to load messages (table not dropped)
      await p.fetchPrivateMessages('1');
      final user = p.findUser('1');
      expect(user, isNotNull);
    });
  });

  group('ChatProvider.sendDirect race conditions', () {
    test('two rapid sends to same user do not lose messages', () async {
      final p = ChatProvider(repo, localStore: store);
      await p.load();

      await Future.wait([
        p.sendDirect('1', '123', 'message A'),
        p.sendDirect('1', '123', 'message B'),
      ]);

      final user = p.findUser('1');
      final contents = user!.chatHistory.map((m) => m.content).toList();
      expect(contents, contains('message A'));
      expect(contents, contains('message B'));
    });

    test('sendDirect then immediate fetch does not drop sent message', () async {
      final p = ChatProvider(repo, localStore: store);
      await p.load();

      // Fire send and fetch concurrently
      await Future.wait([
        p.sendDirect('1', '123', 'race condition message'),
        p.fetchPrivateMessages('1'),
      ]);

      final user = p.findUser('1');
      final contents = user!.chatHistory.map((m) => m.content).toList();
      expect(contents, contains('race condition message'));
    });

    test('two identical rapid sends — both delivered, no merge loss', () async {
      final p = ChatProvider(repo, localStore: store);
      await p.load();

      // sendDirect uses a single message object — two calls create two distinct messages
      await p.sendDirect('1', '123', 'same text');
      await p.sendDirect('1', '123', 'same text');

      final user = p.findUser('1');
      expect(user!.chatHistory, hasLength(7)); // 5 seed + 2
      final sameText = user.chatHistory
          .where((m) => m.content == 'same text')
          .toList();
      expect(sameText, hasLength(2));
    });

    test('add + fetch race — fetch completes after send inserts but before local store flush', () async {
      final p = ChatProvider(repo, localStore: store);
      await p.load();

      // Step 1: start a send but don't await it yet
      final sendFuture = p.sendDirect('1', '123', 'timing message');

      // Step 2: immediately fetch (might see or not see the new message)
      await p.fetchPrivateMessages('1');

      // Step 3: complete the send
      await sendFuture;

      final user = p.findUser('1');
      // The message should exist regardless of timing
      final timingMessages =
          user!.chatHistory.where((m) => m.content == 'timing message');
      expect(timingMessages, isNotEmpty);
    });

    test('fetchPrivateMessages during sendDirect async gap does not crash', () async {
      final p = ChatProvider(repo, localStore: store);
      await p.load();

      // Force sendDirect to yield at every await by using delayed repo
      final delayedRepo = _DelayedChatRepository();
      final p2 = ChatProvider(delayedRepo, localStore: store);
      await p2.load();

      // Fire sends that will be delayed
      final sends = [
        p2.sendDirect('1', '123', 'delayed A'),
        p2.sendDirect('2', '123', 'delayed B'),
      ];

      // Trigger fetches during the delay
      await Future.wait([
        p2.fetchPrivateMessages('1'),
        p2.fetchPrivateMessages('2'),
      ]);

      // Let the delayed sends complete
      await Future.wait(sends);

      // Further fetches after everything settled
      await p2.fetchPrivateMessages('1');
      await p2.fetchPrivateMessages('2');

      expect(p2.findUser('1')?.chatHistory.any((m) => m.content == 'delayed A'), isTrue);
      expect(p2.findUser('2')?.chatHistory.any((m) => m.content == 'delayed B'), isTrue);
    });
  });

  group('ChatProvider.fetchPrivateMessages crash vectors', () {
    test('non-existent targetUserId crashes with StateError', () async {
      final p = ChatProvider(repo, localStore: store);
      expect(
        () => p.fetchPrivateMessages('ghost-user'),
        throwsA(isA<StateError>()),
      );
    });

    test('existing user with null chatId returns silently', () async {
      final p = ChatProvider(repo, localStore: store);
      // Manually add a user with null chatId
      p.addConnection(999, 'Ghost', 'mock-chat-id');
      await p.fetchPrivateMessages('999');
      // chatId is 'mock-chat-id', not null, so it will try API call

      // Now test with truly null chatId — addConnection always sets chatId
      // This is a gap: addConnection always sets chatId to the passed value
    });

    test('fetch before load — empty _users throws StateError', () async {
      final p = ChatProvider(repo, localStore: store);
      expect(
        () => p.fetchPrivateMessages('1'),
        throwsA(isA<StateError>()),
      );
    });

    test('rapid fetches do not crash', () async {
      final p = ChatProvider(repo, localStore: store);
      await p.load();

      await Future.wait([
        p.fetchPrivateMessages('1'),
        p.fetchPrivateMessages('1'),
        p.fetchPrivateMessages('1'),
        p.fetchPrivateMessages('1'),
      ]);
    });

    test('creating a user with null chatId does not crash fetchPrivateMessages', () async {
      final repo = _NullChatIdRepo();
      final p = ChatProvider(repo, localStore: store);
      await p.load();

      // This should return silently since chatId is null
      await p.fetchPrivateMessages('1');
    });
  });

  group('ChatProvider.syncAcceptedConnections edge cases', () {
    test('empty connections list does nothing', () async {
      final p = ChatProvider(repo, localStore: store);
      await p.load();
      await p.syncAcceptedConnections([], '123');
      // Should not crash
    });

    test('currentUserId matching neither fromUserId nor toUserId', () async {
      final p = ChatProvider(repo, localStore: store);
      await p.load();
      final conns = [
        ConnectionRequest(
          id: 1,
          fromUserId: 10,
          fromUserFullName: 'Alice',
          toUserId: 20,
          toUserFullName: 'Bob',
          status: 'accepted',
          createdAt: DateTime.now(),
        ),
      ];
      // currentUserId '999' matches neither 10 nor 20
      // peerIdOf returns the OTHER user's id — only used for startPrivateChat
      await p.syncAcceptedConnections(conns, '999');
    });

    test('duplicate sync — does not add duplicates', () async {
      final p = ChatProvider(repo, localStore: store);
      await p.load();
      final conns = [
        ConnectionRequest(
          id: 1,
          fromUserId: 2,
          fromUserFullName: 'Sara M.',
          toUserId: 123,
          toUserFullName: 'Current User',
          status: 'accepted',
          createdAt: DateTime.now(),
        ),
      ];
      // User '2' is already in seed data
      await p.syncAcceptedConnections(conns, '123');
      expect(p.users.where((u) => u.userId == '2'), hasLength(1));
    });

    test('startPrivateChat throws — silently skipped', () async {
      final throwingRepo = _ThrowingChatRepo();
      final p = ChatProvider(throwingRepo, localStore: store);
      await p.load();
      final conns = [
        ConnectionRequest(
          id: 1,
          fromUserId: 55,
          fromUserFullName: 'New Friend',
          toUserId: 123,
          toUserFullName: 'Current User',
          status: 'accepted',
          createdAt: DateTime.now(),
        ),
      ];
      // Should not crash — startPrivateChat throws, caught by try/catch
      await p.syncAcceptedConnections(conns, '123');
    });
  });
}

/// Delays every API call by 50ms to trigger race conditions.
class _DelayedChatRepository extends MockChatRepository {
  @override
  Future<DirectMessage> sendDirectMessage(String chatId, String content) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return super.sendDirectMessage(chatId, content);
  }

  @override
  Future<PrivateChat> startPrivateChat(int userId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return super.startPrivateChat(userId);
  }

  @override
  Future<List<DirectMessage>> fetchPrivateMessages(String chatId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    return super.fetchPrivateMessages(chatId);
  }
}

/// A ChatUser with a null chatId via seed data.
class _NullChatIdRepo extends MockChatRepository {
  @override
  Future<List<ChatUser>> fetchUsers() async {
    return [
      ChatUser(
        userId: '1',
        displayName: 'Null Chat',
        profilePictureUrl: '',
        status: '',
        isOnline: false,
        bio: '',
        isPro: false,
        chatId: null,
        chatHistory: [],
      ),
    ];
  }
}

class _ThrowingChatRepo extends MockChatRepository {
  @override
  Future<PrivateChat> startPrivateChat(int userId) async {
    throw Exception('startPrivateChat failed');
  }
}
