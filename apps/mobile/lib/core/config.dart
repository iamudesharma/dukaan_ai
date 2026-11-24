abstract final class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'DUKAAN_API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1/',
  );

  static String normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    return trimmed.endsWith('/') ? trimmed : '$trimmed/';
  }
}
