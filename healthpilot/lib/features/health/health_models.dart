const List<HealthCondition> kSeedConditions = [
  HealthCondition(name: 'Schizophrenia', loggedAt: '11:30 AM, May 13, 2023'),
  HealthCondition(name: 'Bipolar Disorder', loggedAt: '11:30 AM, May 13, 2023'),
  HealthCondition(
      name: 'Major Depressive Disorder', loggedAt: '11:30 AM, May 13, 2023'),
  HealthCondition(
      name: 'Post-Traumatic Stress Disorder (PTSD)',
      loggedAt: '11:30 AM, May 13, 2023'),
  HealthCondition(
      name: 'Obsessive-Compulsive Disorder (OCD)',
      loggedAt: '11:30 AM, May 13, 2023'),
  HealthCondition(
      name: 'Generalized Anxiety Disorder (GAD)',
      loggedAt: '11:30 AM, May 13, 2023'),
  HealthCondition(
      name: 'Borderline Personality Disorder (BPD)',
      loggedAt: '11:30 AM, May 13, 2023'),
];

const List<HealthSymptom> kSeedSymptoms = [
  HealthSymptom(name: 'Fever', severity: 4, loggedAt: '09:00 AM, Jan 1, 2024'),
  HealthSymptom(name: 'Cough', severity: 2, loggedAt: '09:00 AM, Jan 1, 2024'),
  HealthSymptom(
      name: 'Shortness of breath',
      severity: 6,
      loggedAt: '09:00 AM, Jan 1, 2024'),
  HealthSymptom(
      name: 'Fatigue', severity: 4, loggedAt: '09:00 AM, Jan 1, 2024'),
  HealthSymptom(
      name: 'Loss of taste or smell',
      severity: 2,
      loggedAt: '09:00 AM, Jan 1, 2024'),
  HealthSymptom(
      name: 'Muscle or body aches',
      severity: 4,
      loggedAt: '09:00 AM, Jan 1, 2024'),
  HealthSymptom(
      name: 'Headache', severity: 4, loggedAt: '09:00 AM, Jan 1, 2024'),
  HealthSymptom(
      name: 'Sore throat', severity: 2, loggedAt: '09:00 AM, Jan 1, 2024'),
  HealthSymptom(
      name: 'Congestion or runny nose',
      severity: 2,
      loggedAt: '09:00 AM, Jan 1, 2024'),
  HealthSymptom(
      name: 'Nausea or vomiting',
      severity: 4,
      loggedAt: '09:00 AM, Jan 1, 2024'),
  HealthSymptom(
      name: 'Diarrhea', severity: 4, loggedAt: '09:00 AM, Jan 1, 2024'),
];

class HealthCondition {
  final int? id;
  final String name;
  final String loggedAt;

  const HealthCondition({
    this.id,
    required this.name,
    required this.loggedAt,
  });

  factory HealthCondition.fromJson(Map<String, dynamic> json) =>
      HealthCondition(
        id: json['id'] as int?,
        name: json['name'] as String,
        loggedAt: json['logged_at'] as String,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'logged_at': loggedAt,
      };

  HealthCondition copyWith({int? id, String? name, String? loggedAt}) =>
      HealthCondition(
        id: id ?? this.id,
        name: name ?? this.name,
        loggedAt: loggedAt ?? this.loggedAt,
      );
}

class HealthSymptom {
  final int? id;
  final String name;
  final int severity; // 0–10
  final String loggedAt;

  const HealthSymptom({
    this.id,
    required this.name,
    required this.severity,
    required this.loggedAt,
  });

  factory HealthSymptom.fromJson(Map<String, dynamic> json) => HealthSymptom(
        id: json['id'] as int?,
        // Backend field is `symptom_name`; tolerate legacy `name`.
        name: (json['symptom_name'] ?? json['name'] ?? '') as String,
        severity: json['severity'] as int? ?? 1,
        // Server stamps `logged_at` (ISO 8601); fall back to created_at.
        loggedAt: (json['logged_at'] ?? json['created_at'] ?? '') as String,
      );

