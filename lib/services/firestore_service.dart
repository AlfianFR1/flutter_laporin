import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseLaporanService {
  final CollectionReference laporanRef =
      FirebaseFirestore.instance.collection('laporan');

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> kirimLaporan({
    required String judul,
    required String deskripsi,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception("User belum login");

    await laporanRef.add({
      'uid': user.uid,
      'email': user.email,
      'judul': judul,
      'deskripsi': deskripsi,
      'status': 'menunggu', // default status
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Opsional: Ambil semua laporan user ini
  Future<List<Map<String, dynamic>>> getLaporanSaya() async {
    final user = _auth.currentUser;
    if (user == null) return [];

    final snapshot = await laporanRef
        .where('uid', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => doc.data() as Map<String, dynamic>)
        .toList();
  }
}
