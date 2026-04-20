/// Same catalog as onboarding allergies (`initial_info_3.dart`) for consistent suggestions.
abstract final class AllergySuggestionCatalog {
  static const List<String> names = [
    "Pollen Allergy (Hay Fever)",
    "Dust Mite Allergy",
    "Pet Allergy (Cats)",
    "Pet Allergy (Dogs)",
    "Food Allergy (Peanuts)",
    "Food Allergy (Tree nuts)",
    "Food Allergy (Milk)",
    "Food Allergy (Eggs)",
    "Food Allergy (Wheat)",
    "Food Allergy (Soy)",
    "Food Allergy (Fish)",
    "Food Allergy (Shellfish)",
    "Insect Sting Allergy (Bee stings)",
    "Insect Sting Allergy (Wasp stings)",
    "Insect Sting Allergy (Hornet stings)",
    "Insect Sting Allergy (Fire ant stings)",
    "Latex Allergy",
    "Medication Allergy (Penicillin)",
    "Medication Allergy (NSAIDs)",
    "Medication Allergy (Aspirin)",
    "Medication Allergy (Chemotherapy drugs)",
    "Mold Allergy",
    "Cosmetic and Skin Allergies (Fragrances)",
    "Cosmetic and Skin Allergies (Skin creams and lotions)",
    "Anaphylaxis Trigger (Severe peanut allergies)",
    "Environmental Allergies (Dust)",
    "Environmental Allergies (Mold)",
    "Environmental Allergies (Pollen)",
    "Environmental Allergies (Animal dander)",
    "Cold Weather Allergy (Cold urticaria)",
    "Sun Allergy (Photosensitivity)",
  ];

  static List<String> matching(String query, {int limit = 20}) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return names
        .where((e) => e.toLowerCase().contains(q))
        .take(limit)
        .toList();
  }
}
