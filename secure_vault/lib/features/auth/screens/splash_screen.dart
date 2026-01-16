import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/auth_service.dart';
import 'login_screen.dart';
import '../../vault/screens/vault_list_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    // Maximum wait time - always navigate after this
    final maxWaitTime = Future.delayed(const Duration(seconds: 5));
    
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      
      // Initialize auth service with very short timeout
      final initFuture = authService.initialize().timeout(
        const Duration(seconds: 1),
        onTimeout: () {
          print('Auth initialization timeout - proceeding to login');
          return;
        },
      );
      
      // Wait for either initialization or max time
      await Future.any([initFuture, maxWaitTime]);
      
      // Small delay for splash effect (only if we finished quickly)
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      
      // Navigate based on auth state
      if (authService.isLoggedIn) {
        print('User is logged in, navigating to VaultListScreen');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const VaultListScreen(),
          ),
        );
      } else {
        print('User is not logged in, navigating to LoginScreen');
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    } catch (e) {
      // If any error, go to login screen immediately
      print('Auth check error: $e');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              builder: (context, value, child) {
                return Transform.scale(
                  scale: value,
                  child: Opacity(
                    opacity: value,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock,
                        size: 100,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            Text(
              'Secure Vault',
              style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'เก็บไฟล์ของคุณอย่างปลอดภัย',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 48),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
