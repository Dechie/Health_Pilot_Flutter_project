import 'package:healthpilot/core/network/api_client.dart';
import 'package:healthpilot/core/network/api_constants.dart';
import 'package:healthpilot/core/repositories/i_medication_repository.dart';
import 'package:healthpilot/features/medication/medication_models.dart';

class RemoteMedicationRepository implements IMedicationRepository {
  const RemoteMedicationRepository(this._client);
  final ApiClient _client;

  @override
  Future<List<Medication>> fetchMedications({bool activeOnly = true}) async {
    final data = await _client.get(
      '${ApiConstants.medicationsBase}/',
      queryParameters: activeOnly ? {'active': true} : null,
    );
    return (data as List)
        .map((e) => Medication.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<Medication> addMedication(Medication medication) async {
    final data = await _client.post(
      '${ApiConstants.medicationsBase}/',
      data: medication.toJson(),
    );
    return Medication.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<Medication> updateMedication(Medication medication) async {
    final data = await _client.patch(
      '${ApiConstants.medicationsBase}/${medication.id}/',
      data: medication.toJson(),
    );
    return Medication.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteMedication(int id) async =>
      _client.delete('${ApiConstants.medicationsBase}/$id/');

  @override
  Future<List<MedicationReminder>> fetchReminders(int medicationId) async {
    final data = await _client
        .get('${ApiConstants.medicationsBase}/$medicationId/reminders/');
    return (data as List)
        .map((e) => MedicationReminder.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<MedicationReminder> addReminder(
      int medicationId, MedicationReminder reminder) async {
    final data = await _client.post(
      '${ApiConstants.medicationsBase}/$medicationId/reminders/',
      data: reminder.toJson(),
    );
    return MedicationReminder.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<MedicationReminder> updateReminder(
      int medicationId, MedicationReminder reminder) async {
    final data = await _client.patch(
      '${ApiConstants.medicationsBase}/$medicationId/reminders/${reminder.id}/',
      data: reminder.toJson(),
    );
    return MedicationReminder.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> deleteReminder(int medicationId, int reminderId) async =>
      _client.delete(
          '${ApiConstants.medicationsBase}/$medicationId/reminders/$reminderId/');

  @override
  Future<List<DoseLog>> fetchDoses(int medicationId) async {
    final data = await _client
        .get('${ApiConstants.medicationsBase}/$medicationId/doses/');
    return (data as List)
        .map((e) => DoseLog.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<DoseLog> logDose(int medicationId, DoseLog dose) async {
    final data = await _client.post(
      '${ApiConstants.medicationsBase}/$medicationId/doses/',
      data: dose.toJson(),
    );
    return DoseLog.fromJson(data as Map<String, dynamic>);
  }
}
