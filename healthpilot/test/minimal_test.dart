import 'package:flutter_test/flutter_test.dart';
import 'helpers/chat_local_store_test_helper.dart';

void main() {
  testWidgets('minimal local store test', (tester) async {
    final store = await createTestChatLocalStore();
    expect(store, isNotNull);
  });
}
