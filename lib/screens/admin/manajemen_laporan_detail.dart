import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laporin/providers/user_provider.dart';
import 'package:laporin/services/api_service.dart';
import 'package:laporin/utils/date_formatter.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';


class ManajemenLaporanDetailScreen extends StatefulWidget {
  final int reportId;

  const ManajemenLaporanDetailScreen({super.key, required this.reportId});

  @override
  State<ManajemenLaporanDetailScreen> createState() => _ManajemenLaporanDetailScreenState();
}

class _ManajemenLaporanDetailScreenState extends State<ManajemenLaporanDetailScreen> {
  late Future<void> _loadDataFuture;
  Map<String, dynamic> report = {};
  List<Map<String, dynamic>> comments = [];
  List<Map<String, dynamic>> statusHistories = [];

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadData();
  }

  Future<void> _loadData() async {
    final detail = await ApiService.ambilDetailLaporan(widget.reportId.toString());
    final status = await ApiService.ambilStatusHistoryByReportId(widget.reportId);
    if (!mounted) return;
    setState(() {
      report = detail;
      comments = List<Map<String, dynamic>>.from(detail['comments'] ?? []);
      statusHistories = status;
    });
  }

  Future<void> _ubahStatus(String status) async {
    try {
      await ApiService.updateStatusLaporan(id: widget.reportId.toString(), status: status);
      await _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status diubah menjadi $status')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  void _showKomentarDialog({Map<String, dynamic>? komentar}) {
    final controller = TextEditingController(text: komentar?['comment'] ?? '');

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(komentar == null ? 'Tambah Komentar' : 'Edit Komentar'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Tulis komentar...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          ElevatedButton(
            onPressed: () async {
              final text = controller.text.trim();
              if (text.isEmpty) return;
              try {
                if (komentar == null) {
                  await ApiService.tambahKomentar(reportId: widget.reportId, comment: text);
                } else {
                  await ApiService.updateKomentar(commentId: komentar['id'], comment: text);
                }
                Navigator.pop(context);
                await _loadData();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(komentar == null ? 'Komentar ditambahkan.' : 'Komentar diperbarui.')),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
              }
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _konfirmasiHapusKomentar(int commentId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Hapus Komentar'),
        content: const Text('Yakin ingin menghapus komentar ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Batal')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Hapus')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.hapusKomentar(commentId);
        await _loadData();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Komentar berhasil dihapus.')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  String _getErrorMessage(Object e) {
    if (e is SocketException) return 'Tidak dapat terhubung ke server.';
    if (e is HttpException) return 'Gagal berkomunikasi dengan server.';
    if (e is TimeoutException) return 'Timeout server.';
    return e.toString();
  }

  Widget _buildRiwayatStatus() {
  if (statusHistories.isEmpty) {
    return Text('Belum ada riwayat status.', style: GoogleFonts.poppins());
  }

  return Column(
    children: statusHistories.map((status) {
      final oleh = status['changed_by'] == report['user_uid'] ? 'User' : 'Admin';
      return Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          leading: const Icon(Icons.history, color: Colors.deepPurple),
          title: Text(status['status'], style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
          subtitle: Text(
            'Oleh: $oleh • ${DateFormatter.fromIso(status['createdAt'])}',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
        ),
      );
    }).toList(),
  );
}


 Widget _buildKomentarList() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (comments.isEmpty)
        Text('Belum ada komentar', style: GoogleFonts.poppins())
      else
        ...comments.map((komentar) {
          final oleh = komentar['user_uid'] == report['user_uid'] ? 'User' : 'Admin';
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              leading: const Icon(Icons.comment, color: Colors.deepPurple),
              title: Text(komentar['comment'] ?? '', style: GoogleFonts.poppins()),
              subtitle: Text(
                '$oleh • ${komentar['createdAt'] != null ? DateFormatter.fromIso(komentar['createdAt']) : '-'}',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
              trailing: PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _showKomentarDialog(komentar: komentar);
                  } else if (value == 'delete') {
                    _konfirmasiHapusKomentar(komentar['id']);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(value: 'edit', child: Text('Edit')),
                  const PopupMenuItem(value: 'delete', child: Text('Hapus')),
                ],
              ),
            ),
          );
        }),
      const SizedBox(height: 12),
      Align(
        alignment: Alignment.centerRight,
        child: ElevatedButton.icon(
          onPressed: () => _showKomentarDialog(),
          icon: const Icon(Icons.add_comment),
          label: Text('Tambah Komentar', style: GoogleFonts.poppins()),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ),
    ],
  );
}


  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF8F9FA),
    appBar: AppBar(
      title: Text(
        'Detail Laporan (Admin)',
        style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
      ),
      backgroundColor: Colors.deepPurple,
      foregroundColor: Colors.white,
    ),
    body: FutureBuilder<void>(
      future: _loadDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: GoogleFonts.poppins(color: Colors.red),
            ),
          );
        }

        final title = report['title'] ?? '-';
        final desc = report['description'] ?? '-';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    DateFormatter.fromIso(report['createdAt'] ?? ''),
                    style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                desc,
                style: GoogleFonts.poppins(fontSize: 15),
              ),
              const SizedBox(height: 16),
              if (report['image_url'] != null)
  Column(
    children: [
      GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ImagePreviewScreen(
                imageUrl: '${ApiService.baseUrl}/${report['image_url']}',
              ),
            ),
          );
        },
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            '${ApiService.baseUrl}/${report['image_url']}',
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
      ),
      const SizedBox(height: 24), // ⬅️ Selalu beri jarak jika gambar ada
    ],
  )
else
  const SizedBox(height: 24), // ⬅️ Jika tidak ada gambar, tetap beri jarak

// lalu lanjut ke dropdown
DropdownButtonFormField<String>(
  value: report['status'],
  decoration: InputDecoration(
    labelText: 'Ubah Status Laporan',
    labelStyle: GoogleFonts.poppins(),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  ),
  items: const [
    DropdownMenuItem(value: 'pending', child: Text('Belum Diproses')),
    DropdownMenuItem(value: 'on_progress', child: Text('Sedang Diproses')),
    DropdownMenuItem(value: 'resolved', child: Text('Selesai')),
    DropdownMenuItem(value: 'rejected', child: Text('Ditolak')),
    DropdownMenuItem(value: 'canceled', child: Text('Dibatalkan')),
  ],
  onChanged: (value) {
    if (value != null && value != report['status']) {
      _ubahStatus(value);
    }
  },
),

              const SizedBox(height: 32),

              // Riwayat Status
              Text(
                'Riwayat Status',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _buildRiwayatStatus(),

              const SizedBox(height: 32),
              Text(
                'Komentar',
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              _buildKomentarList(),

              const SizedBox(height: 100),
            ],
          ),
        );
      },
    ),
  );
}



}

class ImagePreviewScreen extends StatelessWidget {
  final String imageUrl;

  const ImagePreviewScreen({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Center(
        child: InteractiveViewer(
          child: Image.network(imageUrl),
        ),
      ),
    );
  }
}
