import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/kurir_model.dart';
import 'package:misi_paket/models/kurir_stats_model.dart' as model;
import 'package:misi_paket/services/kurir_stats_service.dart';
import 'package:http/http.dart' as http;

class KurirDetailPage extends StatefulWidget {
  final Kurir kurir;
  final int kurirId;

  const KurirDetailPage({
    super.key,
    required this.kurir,
    required this.kurirId,
  });

  @override
  State<KurirDetailPage> createState() => _KurirDetailPageState();
}

class _KurirDetailPageState extends State<KurirDetailPage> {
  model.KurirStatsModel? stats;
  bool isLoading = true;
  bool isOnline = false;
  bool isStatusLoading = true;

  final Color primaryColor = const Color(0xFFE64513); // Oranye FaiExpress
  final Color backgroundColor = const Color(0xFF121212); // Dark
  final Color cardColor = const Color(0xFF1E1E1E);

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await fetchKurirStatus(); // ini akan set isStatusLoading = false
    await loadStats(); // ini akan set isLoading = false
  }

  Future<void> fetchKurirStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = widget.kurirId;

    final response = await http.get(
      Uri.parse('http://localhost:8080/api/kurir/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      // jika response berupa objek kurir lengkap
      final status = data['user']['status'];

      if (status != null) {
        setState(() {
          isOnline = status == "online";
          isStatusLoading = false;
        });
      } else {
        print('Status tidak ditemukan di response');
        setState(() {
          isStatusLoading = false;
        });
      }
    } else {
      print('Gagal ambil status kurir');
      setState(() {
        isStatusLoading = false;
      });
    }
  }

  Future<void> loadStats() async {
    final fetchedStats = await KurirStatsService.fetchStats(widget.kurirId);
    if (fetchedStats != null) {
      setState(() {
        stats = fetchedStats;
        isLoading = false;
      });
    }
  }

  Future<void> updateKurirStatus(bool isOnline) async {
    final kurirId = widget.kurirId;
    final status = isOnline ? 'online' : 'offline';

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Token tidak ditemukan')),
      );
      return;
    }

    final response = await http.put(
      Uri.parse('http://localhost:8080/api/kurir/status'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'id': kurirId, 'status': status}),
    );

    if (response.statusCode != 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui status')),
      );
    }
    await fetchKurirStatus();
    Navigator.pop(context, true);
  }

  Widget buildStatCard(String title, String value, IconData icon) {
    return Card(
      color: cardColor,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: primaryColor.withOpacity(0.15),
              child: Icon(icon, color: primaryColor),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text("Dashboard Kurir"),
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.redAccent),
            onPressed: () async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text("Hapus Akun Kurir?"),
      content: Text("Apakah kamu yakin ingin menghapus akun ini?"),
      actions: [
        TextButton(
          child: Text("Batal"),
          onPressed: () => Navigator.pop(ctx, false), // BENAR
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          child: Text("Hapus"),
          onPressed: () => Navigator.pop(ctx, true), // BENAR
        ),
      ],
    ),
  );

  if (confirmed == true) {
    final prefs = await SharedPreferences.getInstance();
    final userId = widget.kurirId;
    final token = prefs.getString('token');

    final response = await http.delete(
      Uri.parse('http://localhost:8080/api/users/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Akun berhasil dihapus")),
      );
      Navigator.pop(context, true); // ← Kembali ke halaman sebelumnya dan kirim sinyal berhasil
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal menghapus akun")),
      );
    }
  }
}

          ),
        ],
      ),
      body: (isLoading || isStatusLoading)
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Kurir
                  Text(
                    widget.kurir.nama,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: primaryColor,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Text(
                  //   // "No. HP: ${widget.kurir.noHp}",
                  //   style: const TextStyle(fontSize: 16, color: Colors.white54),
                  // ),
                  // const SizedBox(height: 30),

                  // Statistik
                  buildStatCard(
                    "Pesanan Diproses",
                    "${stats?.pesananDiproses ?? 0}",
                    Icons.sync,
                  ),
                  const SizedBox(height: 16),
                  buildStatCard(
                    "Pesanan Selesai Hari Ini",
                    "${stats?.pesananSelesaiHariIni ?? 0}",
                    Icons.check_circle_outline,
                  ),
                  const SizedBox(height: 16),
                  buildStatCard(
                    "Pendapatan Hari Ini",
                    "Rp${stats?.pendapatanHariIni.toStringAsFixed(0) ?? 0}",
                    Icons.attach_money,
                  ),
                  const SizedBox(height: 16),
                  Card(
                    color: cardColor,
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.toggle_on,
                                      color: primaryColor, size: 28),
                                  const SizedBox(width: 10),
                                  const Text(
                                    "Status Kurir",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              isStatusLoading
                                  ? const CircularProgressIndicator(
                                      color: Colors
                                          .white) // bisa diganti shimmer juga
                                  : Switch(
                                      activeColor: primaryColor,
                                      value: isOnline,
                                      onChanged: (val) {
                                        setState(() {
                                          isOnline = val;
                                        });
                                        updateKurirStatus(val);
                                      },
                                    ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            isOnline ? "Online" : "Offline",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isOnline ? primaryColor : Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
