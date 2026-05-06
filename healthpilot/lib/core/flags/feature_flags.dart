abstract final class FeatureFlags {
  static const bool auth          = bool.fromEnvironment('FF_AUTH',          defaultValue: false);
  static const bool userProfile   = bool.fromEnvironment('FF_PROFILE',       defaultValue: false);
  static const bool articles      = bool.fromEnvironment('FF_ARTICLES',      defaultValue: false);
  static const bool medications   = bool.fromEnvironment('FF_MEDICATIONS',   defaultValue: false);
  static const bool assessment    = bool.fromEnvironment('FF_ASSESSMENT',    defaultValue: false);
  static const bool contacts      = bool.fromEnvironment('FF_CONTACTS',      defaultValue: false);
  static const bool healthData    = bool.fromEnvironment('FF_HEALTH_DATA',   defaultValue: false);
  static const bool chat          = bool.fromEnvironment('FF_CHAT',          defaultValue: false);
  static const bool aiAssistant   = bool.fromEnvironment('FF_AI_ASSISTANT',  defaultValue: false);
  static const bool community     = bool.fromEnvironment('FF_COMMUNITY',     defaultValue: false);
  static const bool nutrition     = bool.fromEnvironment('FF_NUTRITION',     defaultValue: false);
  static const bool notifications = bool.fromEnvironment('FF_NOTIFICATIONS', defaultValue: false);
  static const bool subscriptions = bool.fromEnvironment('FF_SUBSCRIPTIONS', defaultValue: false);
}
