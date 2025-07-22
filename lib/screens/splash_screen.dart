import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:laporin/providers/user_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();

    // Delay 1 frame agar context tersedia
    Future.microtask(() {
      final user = ref.read(userProvider).value;
      if (user != null) {
        if (user.isLoggedIn) {
          if (user.role == 'admin') {
            context.go('/adminDashboard');
          } else {
            context.go('/userDashboard');
          }
        } else {
          context.go('/login');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
