import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:laporin/providers/user_provider.dart';
import 'package:laporin/services/api_service.dart';
import 'package:laporin/services/preferences_helper.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:laporin/services/firebase_user_service.dart';

class FirebaseGoogleSignInService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  final FirebaseUserService _userService = FirebaseUserService();
  bool _isFirebaseSigningIn = false;

  final StreamController<GoogleSignInAccount?> _googleUserStreamController =
      StreamController<GoogleSignInAccount?>.broadcast();
  Stream<GoogleSignInAccount?> get googleUserStream =>
      _googleUserStreamController.stream;

  StreamSubscription<GoogleSignInAuthenticationEvent>? _authEventSubscription;

  FirebaseGoogleSignInService() {
    _initializeGoogleSignIn();
  }

  void _initializeGoogleSignIn() {
    print('🔄 Inisialisasi GoogleSignIn...');
    unawaited(
      GoogleSignIn.instance
          .initialize()
          .then((_) {
            print('✅ GoogleSignIn siap.');
            // _authEventSubscription = GoogleSignIn.instance.authenticationEvents
            //     .listen(
            //       _handleAuthEvent,
            //       onError: _handleAuthError,
            //     );
            // Tidak memanggil attemptLightweightAuthentication agar tidak langsung login otomatis
          })
          .catchError((error) {
            print('❌ Gagal inisialisasi GoogleSignIn: $error');
          }),
    );
  }

  Future<void> _handleAuthEvent(GoogleSignInAuthenticationEvent event) async {
    print('💡 Event Google: ${event.runtimeType}');
    final user = switch (event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };

    _googleUserStreamController.add(user);

    if (user != null && _auth.currentUser == null) {
      print('✅ Login Firebase...');
      await _firebaseSignIn(user);
    } else if (user == null && _auth.currentUser != null) {
      print('⛔ Logout Firebase...');
      await _auth.signOut();
    }
  }

  Future<void> _handleAuthError(Object e) async {
    print('❌ Event Error: $e');
    _googleUserStreamController.add(null);
  }

  Future<void> _firebaseSignIn(GoogleSignInAccount googleUser) async {
    if (_isFirebaseSigningIn) return; // ⛔ Jangan lanjut kalau sudah login
    _isFirebaseSigningIn = true;

    try {
      final auth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(idToken: auth.idToken);
      final userCredential = await _auth.signInWithCredential(credential);
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: "User tidak ditemukan setelah login.",
        );
      }

      final bool exists = await _userService.userExists(firebaseUser.uid);
      String role;

      if (!exists) {
        role =
            (firebaseUser.email ?? '').toLowerCase() ==
                'rohmanfatur.alfian@gmail.com'
            ? 'admin'
            : 'user';
        await _userService.saveUserToFirestore(firebaseUser, role);
        print('✅ User baru ditambahkan ke Firestore.');
      } else {
        role = await _userService.getUserRole(firebaseUser.uid) ?? 'user';
        print('👥 User lama ditemukan. Role: $role');
      }

      await PreferencesHelper.saveUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        role: role,
        displayName: firebaseUser.displayName ?? '',
        photoURL: firebaseUser.photoURL ?? '',
      );
    } catch (e) {
      print('❌ Error saat login Firebase: $e');
      rethrow;
    } finally {
      _isFirebaseSigningIn = false; // ✅ Reset flag
    }
  }

  Future<void> signInWithGoogle({
    required WidgetRef ref,
    required Function(String role) onSuccess,
    required Function(Object error) onError,
    required BuildContext context,
  }) async {
    try {
      print('🚀 Memulai login dengan Google');

      // 1. Autentikasi Google
      final googleUser = await GoogleSignIn.instance.authenticate();
      if (googleUser == null) {
        return onError('Login dibatalkan oleh pengguna');
      }

      final googleAuth = await googleUser.authentication;

      // 2. Login ke Firebase Auth
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await FirebaseAuth.instance.signInWithCredential(
        credential,
      );
      final firebaseUser = userCredential.user;

      if (firebaseUser == null) {
        return onError("Login Firebase gagal: user null");
      }

      final firebaseIdToken = await firebaseUser.getIdToken();

      // 3. Kirim token ke backend (pakai ApiService)
      final data = await ApiService.loginWithFirebaseIdToken(firebaseIdToken!);
      final role = data['role'] ?? 'user';

      // 4. Simpan ke local storage
      // await PreferencesHelper.saveUser(
      //   uid: firebaseUser.uid,
      //   email: firebaseUser.email ?? '',
      //   role: role,
      //   displayName: firebaseUser.displayName ?? '',
      //   photoURL: firebaseUser.photoURL ?? '',
      // );

      // 5. Set juga ke provider
      await ref
          .read(userProvider.notifier)
          .setUser(
            firebaseUser.uid,
            firebaseUser.email ?? '',
            role,
            displayName: firebaseUser.displayName,
            photoURL: firebaseUser.photoURL,
          );

      print('✅ Login berhasil, role: $role');

      // 6. Simpan token FCM
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .update({'fcm_token': fcmToken});
        print('🔐 FCM token disimpan: $fcmToken');
      }

      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(firebaseUser.uid)
            .update({'fcm_token': newToken});
        print('🔄 Token FCM diperbarui: $newToken');
      });

      onSuccess(role);
    } catch (e) {
      onError(e); // Tangani error cukup satu kali di sini
    }
  }

  Future<void> signOut() async {
    print('👋 Logout...');
    try {
      await _googleSignIn.disconnect();
      await _auth.signOut();
      _googleUserStreamController.add(null);
      print('✅ Logout berhasil.');
    } catch (e) {
      print('❌ Error saat logout: $e');
    }
  }

  // Simpan user info (UID, email, role)
  Future<void> _saveUserToLocal(String uid, String email, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid);
    await prefs.setString('email', email);
    await prefs.setString('role', role);
    await prefs.setBool('is_logged_in', true);
  }

  // Ambil info login dari storage
  Future<Map<String, dynamic>?> getUserFromLocal() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_logged_in') ?? false;

    if (!isLoggedIn) return null;

    return {
      'uid': prefs.getString('uid'),
      'email': prefs.getString('email'),
      'role': prefs.getString('role'),
    };
  }

  // Hapus info saat logout
  Future<void> clearUserLocal() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // atau hapus satu per satu kalau perlu
  }

  void dispose() {
    _authEventSubscription?.cancel();
    _googleUserStreamController.close();
  }
}
