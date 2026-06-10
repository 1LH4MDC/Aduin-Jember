import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../core/app_config.dart';
import 'api_client.dart';

class SambatService {
  final ApiClient _apiClient;

  SambatService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  Future<List<Map<String, dynamic>>> fetchMySambat(String userId) async {
    final sambat = await fetchSambat();
    return sambat.where((item) => _sambatOwnerId(item) == userId).toList();
  }

  Future<List<Map<String, dynamic>>> fetchAllSambat({
    String? status,
    String? category,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (status != null && status.isNotEmpty) {
      queryParameters['status'] = status;
    }
    if (category != null && category.isNotEmpty) {
      queryParameters['kategori'] = category;
    }

    return fetchSambat(
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
  }

  Future<List<Map<String, dynamic>>> fetchSambat({
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _apiClient.getJson(
      '/api/sambat',
      queryParameters: queryParameters,
    );
    return _toMapList(_readDataList(response));
  }

  Future<Map<String, dynamic>> createSambat({
    required String title,
    required String category,
    required String description,
    required File imageFile,
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    final publicUrl = await _createWatermarkedUrl(imageFile);
    final response = await _apiClient.postJson(
      '/api/sambat',
      authenticated: true,
      body: {
        'judul': title,
        'deskripsi': description,
        'fotoUrl': publicUrl,
        'latitude': latitude,
        'longitude': longitude,
        'alamatLengkap': address,
        'kategori': category,
      },
    );
    return _readDataMap(response);
  }

  Future<void> updateStatus({
    required String sambatId,
    required String status,
    String? catatan,
  }) async {
    await _apiClient.patchJson(
      '/api/sambat/$sambatId/status',
      body: {
        'status': status,
        if (catatan != null && catatan.isNotEmpty) 'catatan': catatan,
      },
    );
  }

  Future<String> _createWatermarkedUrl(File sourceFile) async {
    final request = http.MultipartRequest('POST', AppConfig.watermarkUri)
      ..files.add(await http.MultipartFile.fromPath('image', sourceFile.path))
      ..fields['watermark_text'] = AppConfig.defaultWatermarkText
      ..fields['text'] = AppConfig.defaultWatermarkText;

    final token = _apiClient.token;
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    final response = await request.send();
    final bytes = await response.stream.toBytes();

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('Watermark gagal: ${utf8.decode(bytes)}');
    }

    final body = utf8.decode(bytes).trim();
    if (body.startsWith('http')) {
      return body;
    }

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      final data = decoded['data'];
      final nestedMap = data is Map<String, dynamic>
          ? data
          : data is Map
          ? Map<String, dynamic>.from(data)
          : <String, dynamic>{};

      final urlValue =
          decoded['fotoUrl'] ??
          decoded['watermarked_url'] ??
          decoded['image_url'] ??
          decoded['url'] ??
          decoded['resultUrl'] ??
          nestedMap['fotoUrl'] ??
          nestedMap['watermarked_url'] ??
          nestedMap['image_url'] ??
          nestedMap['url'] ??
          nestedMap['resultUrl'];
      if (urlValue is String && urlValue.isNotEmpty) {
        return urlValue;
      }
    }

    throw Exception('Respons watermark tidak dikenali.');
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

  String _sambatOwnerId(Map<String, dynamic> sambat) {
    final candidates = [
      sambat['idUser'],
      sambat['user_id'],
      sambat['iduser'],
      sambat['userId'],
    ];

    for (final candidate in candidates) {
      final value = candidate?.toString();
      if (value != null && value.isNotEmpty) {
        return value;
      }
    }

    return '';
  }
}
