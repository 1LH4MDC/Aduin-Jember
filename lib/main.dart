import 'package:aduin_jember/pages/admin/bottom_nav_admin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:device_preview/device_preview.dart'; // 1. Import package-nya
import 'core/theme.dart';
import 'pages/auth/login_page.dart';

void main() {
  // 2. Bungkus aplikasi utama dengan DevicePreview
  runApp(
    DevicePreview(
      enabled: !kReleaseMode, // Hanya aktif saat mode debug/development
      builder: (context) => const AduinJemberApp(),
    ),
  );
}

class AduinJemberApp extends StatelessWidget {
  const AduinJemberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // 3. Tambahkan pengaturan DevicePreview di sini
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      
      title: 'Aduin Jember',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const BottomNavAdmin(), 
    );
  }
}