import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:healthpilot/core/auth/auth_state.dart';
import 'package:healthpilot/core/auth/mock_auth_repository.dart';
import 'package:healthpilot/core/auth/remote_auth_repository.dart';
import 'package:healthpilot/core/flags/feature_flags.dart';
import 'package:healthpilot/core/network/api_client.dart';
import 'package:healthpilot/core/repositories/i_medication_repository.dart';
import 'package:healthpilot/core/repositories/i_profile_repository.dart';
import 'package:healthpilot/core/storage/secure_token_store.dart';
import 'package:healthpilot/features/medication/medication_provider.dart';
import 'package:healthpilot/features/medication/repositories/mock_medication_repository.dart';
import 'package:healthpilot/features/medication/repositories/remote_medication_repository.dart';
import 'package:healthpilot/features/profile/profile_provider.dart';
import 'package:healthpilot/features/profile/repositories/mock_profile_repository.dart';
import 'package:healthpilot/features/profile/repositories/remote_profile_repository.dart';
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

        // Branch 3 — User profile; auto-loads when AuthState becomes authenticated.
        ChangeNotifierProxyProvider<AuthState, ProfileProvider>(
          create: (_) => ProfileProvider(
            FeatureFlags.userProfile
                ? RemoteProfileRepository(apiClient) as IProfileRepository
                : MockProfileRepository(),
          ),
          update: (_, authState, provider) {
            if (authState.status == AuthStatus.authenticated) {
              provider!.load();
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
      ];
}
