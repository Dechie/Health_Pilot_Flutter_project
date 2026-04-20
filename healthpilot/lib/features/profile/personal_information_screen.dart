// Deprecated path shim: this screen still lives under onboarding for now.
// Branch B will migrate/merge it into the profile feature; keep this wrapper so
// profile UI can depend on `features/profile/` and we can change the underlying
// implementation without updating every import.
export 'package:healthpilot/features/onboarding/personal_information_screen.dart'
    show PersonalInformationScreen;

