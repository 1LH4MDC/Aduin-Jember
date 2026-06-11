class AppConfig {
  static const String railwayBaseUrl = String.fromEnvironment(
    'RAILWAY_BASE_URL',
    defaultValue: 'https://aduinjember-production.up.railway.app',
  );

  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ulztiyvuezhupmkcbczx.supabase.co',
  );

  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_mUr1kT1jZJ0uaKU2FfHTOg_xhSCFzzN',
  );

  static const String sambatBucketName = 'foto-laporan';

  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

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
