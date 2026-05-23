import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:healthpilot/core/auth/auth_state.dart';
import 'package:healthpilot/core/auth/mock_auth_repository.dart';
import 'package:healthpilot/core/auth/remote_auth_repository.dart';
import 'package:healthpilot/core/flags/feature_flags.dart';
import 'package:healthpilot/core/network/api_client.dart';
import 'package:healthpilot/core/repositories/i_ai_assistant_repository.dart';
import 'package:healthpilot/core/repositories/i_assessment_repository.dart';
import 'package:healthpilot/core/repositories/i_article_repository.dart';
import 'package:healthpilot/core/repositories/i_chat_repository.dart';
import 'package:healthpilot/core/repositories/i_contacts_repository.dart';
import 'package:healthpilot/core/repositories/i_nutrition_repository.dart';
import 'package:healthpilot/core/repositories/i_health_repository.dart';
import 'package:healthpilot/core/repositories/i_medication_repository.dart';
import 'package:healthpilot/core/repositories/i_profile_repository.dart';
import 'package:healthpilot/core/storage/secure_token_store.dart';
import 'package:healthpilot/features/articles/article_provider.dart';
import 'package:healthpilot/features/articles/repositories/mock_article_repository.dart';
import 'package:healthpilot/features/articles/repositories/remote_article_repository.dart';
import 'package:healthpilot/features/chat/chat_provider.dart';
import 'package:healthpilot/features/chat/repositories/mock_chat_repository.dart';
import 'package:healthpilot/features/chat/repositories/remote_chat_repository.dart';
import 'package:healthpilot/features/food_nutrition/nutrition_provider.dart';
import 'package:healthpilot/features/food_nutrition/repositories/mock_nutrition_repository.dart';
import 'package:healthpilot/features/food_nutrition/repositories/remote_nutrition_repository.dart';
import 'package:healthpilot/features/health/health_provider.dart';
import 'package:healthpilot/features/chatbot/ai_assistant_provider.dart';
import 'package:healthpilot/features/profile/contacts_provider.dart';
import 'package:healthpilot/features/profile/repositories/mock_contacts_repository.dart';
import 'package:healthpilot/features/profile/repositories/remote_contacts_repository.dart';
import 'package:healthpilot/features/chatbot/repositories/mock_ai_assistant_repository.dart';
import 'package:healthpilot/features/chatbot/repositories/remote_ai_assistant_repository.dart';
import 'package:healthpilot/features/health_assessment/assessment_provider.dart';
import 'package:healthpilot/features/health_assessment/repositories/mock_assessment_repository.dart';
import 'package:healthpilot/features/health_assessment/repositories/remote_assessment_repository.dart';
import 'package:healthpilot/features/health/repositories/mock_health_repository.dart';
import 'package:healthpilot/features/health/repositories/remote_health_repository.dart';
import 'package:healthpilot/features/medication/medication_provider.dart';
import 'package:healthpilot/features/medication/repositories/mock_medication_repository.dart';
import 'package:healthpilot/features/medication/repositories/remote_medication_repository.dart';
import 'package:healthpilot/features/profile/profile_provider.dart';
import 'package:healthpilot/features/profile/repositories/mock_profile_repository.dart';
import 'package:healthpilot/features/profile/repositories/remote_profile_repository.dart';
import 'package:healthpilot/core/repositories/i_subscription_repository.dart';
import 'package:healthpilot/features/subscription/subscription_provider.dart';
import 'package:healthpilot/features/subscription/repositories/mock_subscription_repository.dart';
import 'package:healthpilot/features/subscription/repositories/remote_subscription_repository.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

/// Initializes the network layer and builds the Provider list for all feature
/// repositories. Called once in main() before runApp.
///
/// Each integration branch adds its `Provider<IXRepository>` entry to [providers].
abstract final class RepositoryLocator {
  static late final SecureTokenStore tokenStore;
  static late final ApiClient apiClient;

  // Late-bound so AuthState can register its callback after creation.
  static void Function()? _onAuthExpiredCallback;

  static void initialize() {
    tokenStore = const SecureTokenStore(FlutterSecureStorage());
    ApiClient.initialize(
      tokenStore: tokenStore,
      onAuthExpired: () => _onAuthExpiredCallback?.call(),
    );
    apiClient = ApiClient.instance;
  }

