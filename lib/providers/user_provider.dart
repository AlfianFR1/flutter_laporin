// // File: lib/providers/user_provider.dart
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class UserProvider extends ChangeNotifier {
//   String? uid;
//   String? email;
//   String? role;
//   String? displayName;
//   String? photoURL;
//   bool isLoggedIn = false;

//   Future<void> loadUserFromStorage() async {
//     final prefs = await SharedPreferences.getInstance();
//     final isLogin = prefs.getBool('is_logged_in') ?? false;

//     if (isLogin) {
//       uid = prefs.getString('uid');
//       email = prefs.getString('email');
//       role = prefs.getString('role');
//       displayName = prefs.getString('display_name');
//       photoURL = prefs.getString('photo_url');
//       isLoggedIn = true;
//       notifyListeners();
//     }
//   }

//   Future<void> setUser(
//     String newUid,
//     String newEmail,
//     String newRole, {
//     String? newDisplayName,
//     String? newPhotoURL,
//   }) async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setString('uid', newUid);
//     await prefs.setString('email', newEmail);
//     await prefs.setString('role', newRole);
//     await prefs.setBool('is_logged_in', true);

//     if (newDisplayName != null) {
//       await prefs.setString('display_name', newDisplayName);
//       displayName = newDisplayName;
//     }

//     if (newPhotoURL != null) {
//       await prefs.setString('photo_url', newPhotoURL);
//       photoURL = newPhotoURL;
//     }

//     uid = newUid;
//     email = newEmail;
//     role = newRole;
//     isLoggedIn = true;
//     notifyListeners();
//   }

//   Future<void> clearUser() async {
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.clear();
//     uid = null;
//     email = null;
//     role = null;
//     displayName = null;
//     photoURL = null;
//     isLoggedIn = false;
//     notifyListeners();
//   }

//   bool get isUserSessionValid => uid != null && email != null && isLoggedIn;
// }


// lib/providers/user_provider.dart (lanjutan)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:laporin/providers/user_notifier.dart';
import 'package:laporin/providers/user_state.dart';

final userProvider = AsyncNotifierProvider<UserNotifier, UserState>(() {
  return UserNotifier();
});
