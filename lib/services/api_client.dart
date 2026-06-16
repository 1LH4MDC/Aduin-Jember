import 'dart:convert';

import 'package:aduin_jember/core/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// kelas ini dibikin buat bungkus request http biar gampang dipake berulang kali
class ApiClient {
  ApiClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  // key buat nyimpen token jwt di local storage perangkat
  static const String _tokenKey = 'auth_token';
  final http.Client _httpClient;

  String? _token;

  // getter buat ngambil token aktif sekarang
  String? get token => _token;

  // ambil token yang tersimpan di local storage pas aplikasi pertama kali dibuka
  Future<void> restoreToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }

  // nyimpen token baru ke local storage dan update variabel lokal _token
  Future<void> setToken(String? token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    if (token == null || token.isEmpty) {
      await prefs.remove(_tokenKey);
    } else {
      await prefs.setString(_tokenKey, token);
    }
  }

  // bersihin token dari memory dan local storage pas user logout
  Future<void> clearToken() => setToken(null);

  // bikin default header request http, dan selipin bearer token kalau request butuh otentikasi
  Map<String, String> _headers({bool authenticated = true}) {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (authenticated && _token != null && _token!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  // kirim request get ke api dan balikin data json hasil decode-nya
  Future<dynamic> getJson(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool authenticated = true,
  }) async {
    final response = await _httpClient.get(
      AppConfig.apiUri(path, queryParameters),
      headers: _headers(authenticated: authenticated),
    );
    return _decodeResponse(response);
  }

  // kirim request post dengan body json ke api
  Future<dynamic> postJson(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = false,
  }) async {
    final response = await _httpClient.post(
      AppConfig.apiUri(path),
      headers: _headers(authenticated: authenticated),
      body: jsonEncode(body ?? const <String, dynamic>{}),
    );
    return _decodeResponse(response);
  }

  // kirim request patch buat update sebagian data ke api
  Future<dynamic> patchJson(
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final response = await _httpClient.patch(
      AppConfig.apiUri(path),
      headers: _headers(authenticated: authenticated),
      body: jsonEncode(body ?? const <String, dynamic>{}),
    );
    return _decodeResponse(response);
  }

  // kirim request delete buat hapus data ke api
  Future<dynamic> deleteJson(String path, {bool authenticated = true}) async {
    final response = await _httpClient.delete(
      AppConfig.apiUri(path),
      headers: _headers(authenticated: authenticated),
    );
    return _decodeResponse(response);
  }

  // fungsi helper buat nerjemahin response mentah http ke format json atau map
  dynamic _decodeResponse(http.Response response) {
    final body = response.body.trim();
    // kalau status code ga di range sukses (200-299), langsung lempar error custom
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(
        message: _extractErrorMessage(body, response.statusCode),
        statusCode: response.statusCode,
        body: body,
      );
    }

    if (body.isEmpty) {
      return null;
    }

    try {
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  // helper buat nyari pesan error dari response body backend biar gampang dibaca user
  String _extractErrorMessage(String body, int statusCode) {
    if (body.isEmpty) {
      return 'Request gagal dengan status $statusCode';
    }

    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded['message']?.toString() ??
            decoded['error']?.toString() ??
            'Request gagal dengan status $statusCode';
      }
    } catch (_) {
      // ignore decode failure
    }

    return body;
  }
}

// kelas custom exception buat nampung error response khusus dari server api
class ApiException implements Exception {
  const ApiException({
    required this.message,
    required this.statusCode,
    required this.body,
  });

  final String message;
  final int statusCode;
  final String body;

  bool get isServerError => statusCode >= 500;

  @override
  String toString() => message;
}
