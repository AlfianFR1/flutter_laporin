import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:laporin/providers/user_provider.dart';
import 'package:laporin/services/api_service.dart';
import 'package:laporin/utils/date_formatter.dart';
import 'package:provider/provider.dart';

class LaporanDetailScreen extends ConsumerStatefulWidget {
  final int reportId;

  const LaporanDetailScreen({super.key, required this.reportId});

  @override
  ConsumerState<LaporanDetailScreen> createState() => _LaporanDetailScreenState();
}

class _LaporanDetailScreenState extends ConsumerState<LaporanDetailScreen> {
  late Future<void> _loadDataFuture;
  Map<String, dynamic> report = {};
  List<Map<String, dynamic>> comments = [];
  List<Map<String, dynamic>> statusHistories = [];

  @override
  void initState() {
    super.initState();
    _loadDataFuture = _loadData();
  }

  bool get _bisaDieditAtauDibatalkan {
    return report['status'] != 'canceled' && statusHistories.length <= 1;
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

  void _showEditLaporanDialog() {
    final titleController = TextEditingController(text: report['title']);
    final descController = TextEditingController(text: report['description']);
    XFile? selectedImage;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit Laporan'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: titleController, decoration: const InputDecoration(labelText: 'Judul')),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Deskripsi'),
                  maxLines: 3,
                ),
                const SizedBox(height: 8),
                ElevatedButton.icon(
                  onPressed: () async {
                    final picker = ImagePicker();
                    final picked = await picker.pickImage(source: ImageSource.gallery);
                    if (picked != null) {
                      setDialogState(() {
                        selectedImage = picked;
                      });
                    }
                  },
                  icon: const Icon(Icons.image),
                  label: const Text('Pilih Gambar Baru'),
                ),
                if (selectedImage != null) Text('Gambar dipilih: ${selectedImage?.name}'),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            ElevatedButton(
              onPressed: () async {
                try {
                  await ApiService.updateLaporan(
                    id: widget.reportId.toString(),
                    title: titleController.text,
                    description: descController.text,
                    image: selectedImage,
                  );
                  if (!mounted) return;
                  await _loadData(); // refresh data
                    if (!mounted) return;
                    Navigator.pop(context, 'Laporan berhasil diperbarui');

                } catch (e) {
                  if (!mounted) return;
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(_getErrorMessage(e))),
                  );
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    ).then((result) {
      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
      }
    });
  }

  Future<void> _konfirmasiCancelLaporan() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Batalkan Laporan'),
        content: const Text('Yakin ingin membatalkan laporan ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Tidak')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Ya')),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ApiService.updateStatusLaporan(id: widget.reportId.toString(), status: 'canceled');
        await _loadData();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Laporan dibatalkan.')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
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
              Navigator.pop(context); // hanya tutup dialog
              await _loadData(); // refresh
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
  final konfirmasi = await showDialog<bool>(
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

  if (konfirmasi == true) {
    try {
      await ApiService.hapusKomentar(commentId);
      await _loadData();
      // ✅ Tambahkan pesan sukses
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Komentar berhasil dihapus.')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }
}


  String _getErrorMessage(Object e) {
    if (e is SocketException) return 'Tidak dapat terhubung ke server.';
    if (e is HttpException) return 'Gagal berkomunikasi dengan server.';
    if (e is TimeoutException) return 'Timeout server.';
    return e.toString();
  }

  Widget _buildRiwayatStatus(String? currentUid) {
    if (statusHistories.isEmpty) return const Text('Belum ada riwayat status.');
    return Column(
      children: statusHistories.map((status) {
        final oleh = status['changed_by'] == currentUid ? 'Anda' : 'Admin';
        return ListTile(
          leading: const Icon(Icons.history),
          title: Text(status['status']),
          subtitle: Text('Oleh: $oleh • ${DateFormatter.fromIso(status['createdAt'])}'),
        );
      }).toList(),
    );
  }

  Widget _buildKomentarList() {
  final user = ref.watch(userProvider).maybeWhen(
    data: (data) => data,
    orElse: () => null,
  );
  final currentUid = user?.uid ?? '';

  final bool isEditable = !['canceled', 'rejected', 'resolved'].contains(report['status']);

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (comments.isEmpty)
        const Text('Belum ada komentar')
      else
        ...comments.map((komentar) {
          final oleh = komentar['user_uid'] == currentUid ? 'Kamu' : 'Admin';
          return ListTile(
            leading: const Icon(Icons.comment),
            title: Text(komentar['comment'] ?? ''),
            subtitle: Text(
              '$oleh • ${komentar['createdAt'] != null ? DateFormatter.fromIso(komentar['createdAt']) : '-'}',
            ),
            trailing: komentar['user_uid'] == currentUid
              ? PopupMenuButton<String>(
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
                )
              : null,
          );
        }),
      const SizedBox(height: 12),
      if (isEditable)
        Align(
          alignment: Alignment.centerRight,
          child: ElevatedButton.icon(
            onPressed: () => _showKomentarDialog(),
            icon: const Icon(Icons.add_comment),
            label: const Text('Tambah Komentar'),
          ),
        ),
    ],
  );
}




  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider).maybeWhen(
    data: (data) => data,
    orElse: () => null,
  );
  final currentUid = user?.uid ?? '';

    return Scaffold(
      appBar: AppBar(title: const Text('Detail Laporan')),
      body: FutureBuilder<void>(
        future: _loadDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final title = report['title'] ?? '-';
          final desc = report['description'] ?? '-';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: Text(title, style: Theme.of(context).textTheme.headlineSmall)),
                    if (_bisaDieditAtauDibatalkan)
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            tooltip: 'Edit Laporan',
                            onPressed: _showEditLaporanDialog,
                          ),
                          IconButton(
                            icon: const Icon(Icons.cancel, color: Colors.red),
                            tooltip: 'Batalkan Laporan',
                            onPressed: _konfirmasiCancelLaporan,
                          ),
                        ],
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      DateFormatter.fromIso(report['createdAt'] ?? ''),
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(desc),
                const SizedBox(height: 16),
                if (report['image_url'] != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      '${ApiService.baseUrl}/${report['image_url']}',
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                const SizedBox(height: 24),
                Text('Riwayat Status', style: Theme.of(context).textTheme.titleMedium),
                const Divider(),
                _buildRiwayatStatus(currentUid),
                const SizedBox(height: 24),
                Text('Komentar / Progress', style: Theme.of(context).textTheme.titleMedium),
                const Divider(),
                _buildKomentarList(),
                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
    );
  }
}
