import 'package:flutter/foundation.dart';

import 'api_client.dart';

class AuthController extends ChangeNotifier {
  AuthController({ApiClient? apiClient})
    : apiClient = apiClient ?? ApiClient() {
    _bootstrap();
  }

  final ApiClient apiClient;

  Map<String, dynamic>? profile;
  bool isLoading = true;
  bool isBusy = false;
  String? errorMessage;

  bool get isAuthenticated =>
      apiClient.token != null && apiClient.token!.isNotEmpty;

  bool get isAdmin {
    final value =
        profile?['is_admin'] ?? profile?['isAdmin'] ?? profile?['role'];
    if (value is bool) {
      return value;
    }
    return value?.toString().toLowerCase() == 'admin';
  }

  String get displayName {
    final candidates = [
      profile?['nama'],
      profile?['full_name'],
      profile?['name'],
    ];

    for (final candidate in candidates) {
      if (candidate is String && candidate.trim().isNotEmpty) {
        return candidate.trim();
      }
    }

    final email = profile?['email']?.toString() ?? '';
    if (email.contains('@')) {
      return email.split('@').first;
    }

    return 'Pengguna';
  }

  String get email => (profile?['email'] ?? '').toString();

  String get userId =>
      (profile?['idUser'] ?? profile?['id'] ?? profile?['user_id'] ?? '')
          .toString();

  Future<void> _bootstrap() async {
    isLoading = true;
    notifyListeners();

    try {
      await apiClient.restoreToken();
      if (apiClient.token == null || apiClient.token!.isEmpty) {
        profile = null;
        return;
      }

      await loadProfile();
    } catch (error) {
      errorMessage = error.toString();
      profile = null;
      await apiClient.clearToken();
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadProfile() async {
    final response = await apiClient.getJson('/api/profil');
    profile = _extractDataMap(response);
  }

  Future<void> updateProfile({
    required String nama,
    required String nik,
    String? fotoProfil,
  }) async {
    isBusy = true;
    errorMessage = null;
    notifyListeners();

    try {
      await apiClient.patchJson(
        '/api/profil',
        authenticated: true,
        body: {
          'nama': nama.trim(),
          'nik': nik.trim(),
          if (fotoProfil != null) 'fotoProfil': fotoProfil,
        },
      );
      await loadProfile();
    } catch (error) {
      errorMessage = error.toString();
      rethrow;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    isBusy = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await apiClient.postJson(
        '/api/auth/login',
        authenticated: false,
        body: {'email': email.trim(), 'password': password},
      );

      final data = _extractDataMap(response);
      final token = _readToken(data);
      if (token == null || token.isEmpty) {
        throw Exception('Token login tidak ditemukan pada response.');
      }

      await apiClient.setToken(token);
      profile = _readProfile(data);
      if (profile == null) {
        await loadProfile();
      }
    } catch (error) {
      errorMessage = error.toString();
      rethrow;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> signUp({
    required String fullName,
    required String email,
    required String nik,
    required String password,
  }) async {
    isBusy = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await apiClient.postJson(
        '/api/auth/register',
        authenticated: false,
        body: {
          'email': email.trim(),
          'password': password,
          'nama': fullName.trim(),
          'nik': nik.trim(),
        },
      );

      final data = _extractDataMap(response);
      final token = _readToken(data);
      if (token != null && token.isNotEmpty) {
        await apiClient.setToken(token);
      }

      profile =
          _readProfile(data) ??
          {'nama': fullName.trim(), 'email': email.trim(), 'nik': nik.trim()};
    } catch (error) {
      errorMessage = error.toString();
      rethrow;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    isBusy = true;
    notifyListeners();

    try {
      await apiClient.clearToken();
      profile = null;
    } finally {
      isBusy = false;
      isLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> _extractDataMap(dynamic response) {
    if (response is Map<String, dynamic>) {
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        return data;
      }
      return response;
    }

    return <String, dynamic>{};
  }

  String? _readToken(Map<String, dynamic> data) {
    final tokenCandidates = [
      data['accessToken'],
      data['access_token'],
      data['token'],
      data['jwt'],
    ];

    for (final candidate in tokenCandidates) {
      final token = candidate?.toString();
      if (token != null && token.isNotEmpty) {
        return token;
      }
    }

    return null;
  }

  Map<String, dynamic>? _readProfile(Map<String, dynamic> data) {
    final candidates = [data['profile'], data['profil'], data['user'], data];

    for (final candidate in candidates) {
      Map<String, dynamic>? profileMap;
      if (candidate is Map<String, dynamic>) {
        profileMap = Map<String, dynamic>.from(candidate);
      } else if (candidate is Map) {
        profileMap = Map<String, dynamic>.from(candidate);
      }

      if (profileMap != null) {
        // Menyisipkan field role/admin dari data luar ke profil jika belum ada
        if (data['role'] != null && !profileMap.containsKey('role')) {
          profileMap['role'] = data['role'];
        }
        if (data['is_admin'] != null && !profileMap.containsKey('is_admin')) {
          profileMap['is_admin'] = data['is_admin'];
        }
        if (data['isAdmin'] != null && !profileMap.containsKey('isAdmin')) {
          profileMap['isAdmin'] = data['isAdmin'];
        }
        return profileMap;
      }
    }

    return null;
  }
}
