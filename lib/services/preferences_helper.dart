import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static const _keyUid = 'uid';
  static const _keyEmail = 'email';
  static const _keyRole = 'role';
  static const _keyName = 'displayName';
  static const _keyPhoto = 'photoURL';
  static const _keyIsLoggedIn = 'is_logged_in';

  /// Simpan data user ke SharedPreferences
  static Future<void> saveUser({
    required String uid,
    required String email,
    required String role,
    required String displayName,
    required String photoURL,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUid, uid);
    await prefs.setString(_keyEmail, email);
    await prefs.setString(_keyRole, role);
    await prefs.setString(_keyName, displayName);
    await prefs.setString(_keyPhoto, photoURL);
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  /// Ambil data user dari SharedPreferences
  static Future<Map<String, String>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool(_keyIsLoggedIn) ?? false;
    if (!isLoggedIn) return null;

    return {
      'uid': prefs.getString(_keyUid) ?? '',
      'email': prefs.getString(_keyEmail) ?? '',
      'role': prefs.getString(_keyRole) ?? '',
      'displayName': prefs.getString(_keyName) ?? '',
      'photoURL': prefs.getString(_keyPhoto) ?? '',
    };
  }

  /// Hapus data user dari SharedPreferences saat logout
  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUid);
    await prefs.remove(_keyEmail);
    await prefs.remove(_keyRole);
    await prefs.remove(_keyName);
    await prefs.remove(_keyPhoto);
    await prefs.remove(_keyIsLoggedIn);
  }
}
