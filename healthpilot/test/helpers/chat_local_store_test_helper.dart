import 'package:healthpilot/core/database/chat_database.dart';
import 'package:healthpilot/core/repositories/i_ai_assistant_repository.dart';
import 'package:healthpilot/features/chat/chat_provider.dart';
import 'package:healthpilot/features/chat/data/chat_local_store.dart';
import 'package:healthpilot/features/chat/repositories/mock_chat_repository.dart';
import 'package:healthpilot/features/chatbot/ai_assistant_provider.dart';
import 'package:healthpilot/features/chatbot/repositories/mock_ai_assistant_repository.dart';

Future<ChatLocalStore> createTestChatLocalStore() async {
  final database = await ChatDatabase.openInMemory();
  return ChatLocalStore(database);
}

Future<ChatProvider> createTestChatProvider() async {
  final store = await createTestChatLocalStore();
  final provider = ChatProvider(MockChatRepository(), localStore: store);
  await provider.load();
  return provider;
}

Future<AiAssistantProvider> createTestAiProvider({
  IAiAssistantRepository? repository,
}) async {
  final store = await createTestChatLocalStore();
  final provider = AiAssistantProvider(
    repository ?? MockAiAssistantRepository(),
    localStore: store,
  );
  await provider.load();
  return provider;
}
