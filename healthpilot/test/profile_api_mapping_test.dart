import 'package:flutter_test/flutter_test.dart';
import 'package:healthpilot/features/profile/user_profile.dart';

void main() {
  group('profile API field mapping', () {
    test('genderToApi maps UI labels to M/F', () {
      expect(genderToApi('male'), 'M');
      expect(genderToApi('female'), 'F');
      expect(genderToApi(null), isNull);
      expect(genderToApi('other'), isNull);
    });

    test('yesNoToYn maps radio answers to Y/N', () {
      expect(yesNoToYn('Yes'), 'Y');
      expect(yesNoToYn('No'), 'N');
      expect(yesNoToYn('I don\'t know'), isNull);
      expect(yesNoToYn(''), isNull);
    });

    test('dateOfBirthFromAge returns ISO date string', () {
      final age = DateTime.now().year - 1990;
      expect(dateOfBirthFromAge(age), '1990-01-01');
    });

    test('toAuthUpdateJson includes onboarding fields', () {
      final profile = UserProfile(
        gender: 'M',
        dateOfBirth: DateTime(1990, 5, 15),
        heightCm: 175,
        weightKg: 75,
        hasHypertension: 'Y',
        hasChronicCondition: 'N',
        bloodType: 'A+',
        allergies: 'penicillin, peanuts',
      );

      expect(profile.toAuthUpdateJson(), {
        'gender': 'M',
        'date_of_birth': '1990-05-15',
        'height_cm': 175,
        'weight_kg': 75,
        'has_hypertension': 'Y',
        'has_chronic_condition': 'N',
        'blood_type': 'A+',
        'allergies': 'penicillin, peanuts',
      });
    });

    test('fromAuthJson parses computed and stored fields', () {
      final profile = UserProfile.fromAuthJson({
        'id': 1,
        'gender': 'F',
        'date_of_birth': '1990-05-15',
        'age': 35,
        'height_cm': 170,
        'weight_kg': 65,
        'has_diabetes': 'N',
      });

      expect(profile.gender, 'F');
      expect(profile.dateOfBirth, DateTime(1990, 5, 15));
      expect(profile.age, 35);
      expect(profile.hasDiabetes, 'N');
    });
  });
}
