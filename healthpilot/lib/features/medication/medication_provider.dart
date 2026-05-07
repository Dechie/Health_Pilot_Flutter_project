import 'package:flutter/foundation.dart';
import 'package:healthpilot/core/network/api_error.dart';
import 'package:healthpilot/core/repositories/i_medication_repository.dart';
import 'package:healthpilot/features/medication/medication_models.dart';

enum MedLoadStatus { idle, loading, loaded, error }

class MedicationProvider extends ChangeNotifier {
  final IMedicationRepository _repo;

  List<Medication> _medications = [];
  MedLoadStatus _status = MedLoadStatus.idle;
  String? _error;
  bool _loadStarted = false;

  List<Medication> get medications => List.unmodifiable(_medications);
  MedLoadStatus get status => _status;
  String? get error => _error;

  MedicationProvider(this._repo);

  Future<void> load() async {
    if (_loadStarted) return;
    _loadStarted = true;
    _status = MedLoadStatus.loading;
    _error = null;
    notifyListeners();
    try {
      _medications = await _repo.fetchMedications();
      _status = MedLoadStatus.loaded;
    } on ApiException catch (e) {
      _error = _msg(e);
      _status = MedLoadStatus.error;
    } finally {
      notifyListeners();
    }
  }

  Future<void> add(Medication medication) async {
    final created = await _repo.addMedication(medication);
    _medications = [..._medications, created];
    notifyListeners();
  }

  Future<void> update(Medication medication) async {
    final updated = await _repo.updateMedication(medication);
    _medications = [
      for (final m in _medications)
        if (m.id == updated.id) updated else m,
    ];
    notifyListeners();
  }

  Future<void> delete(int id) async {
    await _repo.deleteMedication(id);
    _medications = _medications.where((m) => m.id != id).toList();
    notifyListeners();
  }

  Future<List<MedicationReminder>> fetchReminders(int medicationId) =>
      _repo.fetchReminders(medicationId);

  Future<MedicationReminder> addReminder(
          int medicationId, MedicationReminder r) =>
      _repo.addReminder(medicationId, r);

  Future<void> deleteReminder(int medicationId, int reminderId) =>
      _repo.deleteReminder(medicationId, reminderId);

  Future<List<DoseLog>> fetchDoses(int medicationId) =>
      _repo.fetchDoses(medicationId);

  Future<DoseLog> logDose(int medicationId, DoseLog dose) =>
      _repo.logDose(medicationId, dose);

  static String _msg(ApiException e) => switch (e) {
        ServerError(:final message) => message,
        NetworkError() => 'No internet connection.',
        _ => 'Something went wrong.',
      };

  static String errorMessage(ApiException e) => _msg(e);
}
