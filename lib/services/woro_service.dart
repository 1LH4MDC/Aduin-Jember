import 'api_client.dart';

class WoroService {
  final ApiClient _apiClient;

  WoroService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<Map<String, dynamic>>> fetchWoro() async {
    final response = await _apiClient.getJson('/api/woro-woro', authenticated: false);
    return _toMapList(_readDataList(response));
  }

  Future<Map<String, dynamic>> createWoro({
    required String judul,
    required String konten,
    required String kategori,
  }) async {
    final response = await _apiClient.postJson(
      '/api/woro-woro',
      authenticated: true,
      body: {
        'judul': judul,
        'konten': konten,
        'kategori': kategori,
      },
    );
    return _readDataMap(response);
  }

  Future<Map<String, dynamic>> updateWoro(
    String idWoro, {
    required String judul,
    required String konten,
    required String kategori,
  }) async {
    final response = await _apiClient.patchJson(
      '/api/woro-woro/$idWoro',
      authenticated: true,
      body: {
        'judul': judul,
        'konten': konten,
        'kategori': kategori,
      },
    );
    return _readDataMap(response);
  }

  Future<void> deleteWoro(String idWoro) async {
    await _apiClient.deleteJson('/api/woro-woro/$idWoro', authenticated: true);
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
