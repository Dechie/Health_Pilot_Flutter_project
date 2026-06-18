import 'package:flutter/foundation.dart';
import 'package:healthpilot/core/repositories/i_contacts_repository.dart';
import 'package:healthpilot/features/profile/personal_info_contact_models.dart';

class ContactsProvider extends ChangeNotifier {
  final IContactsRepository _repo;

  List<EmergencyContactEntry> _contacts = [];
  List<PersonalDoctorEntry> _doctors = [];
  bool _loadStarted = false;

  List<EmergencyContactEntry> get contacts => List.unmodifiable(_contacts);
  List<PersonalDoctorEntry> get doctors => List.unmodifiable(_doctors);

  ContactsProvider(this._repo);

  Future<void> load() async {
    if (_loadStarted) return;
    _loadStarted = true;
    try {
      _contacts = await _repo.fetchEmergencyContacts();
      _doctors = await _repo.fetchDoctors();
    } catch (_) {
      // silently fall back to empty lists
    } finally {
      notifyListeners();
    }
  }

  Future<void> addContact(EmergencyContactEntry contact) async {
    final created = await _repo.addEmergencyContact(contact);
    _contacts = [..._contacts, created];
    notifyListeners();
  }

  Future<void> updateContact(EmergencyContactEntry contact) async {
    final updated = await _repo.updateEmergencyContact(contact);
    _contacts = [
      for (final c in _contacts)
        if (c.id == updated.id) updated else c,
    ];
    notifyListeners();
  }

  Future<void> deleteContact(String id) async {
    await _repo.deleteEmergencyContact(id);
    _contacts = _contacts.where((c) => c.id != id).toList();
    notifyListeners();
  }

  Future<void> addDoctor(PersonalDoctorEntry doctor) async {
    final created = await _repo.addDoctor(doctor);
    _doctors = [..._doctors, created];
    notifyListeners();
  }

  Future<void> updateDoctor(PersonalDoctorEntry doctor) async {
    final updated = await _repo.updateDoctor(doctor);
    _doctors = [
      for (final d in _doctors)
        if (d.id == updated.id) updated else d,
    ];
    notifyListeners();
  }

  Future<void> deleteDoctor(String id) async {
    await _repo.deleteDoctor(id);
    _doctors = _doctors.where((d) => d.id != id).toList();
    notifyListeners();
  }
}
