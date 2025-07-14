// lib/services/firebase_user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseUserService {
  final CollectionReference usersRef =
      FirebaseFirestore.instance.collection('users');

  Future<void> saveUserToFirestore(User user, String role) async {
    await usersRef.doc(user.uid).set({
      'uid': user.uid,
      'email': user.email,
      'role': role,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<String?> getUserRole(String uid) async {
    final doc = await usersRef.doc(uid).get();
    if (doc.exists && doc.data() != null) {
      final data = doc.data() as Map<String, dynamic>;
      return data['role'] as String?;
    }
    return null;
  }

  Future<bool> userExists(String uid) async {
    final doc = await usersRef.doc(uid).get();
    return doc.exists;
  }
}
