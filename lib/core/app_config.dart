// buat nyimpen semua konfigurasi url api dan supabase
class AppConfig {
  // url dasar backend api yang dideploy di railway
  static const String railwayBaseUrl = String.fromEnvironment(
    'RAILWAY_BASE_URL',
    defaultValue: 'https://aduinjember-production.up.railway.app',
  );

  // url project supabase buat nyimpen berkas/foto
  static const String supabaseUrl = String.fromEnvironment(
    'SUPABASE_URL',
    defaultValue: 'https://ulztiyvuezhupmkcbczx.supabase.co',
  );

  // anon key supabase buat otentikasi client storage
  static const String supabaseAnonKey = String.fromEnvironment(
    'SUPABASE_ANON_KEY',
    defaultValue: 'sb_publishable_mUr1kT1jZJ0uaKU2FfHTOg_xhSCFzzN',
  );

  // nama bucket di supabase khusus buat nyimpen foto laporan pengaduan
  static const String sambatBucketName = 'foto-laporan';

  // helper buat ngecek apa settingan supabase udah lengkap terisi atau belum
  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  // fungsi pembantu buat nyusun uri request api lengkap dengan query parameters-nya
  static Uri apiUri(String path, [Map<String, dynamic>? queryParameters]) {
    // bersihin slash di akhir baseUrl biar ga dobel slash pas digabungin
    final normalizedBase = railwayBaseUrl.endsWith('/')
        ? railwayBaseUrl.substring(0, railwayBaseUrl.length - 1)
        : railwayBaseUrl;
    // bersihin slash di awal path biar seragam
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    // gabungin baseurl sama path dan selipin query params jika ada
    return Uri.parse('$normalizedBase$normalizedPath').replace(
      queryParameters: queryParameters?.map(
        (key, value) => MapEntry(key, value.toString()),
      ),
    );
  }
}
