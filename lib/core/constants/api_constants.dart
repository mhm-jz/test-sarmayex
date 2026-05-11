class ApiConstants {
  static const String baseUrl = 'https://core.sarmayex.com';

  static Uri marketSubscribeUri(String market) {
    return Uri.parse('$baseUrl/api/v1/markets/$market/subscribe');
  }
}
