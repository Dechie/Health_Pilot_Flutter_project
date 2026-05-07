import 'package:flutter/material.dart';
import 'package:healthpilot/features/medication/medication_models.dart';
import 'package:healthpilot/features/medication/medication_provider.dart';
import 'package:provider/provider.dart';

/// Reminder list for a single medication.
class MedicationRemindersScreen extends StatelessWidget {
  const MedicationRemindersScreen({super.key, required this.medication});

  final Medication medication;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${medication.medicationName} — Reminders')),
      body: FutureBuilder<List<MedicationReminder>>(
        future: context
            .read<MedicationProvider>()
            .fetchReminders(medication.id ?? -1),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load reminders.'));
          }
          final reminders = snapshot.data ?? [];
          if (reminders.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No reminders set yet.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: reminders.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final r = reminders[i];
              return ListTile(
                leading: const Icon(Icons.alarm),
                title: Text(r.reminderTime),
                subtitle: Text(_daysLabel(r.daysOfWeek)),
              );
            },
          );
        },
      ),
    );
  }

  static const _dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  String _daysLabel(List<int> days) {
    if (days.length == 7) return 'Every day';
    return days.map((d) => _dayNames[d % 7]).join(', ');
  }
}
