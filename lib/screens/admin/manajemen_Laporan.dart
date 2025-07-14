import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:laporin/services/api_service.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';

class ManajemenLaporanScreen extends StatefulWidget {
  const ManajemenLaporanScreen({super.key});

  @override
  State<ManajemenLaporanScreen> createState() => _ManajemenLaporanScreenState();
}

class _ManajemenLaporanScreenState extends State<ManajemenLaporanScreen> {
  late Future<List<Map<String, dynamic>>> _laporanFuture;
  String _selectedStatus = 'all';

  @override
  void initState() {
    super.initState();
    final uid = Provider.of<UserProvider>(context, listen: false).uid;
    if (uid != null) {
      _laporanFuture = _filterLaporan(_selectedStatus);
    } else {
      _laporanFuture = Future.error('UID tidak ditemukan');
    }
  }

  Future<List<Map<String, dynamic>>> _filterLaporan(String status) async {
    final semuaLaporan = await ApiService.ambilSemuaLaporan();
    if (status == 'all') return semuaLaporan;
    return semuaLaporan.where((laporan) => laporan['status'] == status).toList();
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'on_progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'canceled':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'Manajemen Laporan',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: DropdownButtonFormField<String>(
              value: _selectedStatus,
              decoration: InputDecoration(
                labelText: 'Filter Status',
                labelStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: const [
                DropdownMenuItem(value: 'all', child: Text('Semua')),
                DropdownMenuItem(value: 'pending', child: Text('Belum Diproses')),
                DropdownMenuItem(value: 'on_progress', child: Text('Sedang Diproses')),
                DropdownMenuItem(value: 'resolved', child: Text('Selesai')),
                DropdownMenuItem(value: 'rejected', child: Text('Ditolak')),
                DropdownMenuItem(value: 'canceled', child: Text('Dibatalkan')),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedStatus = value;
                    _laporanFuture = _filterLaporan(_selectedStatus);
                  });
                }
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: _laporanFuture,
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

                final laporanList = snapshot.data!;
                if (laporanList.isEmpty) {
                  return Center(
                    child: Text(
                      'Tidak ada laporan untuk filter ini',
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey[700]),
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: laporanList.length,
                  itemBuilder: (context, index) {
                    final laporan = laporanList[index];
                    final status = laporan['status'] ?? 'unknown';

                    return Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      margin: const EdgeInsets.only(bottom: 16),
                      child: InkWell(
                        onTap: () => context.push('/manajemen-laporan-detail/${laporan['id']}'),
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              laporan['image_url'] != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        '${ApiService.baseUrl}/${laporan['image_url']}',
                                        width: 60,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      laporan['title'] ?? 'Tanpa judul',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Status: ${status.replaceAll('_', ' ')}',
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        color: _statusColor(status),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    if (laporan['createdAt'] != null)
                                      Text(
                                        'Tanggal: ${DateFormat('dd MMM yyyy, HH:mm').format(DateTime.parse(laporan['createdAt']))}',
                                        style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[700]),
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
          ),
        ],
      ),
    );
  }
}
