// ignore_for_file: avoid_print

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

class ApiService {
  static const String baseUrl = 'https://laporin.alfianfr.my.id';

  static Future<String> kirimLaporan({
    required String uid,
    required String title,
    required String description,
    required File imageFile,
  }) async {
    final uri = Uri.parse('$baseUrl/reports');
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();

    final request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token'
      ..fields['title'] = title
      ..fields['description'] = description
      ..fields['user_uid'] = uid
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    return _handleResponse(response.statusCode, responseBody);
  }

  static Future<List<Map<String, dynamic>>> ambilLaporanSaya(String uid) async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/myreports'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );

    final result = await _parseResponse(response);
    return List<Map<String, dynamic>>.from(result['data']);
  }

  static Future<List<Map<String, dynamic>>> ambilSemuaLaporan() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/reports'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );

    final result = await _parseResponse(response);
    return List<Map<String, dynamic>>.from(result['data']);
  }

  static Future<Map<String, dynamic>> ambilDetailLaporan(String id) async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/report/$id'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );

    final result = await _parseResponse(response);
    return result['data'];
  }


static Future<Map<String, dynamic>> ambilStatistikLaporanUser() async {
  final token = await _getToken();

  final response = await http.get(
    Uri.parse('$baseUrl/my-report-stats'),
    headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
  );

  final result = await _parseResponse(response);
  return result['data']; // Mengembalikan { total, resolved, rejected }
}

static Future<Map<String, dynamic>> ambilSemuaStatistikLaporan() async {
  final token = await _getToken();

  final response = await http.get(
    Uri.parse('$baseUrl/report-stats'),
    headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
  );

  final result = await _parseResponse(response);
  return result['data']; // Mengembalikan { total, resolved, rejected }
}

static Future<List<Map<String, dynamic>>> ambilSemuaUsers() async {
  final token = await _getToken();

  final response = await http.get(
    Uri.parse('$baseUrl/users'),
    headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
  );

  final result = await _parseResponse(response);
  return List<Map<String, dynamic>>.from(result['data']); 
}




  static Future<String> updateLaporan({
    required String id,
    required String title,
    required String description,
    XFile? image,
  }) async {
    final token = await _getToken();
    final uri = Uri.parse('$baseUrl/report/$id');

    final request = http.MultipartRequest('PUT', uri)
      ..headers[HttpHeaders.authorizationHeader] = 'Bearer $token'
      ..fields['title'] = title
      ..fields['description'] = description;

    if (image != null) {
      final fileBytes = await image.readAsBytes();
      request.files.add(http.MultipartFile.fromBytes('image', fileBytes, filename: image.name));
    }

    final response = await request.send();
    final respStr = await response.stream.bytesToString();

    return _handleResponse(response.statusCode, respStr);
  }

    static Future<String> updateStatusLaporan({
    required String id,
    required String status,
  }) async {
    final token = await _getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/report/$id'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode({'status': status}),
    );

    final result = await _parseResponse(response);
    return result['message'] ?? 'Status laporan diperbarui';
  }


  static Future<List<Map<String, dynamic>>> ambilStatusHistoryByReportId(int reportId) async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/reportstatus/$reportId'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );

    final result = await _parseResponse(response);
    return List<Map<String, dynamic>>.from(result['data']);
  }

  static Future<List<Map<String, dynamic>>> ambilKomentar(int reportId) async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/report/$reportId/comments'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );

    final result = await _parseResponse(response);
    return List<Map<String, dynamic>>.from(result['data']);
  }

  static Future<String> tambahKomentar({
    required int reportId,
    required String comment,
    String type = 'general',
  }) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/report/$reportId/comments'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode({
        'comment': comment,
        'type': type,
      }),
    );

    final result = await _parseResponse(response);
    return result['message'] ?? 'Komentar berhasil ditambahkan';
  }

  static Future<String> updateKomentar({
    required int commentId,
    required String comment,
    String? type,
  }) async {
    final token = await _getToken();

    final response = await http.put(
      Uri.parse('$baseUrl/comments/$commentId'),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
        HttpHeaders.contentTypeHeader: 'application/json',
      },
      body: jsonEncode({
        'comment': comment,
        if (type != null) 'type': type,
      }),
    );

    final result = await _parseResponse(response);
    return result['message'] ?? 'Komentar berhasil diperbarui';
  }

  static Future<String> hapusKomentar(int commentId) async {
    final token = await _getToken();

    final response = await http.delete(
      Uri.parse('$baseUrl/comments/$commentId'),
      headers: {HttpHeaders.authorizationHeader: 'Bearer $token'},
    );

    final result = await _parseResponse(response);
    return result['message'] ?? 'Komentar berhasil dihapus';
  }

  // Helper methods
  static Future<String> _getToken() async {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) throw Exception('Token tidak tersedia');
    return token;
  }

  static Future<Map<String, dynamic>> loginWithFirebaseIdToken(String idToken) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'idToken': idToken}),
    );

    return await _parseResponse(response);
  }

static Future<Map<String, dynamic>> _parseResponse(http.Response response) async {
  final contentType = response.headers['content-type'] ?? '';
  final body = response.body;

  try {
    if (!contentType.contains('application/json')) {
      // Log isi body untuk debugging kalau perlu
      throw Exception();
    }

    final data = jsonDecode(body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Terjadi kesalahan');
    }
  } on FormatException catch (e) {
    throw Exception('Gagal decode JSON: ${e.message}\nBody: $body');
  } catch (e) {
    throw Exception('Server error (${response.statusCode})');
  }
}



  static String _handleResponse(int statusCode, String body) {
    try {
      final json = jsonDecode(body);
      if (statusCode >= 200 && statusCode < 300) {
        return json['message'] ?? 'Berhasil';
      } else {
        throw Exception(json['message'] ?? 'Terjadi kesalahan');
      }
    } catch (_) {
      throw Exception('Server tidak merespons dengan benar (kode $statusCode)');
    }
  }
}
