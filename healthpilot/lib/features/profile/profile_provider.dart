import 'package:flutter/foundation.dart';
import 'package:healthpilot/core/flags/feature_flags.dart';
import 'package:healthpilot/core/network/api_error.dart';
import 'package:healthpilot/core/repositories/i_profile_repository.dart';
import 'package:healthpilot/features/profile/user_profile.dart';

enum ProfileLoadStatus { idle, loading, loaded, error }

class ProfileProvider extends ChangeNotifier {
  final IProfileRepository _repo;

  UserProfile _profile = kDemoUserProfile;
  ProfileLoadStatus _status = ProfileLoadStatus.idle;
  String? _error;

  ProfileProvider(this._repo);

  UserProfile get profile => _profile;
  ProfileLoadStatus get status => _status;
  String? get error => _error;
  bool get isLoading => _status == ProfileLoadStatus.loading;

  /// Fetches profile from backend. Guarded against double-loading.
  Future<void> load() async {
    if (!FeatureFlags.userProfile) return;
    if (_status == ProfileLoadStatus.loading || _status == ProfileLoadStatus.loaded) return;
    _status = ProfileLoadStatus.loading;
    notifyListeners();
    try {
      final auth = await _repo.fetchMe();
      final pub = await _repo.fetchPublicProfile();
      _profile = auth.mergeWith(pub);
      _status = ProfileLoadStatus.loaded;
      _error = null;
    } on ApiException catch (e) {
      _status = ProfileLoadStatus.error;
      _error = e.userMessage;
    } catch (e) {
      _status = ProfileLoadStatus.error;
      _error = 'Failed to load profile.';
    }
    notifyListeners();
  }

  /// Saves core identity fields to the backend (or updates local cache in mock mode).
  Future<void> save(UserProfile updated) async {
    if (!FeatureFlags.userProfile) {
      _profile = updated;
      notifyListeners();
      return;
    }
    final saved = await _repo.updateMe(updated);
    _profile = saved;
    notifyListeners();
  }

  /// Resets to demo state — called when the user logs out or switches accounts.
  void reset() {
    _profile = kDemoUserProfile;
    _status = ProfileLoadStatus.idle;
    _error = null;
    notifyListeners();
  }

  /// Saves public profile fields (about_me, visibility).
  Future<void> savePublic(UserProfile updated) async {
    if (!FeatureFlags.userProfile) {
      _profile = _profile.mergeWith(updated);
      notifyListeners();
      return;
    }
    final saved = await _repo.updatePublicProfile(updated);
    _profile = _profile.mergeWith(saved);
    notifyListeners();
  }

}
