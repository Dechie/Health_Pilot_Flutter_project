abstract final class ApiConstants {
  static const String authBase = '/api/v1/auth';
  static const String profileBase = '/api/v1/profile';
  static const String articlesBase = '/api/v1/articles';
  static const String contactsBase = '/api/v1/contacts';
  static const String medicationsBase = '/api/v1/medications';
  static const String assessmentsBase = '/api/v1/assessments';
  static const String healthBase = '/api/v1/health';
  static const String chatBase = '/api/v1/chat';
  static const String communityBase = '/api/v1/community';
  static const String nutritionBase = '/api/v1/nutrition';
  static const String notificationsBase = '/api/v1/notifications';
  static const String subscriptionsBase = '/api/v1/subscriptions';
  static const String adsBase = '/api/v1/ads';

  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
