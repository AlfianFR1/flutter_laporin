// lib/models/user_state.dart
class UserState {
  final String? uid;
  final String? email;
  final String? role;
  final String? displayName;
  final String? photoURL;
  final bool isLoggedIn;

  const UserState({
    this.uid,
    this.email,
    this.role,
    this.displayName,
    this.photoURL,
    this.isLoggedIn = false,
  });

  bool get isUserSessionValid => uid != null && email != null && isLoggedIn;

  UserState copyWith({
    String? uid,
    String? email,
    String? role,
    String? displayName,
    String? photoURL,
    bool? isLoggedIn,
  }) {
    return UserState(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      role: role ?? this.role,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      isLoggedIn: isLoggedIn ?? this.isLoggedIn,
    );
  }

  factory UserState.initial() => const UserState();
}
