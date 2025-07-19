// lib/providers/user_provider.dart
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import './user_state.dart';

class UserNotifier extends AsyncNotifier<UserState> {
  @override
  FutureOr<UserState> build() async {
    return await _loadUserFromStorage();
  }

  Future<UserState> _loadUserFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final isLogin = prefs.getBool('is_logged_in') ?? false;

    if (isLogin) {
      return UserState(
        uid: prefs.getString('uid'),
        email: prefs.getString('email'),
        role: prefs.getString('role'),
        displayName: prefs.getString('display_name'),
        photoURL: prefs.getString('photo_url'),
        isLoggedIn: true,
      );
    }

    return UserState.initial();
  }

  Future<void> setUser(
    String uid,
    String email,
    String role, {
    String? displayName,
    String? photoURL,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('uid', uid);
    await prefs.setString('email', email);
    await prefs.setString('role', role);
    await prefs.setBool('is_logged_in', true);

    if (displayName != null) {
      await prefs.setString('display_name', displayName);
    }

    if (photoURL != null) {
      await prefs.setString('photo_url', photoURL);
    }

    state = AsyncValue.data(UserState(
      uid: uid,
      email: email,
      role: role,
      displayName: displayName,
      photoURL: photoURL,
      isLoggedIn: true,
    ));
  }

  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    state = AsyncValue.data(UserState.initial());
  }
}
