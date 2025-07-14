import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laporin/services/api_service.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class LaporanSayaScreen extends StatefulWidget {
  const LaporanSayaScreen({super.key});

  @override
  State<LaporanSayaScreen> createState() => _LaporanSayaScreenState();
}

class _LaporanSayaScreenState extends State<LaporanSayaScreen> {
  late Future<List<Map<String, dynamic>>> _laporanFuture;

  @override
  void initState() {
    super.initState();
    final uid = Provider.of<UserProvider>(context, listen: false).uid;
    if (uid != null) {
      _laporanFuture = ApiService.ambilLaporanSaya(uid);
    } else {
      _laporanFuture = Future.error('UID tidak ditemukan');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: Text(
          'Laporan Saya',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _laporanFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Terjadi kesalahan: ${snapshot.error}',
                style: GoogleFonts.poppins(),
              ),
            );
          }

          final laporanList = snapshot.data!;
          if (laporanList.isEmpty) {
            return Center(
              child: Text(
                'Belum ada laporan.',
                style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: laporanList.length,
            itemBuilder: (context, index) {
              final laporan = laporanList[index];
              final status = laporan['status'] ?? 'Tidak diketahui';
              final statusColor = _getStatusColor(status);

              return GestureDetector(
                onTap: () {
                  context.push('/laporan/${laporan['id']}');
                },
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // Gambar
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: laporan['image_url'] != null
                              ? Image.network(
                                  '${ApiService.baseUrl}/${laporan['image_url']}',
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  width: 80,
                                  height: 80,
                                  color: Colors.grey.shade200,
                                  child: const Icon(Icons.image_not_supported, color: Colors.grey),
                                ),
                        ),
                        const SizedBox(width: 16),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                laporan['title'] ?? 'Tanpa Judul',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(Icons.check_circle, size: 16, color: statusColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    status,
                                    style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      color: statusColor,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              if (laporan['createdAt'] != null)
                                Text(
                                  'Tanggal: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(laporan['createdAt']))}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // 🔴 Tambahan untuk memberi warna status
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'on_progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'rejected':
      case 'canceled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
