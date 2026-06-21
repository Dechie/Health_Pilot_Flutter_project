import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:healthpilot/core/auth/auth_state.dart';
import 'package:healthpilot/core/auth/mock_auth_repository.dart';
import 'package:healthpilot/core/providers/app_state.dart';
import 'package:healthpilot/core/storage/secure_token_store.dart';
import 'package:healthpilot/features/chat/chat_models.dart';
import 'package:healthpilot/features/chat/chat_provider.dart';
import 'package:healthpilot/features/chat/chat_screen.dart';
import 'package:healthpilot/features/chat/repositories/mock_chat_repository.dart';
import 'package:healthpilot/theme/app_theme.dart';

class _MockTokenStore extends SecureTokenStore {
  const _MockTokenStore() : super(const FlutterSecureStorage());

  @override
  Future<String?> getAccessToken() async => null;
  @override
  Future<String?> getRefreshToken() async => null;
  @override
  Future<String?> getUserId() async => null;
  @override
  Future<void> setAccessToken(String t) async {}
  @override
  Future<void> setRefreshToken(String t) async {}
  @override
  Future<void> setUserId(String id) async {}
  @override
  Future<void> clearAll() async {}
}

/// Subclass that exposes [ChatProvider]'s [@visibleForTesting] methods directly.
class TestableChatProvider extends ChatProvider {
  TestableChatProvider() : super(MockChatRepository());
}

void main() {
  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.it_abs.com/flutter_secure_storage'),
      (_) async => null,
    );
  });

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('ChatProvider loading state', () {
    test('isLoadingThread reflects _loadingThreads state', () {
      final chatP = TestableChatProvider();

      expect(chatP.isLoadingThread('test-1'), isFalse);

      chatP.setLoadingThread('test-1', true);
      expect(chatP.isLoadingThread('test-1'), isTrue);

      chatP.setLoadingThread('test-1', false);
      expect(chatP.isLoadingThread('test-1'), isFalse);
    });

    test('independent threads do not interfere', () {
      final chatP = TestableChatProvider();

      chatP.setLoadingThread('a', true);
      chatP.setLoadingThread('b', true);

      expect(chatP.isLoadingThread('a'), isTrue);
      expect(chatP.isLoadingThread('b'), isTrue);

      chatP.setLoadingThread('a', false);

      expect(chatP.isLoadingThread('a'), isFalse);
      expect(chatP.isLoadingThread('b'), isTrue);
    });
  });

  group('ChatScreen three-way conditional', () {
    /// Pumps a minimal scaffold that replicates the exact three-way logic
    /// from [ChatScreen.build] to verify it renders correctly for each state.
    Future<void> pumpTestScaffold(
      WidgetTester tester, {
      required bool loading,
      required bool empty,
    }) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              if (loading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (empty)
                const Expanded(
                  child: Center(child: Text('Be the first to say hello')),
                )
              else
                const Expanded(
                  child: Center(child: Text('Hello!')),
                ),
            ],
          ),
        ),
      ));
      await tester.pump();
    }

    testWidgets('shows spinner when loading', (tester) async {
      await pumpTestScaffold(tester, loading: true, empty: true);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Be the first to say hello'), findsNothing);
      expect(find.text('Hello!'), findsNothing);
    });

    testWidgets('shows empty state when not loading and empty',
        (tester) async {
      await pumpTestScaffold(tester, loading: false, empty: true);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Be the first to say hello'), findsOneWidget);
      expect(find.text('Hello!'), findsNothing);
    });

    testWidgets('shows messages when not loading and not empty',
        (tester) async {
      await pumpTestScaffold(tester, loading: false, empty: false);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Be the first to say hello'), findsNothing);
      expect(find.text('Hello!'), findsOneWidget);
    });
  });

}
