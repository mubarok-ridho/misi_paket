import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/kurir_stats_model.dart';

class KurirStatsService {
  static Future<KurirStatsModel?> fetchStats(int kurirId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('❌ Token tidak ditemukan.');
        return null;
      }

      print("🔑 JWT Token: $token");

      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

      final prosesResponse = await http.get(
        Uri.parse('http://localhost:8080/api/kurir/$kurirId/orders/proses'),
        headers: headers,
      );

      final selesaiResponse = await http.get(
        Uri.parse('http://localhost:8080/api/kurir/$kurirId/orders/selesai/today'),
        headers: headers,
      );

      final pendapatanResponse = await http.get(
        Uri.parse('http://localhost:8080/api/pendapatan/kurir/$kurirId/today'),
        headers: headers,
      );

      // Debug log
      print("📦 prosesResponse.body: ${prosesResponse.body}");
      print("📦 selesaiResponse.body: ${selesaiResponse.body}");
      print("📦 pendapatanResponse.body: ${pendapatanResponse.body}");

      int prosesCount = 0;
      int selesaiCount = 0;
      double pendapatan = 0.0;

      try {
        final raw = prosesResponse.body;
        if (raw != null && raw.trim().isNotEmpty && raw.trim() != "null") {
          final data = jsonDecode(raw);
if (data is List) {
  prosesCount = data.length;
}
        }
      } catch (e) {
        print("⚠️ Gagal parsing proses: $e");
      }

      try {
        final raw = selesaiResponse.body;
        if (raw != null && raw.trim().isNotEmpty && raw.trim() != "null") {
          final data = jsonDecode(raw);
          if (data is List) {
            selesaiCount = data.length;
          }
        }
      } catch (e) {
        print("⚠️ Gagal parsing selesai: $e");
      }

      try {
        final raw = pendapatanResponse.body;
        if (raw != null && raw.trim().isNotEmpty && raw.trim() != "null") {
          final data = jsonDecode(raw);
          final total = data['total_pendapatan'];
          if (total is int) {
            pendapatan = total.toDouble();
          } else if (total is double) {
            pendapatan = total;
          } else if (total is String) {
            pendapatan = double.tryParse(total) ?? 0.0;
          }
        }
      } catch (e) {
        print("⚠️ Gagal parsing pendapatan: $e");
      }

      return KurirStatsModel(
        pesananDiproses: prosesCount,
        pesananSelesaiHariIni: selesaiCount,
        pendapatanHariIni: pendapatan,
      );
    } catch (e) {
      print('❌ Error saat mengambil data stats: $e');
      return null;
    }
  }
}