  /// Feature repository providers — each integration branch appends one entry.
  static List<SingleChildWidget> get providers => [
        // Branch 2 — Auth
        ChangeNotifierProvider<AuthState>(
          create: (_) {
            final repo = FeatureFlags.auth
                ? RemoteAuthRepository(apiClient)
                : MockAuthRepository();
            final state = AuthState(repo: repo, tokenStore: tokenStore);
            _onAuthExpiredCallback = state.onAuthExpired;
            return state;
          },
        ),

        // Branch 3 — User profile; auto-loads when AuthState becomes authenticated (non-guest).
        ChangeNotifierProxyProvider<AuthState, ProfileProvider>(
          create: (_) => ProfileProvider(
            FeatureFlags.userProfile
                ? RemoteProfileRepository(apiClient) as IProfileRepository
                : MockProfileRepository(),
          ),
          update: (_, authState, provider) {
            if (authState.status == AuthStatus.authenticated && !authState.isGuest) {
              provider!.load();
            } else if (authState.status == AuthStatus.unauthenticated || authState.isGuest) {
              provider!.reset();
            }
            return provider!;
          },
        ),

        // Branch 4 — Medications; auto-loads when AuthState becomes authenticated.
        ChangeNotifierProxyProvider<AuthState, MedicationProvider>(
          create: (_) => MedicationProvider(
            FeatureFlags.medications
                ? RemoteMedicationRepository(apiClient) as IMedicationRepository
                : MockMedicationRepository(),
          ),
          update: (_, authState, provider) {
            if (authState.status == AuthStatus.authenticated) {
              provider!.load();
            }
            return provider!;
          },
        ),

        // Branch 5 — Health data; auto-loads when AuthState becomes authenticated.
        ChangeNotifierProxyProvider<AuthState, HealthProvider>(
          create: (_) => HealthProvider(
            FeatureFlags.healthData
                ? RemoteHealthRepository(apiClient) as IHealthRepository
                : MockHealthRepository(),
          ),
          update: (_, authState, provider) {
            if (authState.status == AuthStatus.authenticated) {
              provider!.load();
            }
            return provider!;
          },
        ),

        // Branch 7 — AI assistant; loads chat history when AuthState becomes authenticated.
        ChangeNotifierProxyProvider<AuthState, AiAssistantProvider>(
          create: (_) => AiAssistantProvider(
            FeatureFlags.aiAssistant
                ? RemoteAiAssistantRepository(apiClient)
                    as IAiAssistantRepository
                : MockAiAssistantRepository(),
          ),
          update: (_, authState, provider) {
            if (authState.status == AuthStatus.authenticated) {
              provider!.load();
            }
            return provider!;
          },
        ),

        // Branch 9 — Contacts; auto-loads when AuthState becomes authenticated.
        ChangeNotifierProxyProvider<AuthState, ContactsProvider>(
          create: (_) => ContactsProvider(
            FeatureFlags.contacts
                ? RemoteContactsRepository(apiClient) as IContactsRepository
                : MockContactsRepository(),
          ),
          update: (_, authState, provider) {
            if (authState.status == AuthStatus.authenticated) {
              provider!.load();
            }
            return provider!;
          },
        ),

        // Branch 13 — Articles; auto-loads feed when AuthState becomes authenticated.
        ChangeNotifierProxyProvider<AuthState, ArticleProvider>(
          create: (_) => ArticleProvider(
            FeatureFlags.articles
                ? RemoteArticleRepository(apiClient) as IArticleRepository
                : MockArticleRepository(),
          ),
          update: (_, authState, provider) {
            if (authState.status == AuthStatus.authenticated) {
              provider!.load();
            }
            return provider!;
          },
        ),

        // Branch 11 — Nutrition; auto-loads history and settings when AuthState becomes authenticated.
        ChangeNotifierProxyProvider<AuthState, NutritionProvider>(
          create: (_) => NutritionProvider(
            FeatureFlags.nutrition
                ? RemoteNutritionRepository(apiClient) as INutritionRepository
                : MockNutritionRepository(),
          ),
          update: (_, authState, provider) {
            if (authState.status == AuthStatus.authenticated) {
              provider!.load();
            }
            return provider!;
          },
        ),

        // Branch 10 — Chat; auto-loads users and groups when AuthState becomes authenticated.
        ChangeNotifierProxyProvider<AuthState, ChatProvider>(
          create: (_) => ChatProvider(
            FeatureFlags.chat
                ? RemoteChatRepository(apiClient) as IChatRepository
                : MockChatRepository(),
          ),
          update: (_, authState, provider) {
            if (authState.status == AuthStatus.authenticated) {
              provider!.load();
            }
            return provider!;
          },
        ),

        // Branch 6 — Assessment; auto-loads history when AuthState becomes authenticated.
        ChangeNotifierProxyProvider<AuthState, AssessmentProvider>(
          create: (_) => AssessmentProvider(
            FeatureFlags.assessment
                ? RemoteAssessmentRepository(apiClient) as IAssessmentRepository
                : MockAssessmentRepository(),
          ),
          update: (_, authState, provider) {
            if (authState.status == AuthStatus.authenticated) {
              provider!.load();
            }
            return provider!;
          },
        ),

        // Branch 14 — Subscriptions; auto-loads plans and status when AuthState becomes authenticated.
        ChangeNotifierProxyProvider<AuthState, SubscriptionProvider>(
          create: (_) => SubscriptionProvider(
            FeatureFlags.subscriptions
                ? RemoteSubscriptionRepository(apiClient)
                    as ISubscriptionRepository
                : MockSubscriptionRepository(),
          ),
          update: (_, authState, provider) {
            if (authState.status == AuthStatus.authenticated) {
              provider!.load();
            }
            return provider!;
          },
        ),
      ];
}
