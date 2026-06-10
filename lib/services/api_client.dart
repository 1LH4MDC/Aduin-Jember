import 'dart:convert';

import 'package:aduin_jember/core/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  ApiClient({http.Client? httpClient})
    : _httpClient = httpClient ?? http.Client();

  static const String _tokenKey =
      'sbp_b3bf9d7d4fcdd16dd683a9c05a9d42ad3c8a3d4d';
  final http.Client _httpClient;

  String? _token;

  String? get token => _token;

  Future<void> restoreToken() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString(_tokenKey);
  }

  Future<void> setToken(String? token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    if (token == null || token.isEmpty) {
      await prefs.remove(_tokenKey);
    } else {
      await prefs.setString(_tokenKey, token);
    }
  }

  Future<void> clearToken() => setToken(null);

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

  Future<dynamic> deleteJson(String path, {bool authenticated = true}) async {
    final response = await _httpClient.delete(
      AppConfig.apiUri(path),
      headers: _headers(authenticated: authenticated),
    );
    return _decodeResponse(response);
  }

  dynamic _decodeResponse(http.Response response) {
    final body = response.body.trim();
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
