class AppConfig {
  static const String railwayBaseUrl = String.fromEnvironment(
    'RAILWAY_BASE_URL',
    defaultValue: 'https://aduinjember-production.up.railway.app',
  );

  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: '',
  );

  static const String sambatBucketName = 'report-images';
  static const String defaultWatermarkText = 'Aduin Jember';

  static bool get hasGoogleMapsConfig => googleMapsApiKey.isNotEmpty;

  static Uri get watermarkUri => Uri.parse('$railwayBaseUrl/watermark');

  static Uri apiUri(String path, [Map<String, dynamic>? queryParameters]) {
    final normalizedBase = railwayBaseUrl.endsWith('/')
        ? railwayBaseUrl.substring(0, railwayBaseUrl.length - 1)
        : railwayBaseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath').replace(
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }
}
