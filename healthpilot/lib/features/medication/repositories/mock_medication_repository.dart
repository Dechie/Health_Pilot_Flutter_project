import 'package:healthpilot/core/repositories/i_medication_repository.dart';
import 'package:healthpilot/features/medication/medication_models.dart';

class MockMedicationRepository implements IMedicationRepository {
  final List<Medication> _store = List.of(kSeedMedications);
  int _nextId = kSeedMedications.length + 1;

  @override
  Future<List<Medication>> fetchMedications({bool activeOnly = true}) async =>
      _store.where((m) => !activeOnly || m.isActive).toList();

  @override
  Future<Medication> addMedication(Medication medication) async {
    final created = medication.copyWith(id: _nextId++);
    _store.add(created);
    return created;
  }

  @override
  Future<Medication> updateMedication(Medication medication) async {
    final idx = _store.indexWhere((m) => m.id == medication.id);
    if (idx != -1) _store[idx] = medication;
    return medication;
  }

  @override
  Future<void> deleteMedication(int id) async =>
      _store.removeWhere((m) => m.id == id);

  @override
  Future<List<MedicationReminder>> fetchReminders(int medicationId) async => [];

  @override
  Future<MedicationReminder> addReminder(
          int medicationId, MedicationReminder reminder) async =>
      MedicationReminder(
        id: reminder.id ?? _nextId++,
        reminderTime: reminder.reminderTime,
        daysOfWeek: reminder.daysOfWeek,
      );

  @override
  Future<MedicationReminder> updateReminder(
          int medicationId, MedicationReminder reminder) async =>
      reminder;

  @override
  Future<void> deleteReminder(int medicationId, int reminderId) async {}

  @override
  Future<List<DoseLog>> fetchDoses(int medicationId) async => [];

  @override
  Future<DoseLog> logDose(int medicationId, DoseLog dose) async =>
      DoseLog(
        id: dose.id ?? _nextId++,
        status: dose.status,
        scheduledAt: dose.scheduledAt,
        takenAt: dose.takenAt,
      );
}
