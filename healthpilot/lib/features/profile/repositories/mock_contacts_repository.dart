import 'package:healthpilot/core/repositories/i_contacts_repository.dart';
import 'package:healthpilot/features/profile/personal_info_contact_models.dart';

class MockContactsRepository implements IContactsRepository {
  final List<EmergencyContactEntry> _contacts = [];
  final List<PersonalDoctorEntry> _doctors = [];

  @override
  Future<List<EmergencyContactEntry>> fetchEmergencyContacts() async =>
      List.of(_contacts);

  @override
  Future<EmergencyContactEntry> addEmergencyContact(
      EmergencyContactEntry contact) async {
    _contacts.add(contact);
    return contact;
  }

  @override
  Future<EmergencyContactEntry> updateEmergencyContact(
      EmergencyContactEntry contact) async {
    final idx = _contacts.indexWhere((c) => c.id == contact.id);
    if (idx != -1) _contacts[idx] = contact;
    return contact;
  }

  @override
  Future<void> deleteEmergencyContact(String id) async {
    _contacts.removeWhere((c) => c.id == id);
  }

  @override
  Future<List<PersonalDoctorEntry>> fetchDoctors() async => List.of(_doctors);

  @override
  Future<PersonalDoctorEntry> addDoctor(PersonalDoctorEntry doctor) async {
    _doctors.add(doctor);
    return doctor;
  }

  @override
  Future<PersonalDoctorEntry> updateDoctor(PersonalDoctorEntry doctor) async {
    final idx = _doctors.indexWhere((d) => d.id == doctor.id);
    if (idx != -1) _doctors[idx] = doctor;
    return doctor;
  }

  @override
  Future<void> deleteDoctor(String id) async {
    _doctors.removeWhere((d) => d.id == id);
  }
}
