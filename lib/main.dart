import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// import konfigurasi, tema, dan halaman internal aplikasi
import 'core/app_config.dart';
import 'core/theme.dart';
import 'pages/auth/auth_gate.dart';
import 'services/auth_service.dart';

// fungsi main ini titik masuk utama pas aplikasi pertama kali dijalankan
Future<void> main() async {
  // mastiin semua sistem internal flutter udah siap sebelum jalanin kode async di bawah
  WidgetsFlutterBinding.ensureInitialized();

  // ngecek dulu config supabase-nya udah diset di app config, kalau ada di-init
  if (AppConfig.hasSupabaseConfig) {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      publishableKey: AppConfig.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        autoRefreshToken: false,
      ),
    );
  }

  // jalanin root widget aplikasi yang dibungkus device preview biar gampang simulasiin layout hp
  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const AduinJemberApp(),
    ),
  );
}

// ini widget utama/root dari aplikasi aduin jember
class AduinJemberApp extends StatelessWidget {
  const AduinJemberApp({super.key});

  @override
  Widget build(BuildContext context) {
    // pake provider authcontroller biar status login user bisa dipantau di semua widget tree
    return ChangeNotifierProvider(
      create: (_) => AuthController(),
      child: MaterialApp(
        // sinkronisasi setelan bahasa dan builder aplikasi sama device preview
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        title: 'Aduin Jember',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // gerbang utama aplikasi buat nentuin halaman login, dashboard user, atau dashboard admin
        home: const AuthGate(),
      ),
    );
  }
}