  // Backend requires `symptom_name` and `severity` (1–10); `logged_at` is
  // optional and defaults to now server-side, so we omit it (the app only
  // ever logs "now", and sending a client clock risks a future-time 400).
  Map<String, dynamic> toJson() => {
        'symptom_name': name,
        'severity': severity.clamp(1, 10),
      };
}

double? _toDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v);
  return null;
}

int? _toInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v);
  return null;
}

/// A vital-signs reading — `GET/POST /health/vitals/`. All metrics optional.
class VitalLog {
  const VitalLog({
    this.id,
    this.systolicBp,
    this.diastolicBp,
    this.heartRate,
    this.temperatureC,
    this.oxygenSaturation,
    this.bloodGlucose,
    this.weightKg,
    this.steps,
    this.notes,
    this.measuredAt,
  });

  final int? id;
  final int? systolicBp;
  final int? diastolicBp;
  final int? heartRate;
  final double? temperatureC;
  final int? oxygenSaturation;
  final double? bloodGlucose;
  final double? weightKg;
  final int? steps;
  final String? notes;
  final DateTime? measuredAt;

  String? get bpDisplay => (systolicBp != null && diastolicBp != null)
      ? '$systolicBp/$diastolicBp'
      : null;

  factory VitalLog.fromJson(Map<String, dynamic> json) => VitalLog(
        id: _toInt(json['id']),
        systolicBp: _toInt(json['systolic_bp']),
        diastolicBp: _toInt(json['diastolic_bp']),
        heartRate: _toInt(json['heart_rate']),
        temperatureC: _toDouble(json['temperature_c']),
        oxygenSaturation: _toInt(json['oxygen_saturation']),
        bloodGlucose: _toDouble(json['blood_glucose']),
        weightKg: _toDouble(json['weight_kg']),
        steps: _toInt(json['steps']),
        notes: json['notes'] as String?,
        measuredAt: DateTime.tryParse(json['measured_at'] as String? ?? ''),
      );

  /// Create payload — only set fields are sent; `measured_at` is omitted so
  /// the server stamps "now".
  Map<String, dynamic> toJson() => {
        if (systolicBp != null) 'systolic_bp': systolicBp,
        if (diastolicBp != null) 'diastolic_bp': diastolicBp,
        if (heartRate != null) 'heart_rate': heartRate,
        if (temperatureC != null) 'temperature_c': temperatureC!.toString(),
        if (oxygenSaturation != null) 'oxygen_saturation': oxygenSaturation,
        if (bloodGlucose != null) 'blood_glucose': bloodGlucose!.toString(),
        if (weightKg != null) 'weight_kg': weightKg!.toString(),
        if (steps != null) 'steps': steps,
        if (notes != null && notes!.isNotEmpty) 'notes': notes,
      };
}

/// Valid `goal_type` values (matches backend enum).
const List<String> kHealthGoalTypes = [
  'sleep',
  'steps',
  'water',
  'weight',
  'calories',
  'blood_sugar',
  'blood_pressure',
  'custom',
];

String healthGoalTypeLabel(String type) {
  switch (type) {
    case 'blood_sugar':
      return 'Blood sugar';
    case 'blood_pressure':
      return 'Blood pressure';
    default:
      return type.isEmpty
          ? 'Goal'
          : '${type[0].toUpperCase()}${type.substring(1)}';
  }
}

/// A health goal — `GET/POST/PATCH/DELETE /health/goals/`.
class HealthGoal {
  const HealthGoal({
    this.id,
    required this.goalType,
    required this.targetValue,
    this.unit,
    this.description,
    this.isActive = true,
  });

  final int? id;
  final String goalType;
  final double targetValue;
  final String? unit;
  final String? description;
  final bool isActive;

