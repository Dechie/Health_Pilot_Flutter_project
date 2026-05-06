enum AppEnvironment { dev, prod }

abstract final class AppEnv {
  static const String baseUrl = String.fromEnvironment(
    'APP_BASE_URL',
    defaultValue: 'http://10.0.2.2:9000',
  );

  static AppEnvironment get environment {
    const raw = String.fromEnvironment('APP_ENV', defaultValue: 'dev');
    return raw == 'prod' ? AppEnvironment.prod : AppEnvironment.dev;
  }
}
