import 'package:flutter_test/flutter_test.dart';
import 'package:healthpilot/features/chat/chat_models.dart';

/// Regression guard: parse the EXACT payloads returned by the live backend
/// (captured via scripts/chat_api_smoke.sh, 2026-06-20) so a future backend
/// contract change is caught here rather than crashing the chat screen.
void main() {
  group('GET /chat/users/ — connected peer', () {
    final liveUser = {
      'id': 24,
      'full_name': 'user two two',
      'email': 'dechasateshome566@gmail.com',
      'avatar': null,
    };

    test('parses int id, full_name, null avatar', () {
      final u = ChatUser.fromJson(liveUser);
      expect(u.userId, '24');
      expect(u.displayName, 'user two two');
      expect(u.profilePictureUrl, '');
    });

    test('still accepts the legacy {user_id, display_name} shape', () {
      final u = ChatUser.fromJson({
        'user_id': '7',
        'display_name': 'Legacy',
        'profile_picture_url': 'http://x/p.png',
      });
      expect(u.userId, '7');
      expect(u.displayName, 'Legacy');
      expect(u.profilePictureUrl, 'http://x/p.png');
    });
  });

  group('GET /chat/groups/ — group object', () {
    final liveGroup = {
      'id': '412622b5-9eeb-4696-82d9-3c13385e8ded',
      'name': 'Diabetes Support',
      'description': 'Support group',
      'participants': [
        {'id': 23, 'full_name': 'user one one', 'email': 'x', 'profile_picture': null},
        {'id': 99, 'full_name': 'someone else', 'email': 'y', 'profile_picture': null},
      ],
      'participant_count': 2,
      'last_message': null,
      'is_active': true,
      'created_at': '2026-06-20T17:01:12.470429Z',
    };

    test('parses id/name and maps participants -> membersId', () {
      final g = ChatGroup.fromJson(liveGroup);
      expect(g.groupId, '412622b5-9eeb-4696-82d9-3c13385e8ded');
      expect(g.groupName, 'Diabetes Support');
      expect(g.membersId, containsAll(<String>['23', '99']));
    });
  });

  group('message object', () {
    test('DirectMessage.fromJson parses int sender_id', () {
      final m = DirectMessage.fromJson({
        'id': '37f8161f-0222-409b-9682-656db7736079',
        'sender_id': 23,
        'sender_name': 'user one one',
        'content': 'Hi everyone!',
        'timestamp': '2026-06-20T17:01:15.869546Z',
        'is_deleted': false,
      });
      expect(m.id, '37f8161f-0222-409b-9682-656db7736079');
      expect(m.senderId, '23');
      expect(m.content, 'Hi everyone!');
    });
  });

  group('GET /chat/private/ — private chat object', () {
    test('PrivateChat.fromJson parses participants + nested last_message', () {
      final c = PrivateChat.fromJson({
        'id': '48dc6594-c1f8-41a6-94a6-d86a4bc4b9bc',
        'participants': [
          {'id': 24, 'full_name': 'user two two', 'email': 'x', 'profile_picture': null},
          {'id': 23, 'full_name': 'user one one', 'email': 'y', 'profile_picture': null},
        ],
        'last_message': {
          'content': 'Hello from smoke test!',
          'sender_name': 'user one one',
          'timestamp': '2026-06-20T17:01:09.013717+00:00',
        },
        'created_at': '2026-06-18T13:29:29.105974Z',
      });
      expect(c.id, '48dc6594-c1f8-41a6-94a6-d86a4bc4b9bc');
      expect(c.participants.length, 2);
      expect(c.lastMessage, 'Hello from smoke test!');
    });
  });
}
