import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:laporin/screens/admin/dashboard_admin.dart';
import 'package:laporin/screens/auth/login_screen.dart';
import 'package:laporin/screens/user/dashboard_user.dart';
import 'package:laporin/services/preferences_helper.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Handle error dari auth stream
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Terjadi kesalahan saat autentikasi.')),
          );
        }

        // Tampilkan loading saat auth state belum selesai
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashLoading();
        }

        final user = snapshot.data;

        if (user != null) {
          // User login, cek role
          return FutureBuilder<Map<String, dynamic>?>(
            future: PreferencesHelper.getUser(),
            builder: (context, roleSnapshot) {
              // Handle error dari getUser
              if (roleSnapshot.hasError) {
                return const Scaffold(
                  body: Center(child: Text('Gagal memuat data pengguna.')),
                );
              }

              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const SplashLoading();
              }

              final role = roleSnapshot.data?['role'];

              if (role == 'admin') {
                return const AdminDashboardScreen();
              } else if (role == 'user') {
                return const UserDashboardScreen();
              } else {
                // Fallback: role tidak ditemukan atau null
                return const LoginScreen();
              }
            },
          );
        } else {
          // Belum login
          return const LoginScreen();
        }
      },
    );
  }
}

/// Widget splash loading dengan logo + loading spinner
class SplashLoading extends StatelessWidget {
  const SplashLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlutterLogo(size: 80),
            SizedBox(height: 20),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
