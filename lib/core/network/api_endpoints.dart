class ApiEndpoints {
  ApiEndpoints._();

  // Base
  static const String baseUrl = 'https://84.247.136.165';

  // Auth
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';

  // User
  static const String user = '/user';
  static const String userProfile = '/user/profile';

  // Add more endpoints as needed
}
