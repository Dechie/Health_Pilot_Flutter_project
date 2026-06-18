import 'package:flutter/foundation.dart';
import 'package:healthpilot/core/flags/feature_flags.dart';
import 'package:healthpilot/core/network/api_error.dart';
import 'package:healthpilot/core/repositories/i_profile_repository.dart';
import 'package:healthpilot/features/profile/user_profile.dart';

enum ProfileLoadStatus { idle, loading, loaded, error }

class ProfileProvider extends ChangeNotifier {
  final IProfileRepository _repo;

  UserProfile _profile =
      FeatureFlags.userProfile ? const UserProfile() : kDemoUserProfile;
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
    if (_status == ProfileLoadStatus.loading) return;
    _status = ProfileLoadStatus.loading;
    try {
      final auth = await _repo.fetchMe();
      _profile = auth;
      _status = ProfileLoadStatus.loaded;
      _error = null;
      try {
        final pub = await _repo.fetchPublicProfile();
        _profile = _profile.mergeWith(pub);
      } catch (_) {
        // Identity fields from /auth/me/ are enough for the profile header.
      }
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

  /// Onboarding step 1 — gender, date_of_birth (from age), height, weight, bmi.
  Future<void> saveOnboardingStep1({
    required String? gender,
    required int age,
    required double heightCm,
    required double weightKg,
    double? bmi,
  }) async {
    final apiGender = genderToApi(gender);
    final dob = DateTime.tryParse(dateOfBirthFromAge(age));
    final partial = UserProfile(
      gender: apiGender,
      dateOfBirth: dob,
      heightCm: heightCm,
      weightKg: weightKg,
      bmi: bmi,
    );
    final saved = await _repo.updateMe(partial);
    _profile = _profile.mergeWith(saved);
    notifyListeners();
  }

  /// Onboarding step 2 — hypertension, diabetes, smoking, recent surgery/accidents.
  Future<void> saveOnboardingStep2({
    required String hypertensionAnswer,
    required String accidentsAnswer,
    required String smokingAnswer,
    required String diabetesAnswer,
  }) async {
    final partial = UserProfile(
      hasHypertension: yesNoToYn(hypertensionAnswer),
      hadRecentSurgery: yesNoToYn(accidentsAnswer),
      isSmoker: yesNoToYn(smokingAnswer),
      hasDiabetes: yesNoToYn(diabetesAnswer),
    );
    final saved = await _repo.updateMe(partial);
    _profile = _profile.mergeWith(saved);
    notifyListeners();
  }

  /// Saves allergies only (profile allergies screen).
  Future<void> saveAllergies(List<String> selectedAllergies) async {
    final partial = UserProfile(
      allergies:
          selectedAllergies.isEmpty ? null : selectedAllergies.join(', '),
    );
    final saved = await _repo.updateMe(partial);
    _profile = _profile.mergeWith(saved);
    notifyListeners();
  }

  /// Onboarding step 3 — allergies, chronic condition, blood type.
  Future<void> saveOnboardingStep3({
    required List<String> selectedAllergies,
    required String chronicConditionAnswer,
    required String bloodType,
  }) async {
    final partial = UserProfile(
      allergies:
          selectedAllergies.isEmpty ? null : selectedAllergies.join(', '),
      hasChronicCondition: yesNoToYn(chronicConditionAnswer),
      bloodType: bloodType,
    );
    final saved = await _repo.updateMe(partial);
    _profile = _profile.mergeWith(saved);
    notifyListeners();
  }

  /// Resets to demo state — called when the user logs out or switches accounts.
  void reset() {
    _profile =
        FeatureFlags.userProfile ? const UserProfile() : kDemoUserProfile;
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
