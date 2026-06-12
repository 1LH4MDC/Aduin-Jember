import 'api_client.dart';

class GawatService {
  final ApiClient _apiClient;

  GawatService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<Map<String, dynamic>> sendSOS({
    required String jenisDarurat,
    required double latitude,
    required double longitude,
  }) async {
    final response = await _apiClient.postJson(
      '/api/gawat',
      authenticated: true,
      body: {
        'jenisDarurat': jenisDarurat,
        'latitude': latitude,
        'longitude': longitude,
      },
    );
    return _readDataMap(response);
  }

  Future<List<Map<String, dynamic>>> fetchGawat() async {
    final response = await _apiClient.getJson('/api/gawat', authenticated: true);
    return _toMapList(_readDataList(response));
  }

  Future<void> updateStatus({
    required String gawatId,
    required String status,
  }) async {
    await _apiClient.patchJson(
      '/api/gawat/$gawatId/status',
      authenticated: true,
      body: {
        'status': status,
      },
    );
  }

  List<Map<String, dynamic>> _toMapList(dynamic data) {
    final list = (data as List).cast<dynamic>();
    return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  List<dynamic> _readDataList(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is List<dynamic>) {
        return data;
      }
      if (data is Map<String, dynamic>) {
        return [data];
      }
    }

    if (response is List<dynamic>) {
      return response;
    }

    return <dynamic>[];
  }

  Map<String, dynamic> _readDataMap(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return response;
    }
    return <String, dynamic>{};
  }
}
