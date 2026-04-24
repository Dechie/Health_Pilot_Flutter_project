import 'package:flutter/material.dart';

/// Placeholder for future reminder scheduling (notifications, backend sync).
class MedicationRemindersScreen extends StatelessWidget {
  const MedicationRemindersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medication reminders')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Reminder scheduling will be wired here after notification preferences and backend support are defined.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
