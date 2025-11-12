class ApiEndpoints {
  ApiEndpoints._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    // defaultValue: 'http://10.0.2.2:3000/api',
    defaultValue: 'http://localhost:3000/api',
  );

  static const String login = '/user/account/login';
  static const String register = '/user/account/register';
}

