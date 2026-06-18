import 'package:flutter_test/flutter_test.dart';
import 'package:healthpilot/features/health_assessment/health_assessment_models.dart';
import 'package:healthpilot/features/health_assessment/health_assessment_subject.dart';

void main() {
  group('AssessmentSummary.toApiJson', () {
    test('matches backend POST schema', () {
      const summary = AssessmentSummary(
        subject: HealthAssessmentSubject.myself,
        bloodType: BloodType.a,
        allergies: 'penicillin',
        symptoms: ['Headache', 'Fever', 'Fatigue'],
        symptomDuration: '3 days',
        hasOtherSymptoms: false,
        symptomsTrend: 'worse',
      );

      expect(summary.toApiJson(), {
        'subject': 'myself',
        'blood_type': 'A',
        'allergies': 'penicillin',
        'symptoms': ['Headache', 'Fever', 'Fatigue'],
        'symptom_duration': '3 days',
        'has_other_symptoms': false,
        'symptoms_trend': 'getting worse',
      });
    });

    test('maps someone else subject and blood type variants', () {
      const summary = AssessmentSummary(
        subject: HealthAssessmentSubject.someoneElse,
        bloodType: BloodType.ab,
        allergies: '',
        symptoms: ['Cough'],
        symptomDuration: 'Less than a week',
        hasOtherSymptoms: true,
        symptomsTrend: 'no_change',
      );

      expect(summary.toApiJson()['subject'], 'someone_else');
      expect(summary.toApiJson()['blood_type'], 'AB');
      expect(summary.toApiJson()['symptoms_trend'], 'no change');
    });
  });

  group('AssessmentSummary.fromApiJson', () {
    test('parses list item with string symptoms', () {
      final summary = AssessmentSummary.fromApiJson({
        'for_whom': 'myself',
        'symptoms': 'Headache, Fever',
        'severity': 6,
        'status': 'failed',
        'created_at': '2026-06-07T16:16:35.024809Z',
      });

      expect(summary.subject, HealthAssessmentSubject.myself);
      expect(summary.symptoms, ['Headache', 'Fever']);
    });

    test('parses detail with wizard fields and additional_notes', () {
      final summary = AssessmentSummary.fromApiJson({
        'for_whom': 'myself',
        'symptoms': 'Headache, Fever',
        'symptom_duration': 'Less than a week',
        'blood_type': 'a',
        'allergies': 'peanuts',
        'additional_notes':
            'Patient reports additional symptoms not listed.\nSymptoms trend: worse',
      });

      expect(summary.bloodType, BloodType.a);
      expect(summary.allergies, 'peanuts');
      expect(summary.symptomDuration, 'Less than a week');
      expect(summary.hasOtherSymptoms, isTrue);
      expect(summary.symptomsTrend, 'worse');
    });
  });

  group('CompletedAssessmentEntry.fromApiJson', () {
    test('parses backend detail response', () {
      final entry = CompletedAssessmentEntry.fromApiJson({
        'id': 'e75b2b2d-93f1-40c6-b532-6df87bfd2919',
        'for_whom': 'myself',
        'symptoms': 'Headache, Fever',
        'severity': 5,
        'status': 'failed',
        'result': null,
        'created_at': '2026-06-07T16:16:36.048829Z',
      });

      expect(entry.id, 'e75b2b2d-93f1-40c6-b532-6df87bfd2919');
      expect(entry.status, 'failed');
      expect(entry.result, isNull);
      expect(entry.isAiPendingOrFailed, isTrue);
      expect(entry.summary.symptoms, ['Headache', 'Fever']);
    });

    test('parses AI result payload', () {
      final entry = CompletedAssessmentEntry.fromApiJson({
        'id': 'abc',
        'for_whom': 'myself',
        'symptoms': 'Headache',
        'status': 'completed',
        'created_at': '2026-06-07T16:16:36.048829Z',
        'result': {
          'possible_causes': [
            {'name': 'Tension headache', 'urgency': 'low'},
          ],
          'general_advice': 'Rest and hydrate.',
          'seek_emergency_care': false,
        },
      });

      expect(entry.result?.possibleCauses.single.name, 'Tension headache');
      expect(entry.result?.generalAdvice, 'Rest and hydrate.');
      expect(entry.isAiPendingOrFailed, isFalse);
    });

    test('parses backend condition fields from POST response', () {
      final entry = CompletedAssessmentEntry.fromApiJson({
        'id': '8ba2c0aa-2816-41e1-ab14-b31e883e8cf0',
        'for_whom': 'myself',
        'symptoms': 'Headache, Fever, Fatigue',
        'symptom_duration': '3 days',
        'blood_type': 'A+',
        'allergies': 'penicillin',
        'status': 'completed',
        'result': {
          'possible_causes': [
            {
              'rank': 1,
              'urgency': 'medium',
              'condition': 'Influenza (Flu)',
              'likelihood': 'High',
              'next_steps':
                  'Rest, drink fluids, monitor temperature',
              'description':
                  'Viral infection causing fever, headache, and fatigue',
            },
          ],
        },
      });

      final cause = entry.result!.possibleCauses.single;
      expect(entry.summary.bloodType, BloodType.a);
      expect(entry.summary.symptomsTrend, isNull);
      expect(cause.name, 'Influenza (Flu)');
      expect(cause.likelihood, 'High');
      expect(cause.nextSteps, contains('Rest'));
      expect(entry.isAiPendingOrFailed, isFalse);
    });
  });

  group('AssessmentSummary.looselyMatches', () {
    test('matches same symptoms regardless of order', () {
      const a = AssessmentSummary(
        subject: HealthAssessmentSubject.myself,
        bloodType: BloodType.a,
        allergies: '',
        symptoms: ['Fever', 'Headache'],
        symptomDuration: null,
        hasOtherSymptoms: null,
        symptomsTrend: null,
      );
      const b = AssessmentSummary(
        subject: HealthAssessmentSubject.myself,
        bloodType: null,
        allergies: '',
        symptoms: ['Headache', 'Fever'],
        symptomDuration: null,
        hasOtherSymptoms: null,
        symptomsTrend: null,
      );

      expect(a.looselyMatches(b), isTrue);
    });
  });
}
