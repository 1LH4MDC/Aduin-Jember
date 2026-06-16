import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/app_config.dart';
import 'api_client.dart';

// kelas ini ngatur state autentikasi user, profil, login, register, dan upload foto profil
class AuthController extends ChangeNotifier {
  AuthController({ApiClient? apiClient})
    : apiClient = apiClient ?? ApiClient() {
    // pas pertama kali dibuat, langsung jalanin bootstrap buat ngecek token lama
    _bootstrap();
  }

  final ApiClient apiClient;

  // nyimpen data profil user berupa map key-value
  Map<String, dynamic>? profile;
  // buat nandain apa aplikasi lagi nyari status login atau loading di awal
  bool isLoading = true;
  // buat nandain apa ada proses request api yang lagi jalan (biar tombol ga bisa diclick dobel)
  bool isBusy = false;
  // buat nyimpen pesan error kalau request gagal
  String? errorMessage;

  // helper buat ngecek apa user udah login (punya token)
  bool get isAuthenticated =>
      apiClient.token != null && apiClient.token!.isNotEmpty;

  // helper buat ngecek apa user login sebagai admin
  bool get isAdmin {
    final value =
        profile?['is_admin'] ?? profile?['isAdmin'] ?? profile?['role'];
    if (value is bool) {
      return value;
    }
    return value?.toString().toLowerCase() == 'admin';
  }

  // helper buat ngambil nama tampilan user dengan berbagai fallback field
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

  // ambil email user
  String get email => (profile?['email'] ?? '').toString();

  // ambil id user unik
  String get userId =>
      (profile?['idUser'] ?? profile?['id'] ?? profile?['user_id'] ?? '')
          .toString();

  // fungsi bootstrap buat ngembaliin session lama pas app baru dibuka
  Future<void> _bootstrap() async {
    isLoading = true;
    notifyListeners();

    try {
      // coba ambil token lama dari shared preferences
      await apiClient.restoreToken();
      if (apiClient.token == null || apiClient.token!.isEmpty) {
        profile = null;
        return;
      }

      // kalau tokennya ada, langsung load profile terbarunya
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

  // ambil profil detail user dari backend
  Future<void> loadProfile() async {
    final response = await apiClient.getJson('/api/profil');
    final data = _extractDataMap(response);
    profile = _readProfile(data) ?? data;
  }

  // update nama dan nik ke database backend
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
          'fotoProfil': fotoProfil,
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

  // upload foto baru ke supabase storage bucket 'foto-profil' terus update url-nya ke backend
  Future<String> uploadProfilePhoto({
    required Uint8List imageBytes,
    required String imageName,
  }) async {
    if (!AppConfig.hasSupabaseConfig) {
      throw Exception(
        'Konfigurasi Supabase belum diset. Isi SUPABASE_URL dan SUPABASE_ANON_KEY.',
      );
    }

    isBusy = true;
    notifyListeners();

    try {
      // 1. bikin path object unik di supabase storage
      final safeName = imageName.trim().isEmpty
          ? 'profil.jpg'
          : imageName.trim().replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
      final objectPath =
          'profil/${DateTime.now().millisecondsSinceEpoch}_$safeName';
      final storage = Supabase.instance.client.storage.from('foto-profil');

      // 2. upload data binary gambar
      await storage.uploadBinary(objectPath, imageBytes);
      final publicUrl = storage.getPublicUrl(objectPath);

      // 3. simpan url foto ke backend via patch
      await apiClient.patchJson(
        '/api/profil',
        authenticated: true,
        body: {'fotoProfil': publicUrl},
      );

      // reload profil terbaru
      await loadProfile();

      return publicUrl;
    } catch (error) {
      errorMessage = error.toString();
      rethrow;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  // fungsi buat login pake email dan password
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

      // simpan token ke local storage
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

  // fungsi buat daftar akun baru
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

  // fungsi buat logout (bersihin data profil dan token dari memori & storage)
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

  // ekstraksi map data dari response api biar seragam
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

  // nyari token di response backend dengan berbagai opsi key
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

  // nyari map profil di response backend dengan berbagai opsi key
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
        // selipin data role/admin dari response luar ke map profile
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
