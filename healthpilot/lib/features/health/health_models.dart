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
        name: json['name'] as String,
        severity: json['severity'] as int,
        loggedAt: json['logged_at'] as String,
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'severity': severity,
        'logged_at': loggedAt,
      };
}
