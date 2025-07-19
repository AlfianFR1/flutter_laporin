import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laporin/services/firebase_google_signin_service.dart';
import 'package:laporin/utils/toast.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _googleSignInService = FirebaseGoogleSignInService();
  bool _isLoading = false;

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);

    await _googleSignInService.signInWithGoogle(
      context: context,
      onSuccess: (role) {
        if (!mounted) return;
        ToastUtil.showSuccess(context, "Login sukses");
        Future.microtask(() {
          context.go(role == 'admin' ? '/adminDashboard' : '/userDashboard');
        });
      },
      onError: (error) {
        if (!mounted) return;
        ToastUtil.showError(context, error.toString());
        setState(() => _isLoading = false);
      },
      ref: ref,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Judul Aplikasi
              Text(
                'Lapor Pak Kades!',
                style: GoogleFonts.poppins(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),

              // Subjudul
              Text(
                'Selamat Datang!',
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Silakan login menggunakan akun Google Anda',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 32),

              // Icon avatar
              CircleAvatar(
                radius: 48,
                backgroundColor: Colors.deepPurple.shade100,
                child: const Icon(
                  Icons.lock,
                  size: 48,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 24),

              // Tombol login
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _loginWithGoogle,
                      icon: Image.asset('assets/google_logo.png', height: 24),
                      label: Text(
                        'Login dengan Google',
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black87,
                        minimumSize: const Size.fromHeight(50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Colors.grey),
                        elevation: 3,
                        shadowColor: Colors.black12,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
