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
import 'package:healthpilot/features/chat/chat_provider.dart';
import 'package:healthpilot/features/chat/general_chat_screen.dart';
import 'package:healthpilot/features/chat/repositories/mock_chat_repository.dart';
import 'package:healthpilot/theme/app_theme.dart';

import 'helpers/chat_local_store_test_helper.dart';

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

Widget _buildTestApp(ChatProvider chatP) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => AppState()),
      ChangeNotifierProvider(
        create: (_) => AuthState(
          repo: MockAuthRepository(),
          tokenStore: const _MockTokenStore(),
        ),
      ),
      ChangeNotifierProvider.value(value: chatP),
    ],
    child: ScreenUtilInit(
      designSize: const Size(411, 852),
      minTextAdapt: true,
      builder: (_, __) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const GeneralChatScreen(showBackButton: false),
      ),
    ),
  );
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

  group('Create group UI flow', () {
    testWidgets('createGroup via provider adds group to state',
        (tester) async {
      final localStore = await createTestChatLocalStore();
      final chatP = ChatProvider(MockChatRepository(), localStore: localStore);
      await chatP.load();

      final before = chatP.groups.length;
      await chatP.createGroup('Test Group', 'Description');
      expect(chatP.groups.length, before + 1);
      expect(
        chatP.groups.any((g) => g.groupName == 'Test Group'),
        isTrue,
      );
    });

    testWidgets('create group button is visible on Groups tab',
        (tester) async {
      final localStore = await createTestChatLocalStore();
      final chatP = ChatProvider(MockChatRepository(), localStore: localStore);
      await chatP.load();

      await tester.pumpWidget(_buildTestApp(chatP));
      await tester.pump();

      // Navigate to Groups tab
      await tester.tap(find.text('Groups'));
      await tester.pump();

      // Button should be visible
      expect(find.text('Create Group'), findsOneWidget);
    });

    testWidgets('tap create group opens dialog', (tester) async {
      final localStore = await createTestChatLocalStore();
      final chatP = ChatProvider(MockChatRepository(), localStore: localStore);
      await chatP.load();

      await tester.pumpWidget(_buildTestApp(chatP));
      await tester.pump();

      // Navigate to Groups tab
      await tester.tap(find.text('Groups'));
      await tester.pump();

      // Tap the create group button
      await tester.tap(find.text('Create Group'));
      await tester.pump(const Duration(milliseconds: 500));

      // Dialog should be visible
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget);
    });

    testWidgets('create group dialog creates group via provider',
        (tester) async {
      final localStore = await createTestChatLocalStore();
      final chatP = ChatProvider(MockChatRepository(), localStore: localStore);
      await chatP.load();

      await tester.pumpWidget(_buildTestApp(chatP));
      await tester.pump();

      // Navigate to Groups tab
      await tester.tap(find.text('Groups'));
      await tester.pump();

      // Tap create group button
      await tester.tap(find.text('Create Group'));
      await tester.pump(const Duration(milliseconds: 500));

      // Enter group name
      await tester.enterText(
        find.widgetWithText(TextField, 'Group name'),
        'Anxiety Support',
      );
      await tester.pump();

      // Tap Create in dialog
      await tester.tap(find.widgetWithText(FilledButton, 'Create'));
      await tester.pump(const Duration(milliseconds: 500));

      // Verify provider state
      expect(
        chatP.groups.any((g) => g.groupName == 'Anxiety Support'),
        isTrue,
      );

      // Verify the group name appears in the UI list
      expect(find.text('Anxiety Support'), findsOneWidget);
    });
  });
}
