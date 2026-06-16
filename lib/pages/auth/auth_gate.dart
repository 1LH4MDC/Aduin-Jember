import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_service.dart';
import '../admin/bottom_nav_admin.dart';
import '../user/bottom_nav.dart';
import 'login_page.dart';

// widget ini dipake buat nentuin halaman mana yang harus ditampilin pas pertama kali masuk app
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // mantau perubahan status login user lewat authcontroller
    return Consumer<AuthController>(
      builder: (context, auth, _) {
        // kalau masih proses loading data dari local storage, tampilin loading spinner dulu
        if (auth.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // kalau ternyata user belum login, langsung lempar ke halaman login
        if (!auth.isAuthenticated) {
          return const LoginPage();
        }

        // kalau udah login, cek role-nya. kalau admin ke bottom nav admin, kalau masyarakat biasa ke bottom nav biasa
        return auth.isAdmin ? const BottomNavAdmin() : const BottomNav();
      },
    );
  }
}
