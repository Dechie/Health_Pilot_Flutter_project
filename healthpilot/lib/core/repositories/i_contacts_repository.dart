import 'package:healthpilot/features/profile/personal_info_contact_models.dart';

abstract class IContactsRepository {
  Future<List<EmergencyContactEntry>> fetchEmergencyContacts();
  Future<EmergencyContactEntry> addEmergencyContact(
      EmergencyContactEntry contact);
  Future<EmergencyContactEntry> updateEmergencyContact(
      EmergencyContactEntry contact);
  Future<void> deleteEmergencyContact(String id);

  Future<List<PersonalDoctorEntry>> fetchDoctors();
  Future<PersonalDoctorEntry> addDoctor(PersonalDoctorEntry doctor);
  Future<PersonalDoctorEntry> updateDoctor(PersonalDoctorEntry doctor);
  Future<void> deleteDoctor(String id);
}
