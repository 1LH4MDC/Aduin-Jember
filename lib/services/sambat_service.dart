import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_config.dart';
import 'api_client.dart';

// service ini ngatur semua transaksi laporan pengaduan masyarakat (sambat)
class SambatService {
  final ApiClient _apiClient;

  SambatService({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // ngambil daftar aduan milik user tertentu (daring filter berdasarkan user id)
  Future<List<Map<String, dynamic>>> fetchMySambat(String userId) async {
    final sambat = await fetchSambat();
    return sambat.where((item) => _sambatOwnerId(item) == userId).toList();
  }

  // ngambil semua aduan yang ada dengan parameter pencarian, status, atau kategori
  Future<List<Map<String, dynamic>>> fetchAllSambat({
    String? status,
    String? category,
    String? search,
  }) async {
    final queryParameters = <String, dynamic>{};
    if (status != null && status.isNotEmpty) {
      queryParameters['status'] = status;
    }
    if (category != null && category.isNotEmpty) {
      queryParameters['kategori'] = category;
    }
    if (search != null && search.isNotEmpty) {
      queryParameters['search'] = search;
    }

    return fetchSambat(
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
  }

  // request get ke endpoint /api/sambat
  Future<List<Map<String, dynamic>>> fetchSambat({
    Map<String, dynamic>? queryParameters,
  }) async {
    final response = await _apiClient.getJson(
      '/api/sambat',
      queryParameters: queryParameters,
    );
    return _toMapList(_readDataList(response));
  }

  // bikin laporan aduan baru. alurnya: upload foto ke supabase dulu baru kirim data teks + url foto ke backend
  Future<Map<String, dynamic>> createSambat({
    required String title,
    required String category,
    required String description,
    required Uint8List imageBytes,
    required String imageName,
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    // 1. upload gambar ke supabase storage dan dapetin public url-nya
    final publicUrl = await _uploadImageToSupabase(
      imageBytes: imageBytes,
      imageName: imageName,
    );

    // 2. kirim payload data lengkap ke server backend
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

  // update status aduan (misal dari pending jadi proses/selesai) dan selipin catatan admin jika ada
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

  // fungsi helper internal buat nge-upload file gambar biner ke bucket supabase 'foto-laporan'
  Future<String> _uploadImageToSupabase({
    required Uint8List imageBytes,
    required String imageName,
  }) async {
    if (!AppConfig.hasSupabaseConfig) {
      throw Exception(
        'Konfigurasi Supabase belum diset. Isi SUPABASE_URL dan SUPABASE_ANON_KEY.',
      );
    }

    // bersihin nama file biar ga ada karakter aneh
    final safeName = imageName.trim().isEmpty
        ? 'sambat.jpg'
        : imageName.trim().replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
    final objectPath = 'sambat/${DateTime.now().millisecondsSinceEpoch}_$safeName';
    
    // upload ke bucket supabase
    final storage = Supabase.instance.client.storage.from(
      AppConfig.sambatBucketName,
    );

    await storage.uploadBinary(objectPath, imageBytes);
    return storage.getPublicUrl(objectPath);
  }

  // helper konversi list map dinamis
  List<Map<String, dynamic>> _toMapList(dynamic data) {
    final list = (data as List).cast<dynamic>();
    return list.map((item) => Map<String, dynamic>.from(item as Map)).toList();
  }

  // helper baca data list dari response
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

  // helper baca data map dari response
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

  // nyari id pemilik laporan dengan berbagai variasi penamaan key json
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
