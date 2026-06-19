import 'package:flutter_test/flutter_test.dart';
import 'package:healthpilot/features/chat/chat_models.dart';
import 'package:healthpilot/features/chat/chat_provider.dart';
import 'package:healthpilot/features/chat/repositories/mock_chat_repository.dart';

import 'helpers/chat_local_store_test_helper.dart';

void main() {
  group('Chat API flow — private chat', () {
    test('fetchUsers returns connected peers', () async {
      final repo = MockChatRepository();
      final users = await repo.fetchUsers();
      expect(users, isNotEmpty);
      expect(users.first.userId, isNotNull);
    });

    test('startPrivateChat returns a chat with UUID-like id', () async {
      final repo = MockChatRepository();
      final chat = await repo.startPrivateChat(1);
      expect(chat.id, isNotEmpty);
      expect(chat.participants, isNotEmpty);
    });

    test('sendDirectMessage returns a DirectMessage with content', () async {
      final repo = MockChatRepository();
      final msg = await repo.sendDirectMessage('chat-uuid', 'Hello!');
      expect(msg.content, 'Hello!');
      expect(msg.senderId, '123');
    });

    test('listPrivateChats returns a list', () async {
      final repo = MockChatRepository();
      final chats = await repo.listPrivateChats();
      expect(chats, isEmpty);
    });
  });

  group('Chat API flow — group chat', () {
    test('fetchGroups returns seeded groups', () async {
      final repo = MockChatRepository();
      final groups = await repo.fetchGroups();
      expect(groups, isNotEmpty);
    });

    test('createGroup returns group with name and description', () async {
      final repo = MockChatRepository();
      final group = await repo.createGroup('Diabetes Support', 'Support group');
      expect(group.groupName, 'Diabetes Support');
      expect(group.description, 'Support group');
      expect(group.groupId, startsWith('mock-group-'));
    });

    test('joinGroup does not throw', () async {
      final repo = MockChatRepository();
      await repo.joinGroup('g1');
    });

    test('leaveGroup does not throw', () async {
      final repo = MockChatRepository();
      await repo.leaveGroup('g1');
    });

    test('sendGroupMessage sends content only', () async {
      final repo = MockChatRepository();
      final msg = await repo.sendGroupMessage('g1', 'Hi everyone!');
      expect(msg.content, 'Hi everyone!');
    });

    test('fetchGroupMessages returns list', () async {
      final repo = MockChatRepository();
      final msgs = await repo.fetchGroupMessages('g1');
      expect(msgs, isEmpty);
    });
  });

  group('ChatProvider UI flow', () {
    test('createGroup adds group to provider state', () async {
      final provider = await createTestChatProvider();
      await provider.createGroup('Diabetes Support', 'Support group');
      final group = provider.findGroup(
        provider.groups.firstWhere((g) => g.groupName == 'Diabetes Support').groupId,
      );
      expect(group, isNotNull);
      expect(group!.groupName, 'Diabetes Support');
      expect(group.description, 'Support group');
    });

    test('joinGroup refreshes groups list', () async {
      final provider = await createTestChatProvider();
      final before = provider.groups.length;
      await provider.joinGroup('g1');
      expect(provider.groups.length, greaterThanOrEqualTo(before));
    });

    test('leaveGroup marks group as unjoined in provider state', () async {
      final provider = await createTestChatProvider();
      final before = provider.groups.length;
      await provider.leaveGroup('g1');
      expect(provider.groups.length, before);
      final group = provider.findGroup('g1');
      expect(group, isNotNull);
      expect(group!.isJoined, isFalse);
    });

    test('sendGroup sends message and marks delivered', () async {
      final provider = await createTestChatProvider();
      await provider.sendGroup('g1', '999', 'Hello group');
      final group = provider.findGroup('g1')!;
      expect(
        group.groupChatHistory.any((m) => m.content == 'Hello group'),
        isTrue,
      );
      final sent = group.groupChatHistory.firstWhere(
        (m) => m.content == 'Hello group',
      );
      expect(sent.isDelivered, isTrue);
    });

    test('fetchGroupMessages loads messages into group history', () async {
      final provider = await createTestChatProvider();
      await provider.fetchGroupMessages('g1');
      final group = provider.findGroup('g1')!;
      expect(group.groupChatHistory, isNotNull);
    });

    test('leaveGroup then createGroup works correctly', () async {
      final provider = await createTestChatProvider();
      await provider.leaveGroup('g1');
      final left = provider.findGroup('g1');
      expect(left, isNotNull);
      expect(left!.isJoined, isFalse);

      await provider.createGroup('New Group', 'A new group');
      expect(
        provider.groups.any((g) => g.groupName == 'New Group'),
        isTrue,
      );
    });
  });

  group('DirectMessage model', () {
    test('fromJson handles sender_id as int', () {
      final msg = DirectMessage.fromJson({
        'id': 'msg-1',
        'sender_id': 5,
        'content': 'Hello',
        'timestamp': '2026-06-18T12:00:00Z',
      });
      expect(msg.id, 'msg-1');
      expect(msg.senderId, '5');
      expect(msg.content, 'Hello');
    });

    test('fromJson handles sender_id as String', () {
      final msg = DirectMessage.fromJson({
        'id': 'msg-2',
        'sender_id': '5',
        'content': 'Hi',
        'timestamp': '2026-06-18T12:00:00Z',
      });
      expect(msg.senderId, '5');
    });

    test('fromJson handles missing id', () {
      final msg = DirectMessage.fromJson({
        'sender_id': '5',
        'content': 'Hi',
        'timestamp': '2026-06-18T12:00:00Z',
      });
      expect(msg.id, isNull);
    });

    test('copyWith preserves id when not overwritten', () {
      final msg = DirectMessage(
        id: 'msg-1',
        senderId: '5',
        content: 'Hello',
        timestamp: DateTime(2026, 6, 18),
      );
      final updated = msg.copyWith(content: 'Updated');
      expect(updated.id, 'msg-1');
      expect(updated.content, 'Updated');
    });
  });

  group('ChatGroup model', () {
    test('fromJson handles API response keys (id/name)', () {
      final group = ChatGroup.fromJson({
        'id': 'uuid-123',
        'name': 'Diabetes Support',
        'description': 'Support group',
        'members_count': 3,
      });
      expect(group.groupId, 'uuid-123');
      expect(group.groupName, 'Diabetes Support');
      expect(group.description, 'Support group');
      expect(group.membersId, isEmpty);
      expect(group.groupChatHistory, isEmpty);
    });

    test('fromJson handles legacy keys (group_id/group_name)', () {
      final group = ChatGroup.fromJson({
        'group_id': 'g1',
        'group_name': 'Test Group',
        'members_id': ['1', '2'],
        'group_chat_history': [
          {
            'sender_id': '1',
            'content': 'Hello',
            'timestamp': '2026-06-18T12:00:00Z',
          },
        ],
      });
      expect(group.groupId, 'g1');
      expect(group.groupName, 'Test Group');
      expect(group.membersId, ['1', '2']);
      expect(group.groupChatHistory.length, 1);
    });
  });
}
