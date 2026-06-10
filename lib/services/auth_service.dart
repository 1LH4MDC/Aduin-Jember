import 'dart:convert';
import 'package:flutter/foundation.dart'; // Tambahkan import ini untuk debugPrint
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class AuthService {
  // Fungsi untuk Register
  static Future<bool> registerUser({
    required String nama,
    required String email,
    required String nik,
    required String password,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.registerEndpoint),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'nama': nama,
          'email': email,
          'nik': nik, 
          'password': password,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true; 
      } else {
        // Ganti print menjadi debugPrint
        debugPrint('Gagal Register: ${response.body}');
        return false;
      }
    } catch (e) {
      // Ganti print menjadi debugPrint
      debugPrint('Error Exception: $e');
      return false;
    }
  }
}