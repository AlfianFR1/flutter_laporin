// lib/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:laporin/screens/admin/dashboard_admin.dart';
import 'package:laporin/screens/auth/login_screen.dart';
import 'package:laporin/screens/user/dashboard_user.dart';
import 'package:laporin/services/preferences_helper.dart'; 

// import 'package:laporin/services/firebase_google_signin_service.dart'; // Sesuaikan path ini

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Masih loading
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final user = snapshot.data;

        if (user != null) {
          // User login, cek role dari shared preferences
          return FutureBuilder<Map<String, dynamic>?>(
            future: PreferencesHelper.getUser(),
            builder: (context, roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }

              final role = roleSnapshot.data?['role'];
              if (role == 'admin') {
                return const AdminDashboardScreen();
              } else {
                return const UserDashboardScreen();
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

