import 'package:flutter/material.dart';

/// Placeholder for future medication history (doses taken, changes over time).
class MedicationHistoryScreen extends StatelessWidget {
  const MedicationHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Medication history')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'History and adherence views will appear here once data persistence and APIs are in place.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
