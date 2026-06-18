import 'package:flutter/material.dart';
import 'package:healthpilot/features/medication/medication_models.dart';
import 'package:healthpilot/features/medication/medication_provider.dart';
import 'package:provider/provider.dart';

/// Dose history for a single medication.
class MedicationHistoryScreen extends StatelessWidget {
  const MedicationHistoryScreen({super.key, required this.medication});

  final Medication medication;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${medication.medicationName} — History')),
      body: FutureBuilder<List<DoseLog>>(
        future:
            context.read<MedicationProvider>().fetchDoses(medication.id ?? -1),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Failed to load dose history.'));
          }
          final doses = snapshot.data ?? [];
          if (doses.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'No dose history yet.',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          return ListView.separated(
            itemCount: doses.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final dose = doses[i];
              return ListTile(
                title: Text(dose.formattedDate),
                subtitle: Text(dose.status),
                trailing: dose.takenAt != null
                    ? const Icon(Icons.check_circle_outline,
                        color: Colors.green)
                    : const Icon(Icons.cancel_outlined, color: Colors.red),
              );
            },
          );
        },
      ),
    );
  }
}
