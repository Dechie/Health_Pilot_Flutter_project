import 'package:healthpilot/features/medication/medication_models.dart';

abstract class IMedicationRepository {
  Future<List<Medication>> fetchMedications({bool activeOnly = true});
  Future<Medication> addMedication(Medication medication);
  Future<Medication> updateMedication(Medication medication);
  Future<void> deleteMedication(int id);

  Future<List<MedicationReminder>> fetchReminders(int medicationId);
  Future<MedicationReminder> addReminder(int medicationId, MedicationReminder reminder);
  Future<MedicationReminder> updateReminder(int medicationId, MedicationReminder reminder);
  Future<void> deleteReminder(int medicationId, int reminderId);

  Future<List<DoseLog>> fetchDoses(int medicationId);
  Future<DoseLog> logDose(int medicationId, DoseLog dose);
}