  HealthGoal copyWith({
    String? goalType,
    double? targetValue,
    String? unit,
    String? description,
    bool? isActive,
  }) =>
      HealthGoal(
        id: id,
        goalType: goalType ?? this.goalType,
        targetValue: targetValue ?? this.targetValue,
        unit: unit ?? this.unit,
        description: description ?? this.description,
        isActive: isActive ?? this.isActive,
      );

  factory HealthGoal.fromJson(Map<String, dynamic> json) => HealthGoal(
        id: _toInt(json['id']),
        goalType: json['goal_type'] as String? ?? 'custom',
        targetValue: _toDouble(json['target_value']) ?? 0,
        unit: json['unit'] as String?,
        description: json['description'] as String?,
        isActive: json['is_active'] as bool? ?? true,
      );

  Map<String, dynamic> toJson() => {
        'goal_type': goalType,
        'target_value': targetValue.toString(),
        if (unit != null) 'unit': unit,
        if (description != null) 'description': description,
        'is_active': isActive,
      };
}

/// An AI-generated health summary — `GET /health/summaries/[latest/]`.
/// Read-only. `fromJson` returns null for the empty `{}` "no summary" body.
class HealthSummary {
  const HealthSummary({
    this.id,
    required this.summary,
    this.confidence,
    this.date,
  });

  final int? id;
  final String summary;
  final double? confidence;
  final String? date;

  static HealthSummary? fromJsonOrNull(Map<String, dynamic> json) {
    final text = json['summary'] as String?;
    if (text == null || text.isEmpty) return null;
    return HealthSummary(
      id: _toInt(json['id']),
      summary: text,
      confidence: _toDouble(json['confidence']),
      date: json['date'] as String?,
    );
  }

  factory HealthSummary.fromJson(Map<String, dynamic> json) => HealthSummary(
        id: _toInt(json['id']),
        summary: json['summary'] as String? ?? '',
        confidence: _toDouble(json['confidence']),
        date: json['date'] as String?,
      );
}

/// Aggregate overview — `GET /health/dashboard/`.
class HealthDashboard {
  const HealthDashboard({
    this.periodDays = 7,
    this.symptomTotal = 0,
    this.avgSymptomSeverity,
    this.vitalStats = const {},
    this.latestSummary,
    this.activeGoals = const [],
    this.recentSymptoms = const [],
  });

  final int periodDays;
  final int symptomTotal;
  final double? avgSymptomSeverity;

  /// Raw `vital_stats` map (avg_heart_rate, avg_systolic, latest_weight, …);
  /// values may be null when there are no readings.
  final Map<String, dynamic> vitalStats;
  final HealthSummary? latestSummary;
  final List<HealthGoal> activeGoals;
  final List<HealthSymptom> recentSymptoms;

  factory HealthDashboard.fromJson(Map<String, dynamic> json) {
    final symptomStats = (json['symptom_stats'] as Map?)?.cast<String, dynamic>() ?? const {};
    final latest = json['latest_summary'];
    final goals = json['active_goals'];
    final recent = json['recent_symptoms'];
    return HealthDashboard(
      periodDays: _toInt(json['period_days']) ?? 7,
      symptomTotal: _toInt(symptomStats['total']) ?? 0,
      avgSymptomSeverity: _toDouble(symptomStats['avg_severity']),
      vitalStats:
          (json['vital_stats'] as Map?)?.cast<String, dynamic>() ?? const {},
      latestSummary: latest is Map && latest['summary'] != null
          ? HealthSummary.fromJson(latest.cast<String, dynamic>())
          : null,
      activeGoals: goals is List
          ? goals
              .map((e) => HealthGoal.fromJson((e as Map).cast<String, dynamic>()))
              .toList()
          : const [],
      recentSymptoms: recent is List
          ? recent
              .map((e) =>
                  HealthSymptom.fromJson((e as Map).cast<String, dynamic>()))
              .toList()
          : const [],
    );
  }
}
