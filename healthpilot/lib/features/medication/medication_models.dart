import 'package:intl/intl.dart';

const List<String> kDosageUnits = [
  'mg',
  'mcg',
  'ml',
  'g',
  'iu',
  'tabs',
  'caps',
  'drops',
];

class Medication {
  const Medication(
    this.medicationName,
    this.noTimesPerDay,
    this.miligrams, {
    this.id,
    this.dosageUnit = 'mg',
    this.isActive = true,
  });

  final int? id;
  final String medicationName;
  final int noTimesPerDay;
  final int miligrams;
  final String dosageUnit;
  final bool isActive;

  factory Medication.fromJson(Map<String, dynamic> json) => Medication(
        json['medication_name'] as String? ?? '',
        json['doses_per_day'] as int? ?? 1,
        ((json['dosage_amount'] as num?)?.toInt()) ?? 0,
        id: json['id'] as int?,
        dosageUnit: json['dosage_unit'] as String? ?? 'mg',
        isActive: json['is_active'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'medication_name': medicationName,
        'doses_per_day': noTimesPerDay,
        'dosage_amount': miligrams,
        'dosage_unit': dosageUnit,
      };

  Medication copyWith({
    int? id,
    String? medicationName,
    int? noTimesPerDay,
    int? miligrams,
    String? dosageUnit,
    bool? isActive,
  }) =>
      Medication(
        medicationName ?? this.medicationName,
        noTimesPerDay ?? this.noTimesPerDay,
        miligrams ?? this.miligrams,
        id: id ?? this.id,
        dosageUnit: dosageUnit ?? this.dosageUnit,
        isActive: isActive ?? this.isActive,
      );
}

class MedicationReminder {
  const MedicationReminder({
    this.id,
    required this.reminderTime,
    this.daysOfWeek = const [0, 1, 2, 3, 4, 5, 6],
  });

  final int? id;
  final String reminderTime; // "HH:MM" 24-hour
  final List<int> daysOfWeek; // 0 = Monday (backend convention)

  factory MedicationReminder.fromJson(Map<String, dynamic> json) =>
      MedicationReminder(
        id: json['id'] as int?,
        reminderTime: json['reminder_time'] as String,
        daysOfWeek: List<int>.from(json['days_of_week'] as List),
      );

  Map<String, dynamic> toJson() => {
        'reminder_time': reminderTime,
        'days_of_week': daysOfWeek,
      };
}

class DoseLog {
  const DoseLog({
    this.id,
    required this.status,
    required this.scheduledAt,
    this.takenAt,
  });

  final int? id;
  final String status; // 'taken' | 'missed' | 'skipped'
  final DateTime scheduledAt;
  final DateTime? takenAt;

  factory DoseLog.fromJson(Map<String, dynamic> json) => DoseLog(
        id: json['id'] as int?,
        status: json['status'] as String,
        scheduledAt: DateTime.parse(json['scheduled_at'] as String),
        takenAt: json['taken_at'] != null
            ? DateTime.parse(json['taken_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'status': status,
        'scheduled_at': scheduledAt.toIso8601String(),
        if (takenAt != null) 'taken_at': takenAt!.toIso8601String(),
      };

  String get formattedDate => DateFormat.yMMMd().format(scheduledAt);
}

/// Seed data used when FF_MEDICATIONS=false.
final List<Medication> kSeedMedications = [
  const Medication('Aspirin', 1, 100, id: 1, dosageUnit: 'mg'),
  const Medication('Vitamin D', 1, 1000, id: 2, dosageUnit: 'iu'),
];
