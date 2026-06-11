import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/app_config.dart';
import 'core/theme.dart';
import 'pages/auth/auth_gate.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

  runApp(
    DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) => const AduinJemberApp(),
    ),
  );
}

class AduinJemberApp extends StatelessWidget {
  const AduinJemberApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthController(),
      child: MaterialApp(
        locale: DevicePreview.locale(context),
        builder: DevicePreview.appBuilder,
        title: 'Aduin Jember',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthGate(),
      ),
    );
  }
}
