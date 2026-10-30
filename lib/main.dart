
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
import 'presentation/splash/splash_screen.dart';
import 'presentation/super_admin/super_admin_login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const HealthSyncApp());
}

class HealthSyncApp extends StatelessWidget {
  const HealthSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HealthSync',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF35AFA0),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7FAF9),
      ),
      routes: {
        '/super-admin-login': (context) =>
            const SuperAdminLoginScreen(),
      },
      home: const SplashScreen(),
    );
  }
}
