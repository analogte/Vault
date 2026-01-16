import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'features/auth/screens/splash_screen.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/vault_service.dart';
import 'services/vault_sync_service.dart';
import 'services/file_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize API service with backend URL
    // For development: http://localhost:3000
    // For mobile emulator: http://10.0.2.2:3000 (Android) or http://localhost:3000 (iOS)
    // For real device: http://<your-computer-ip>:3000
    final apiService = ApiService(
      baseUrl: 'http://localhost:3000', // Change this for your setup
    );
    final authService = AuthService(apiService);
    final vaultService = VaultService();
    final vaultSyncService = VaultSyncService(apiService, authService);
    vaultService.setSyncService(vaultSyncService);

    return MultiProvider(
      providers: [
        Provider<ApiService>(create: (_) => apiService),
        Provider<AuthService>(create: (_) => authService),
        Provider<VaultService>(create: (_) => vaultService),
        Provider<VaultSyncService>(create: (_) => vaultSyncService),
        Provider<FileService>(create: (_) => FileService()),
      ],
      child: MaterialApp(
        title: 'Secure Vault',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
        ),
        darkTheme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
      ),
    );
  }
}
