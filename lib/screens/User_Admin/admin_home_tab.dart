import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'tambah_kurir_page.dart'; // pastikan file ini ada

class AdminHomeTab extends StatefulWidget {
  const AdminHomeTab({super.key});

  @override
  State<AdminHomeTab> createState() => _AdminHomeTabState();
}

class _AdminHomeTabState extends State<AdminHomeTab> {
  int totalProses = 0;
  int totalSelesai = 0;
  List<dynamic> kurirList = [];
  Set<int> activeKurirIds = {};

  bool isLoading = true;
  String errorMsg = '';

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';

      final ordersRes = await http.get(
        Uri.parse('http://localhost:8080/api/orders'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final userRes = await http.get(
        Uri.parse('http://localhost:8080/api/users'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (ordersRes.statusCode == 200 && userRes.statusCode == 200) {
        final ordersData = jsonDecode(ordersRes.body) as List;
        final allUsers = jsonDecode(userRes.body) as List;

        final today = DateTime.now();
        totalSelesai = ordersData.where((e) {
          final tgl = DateTime.tryParse(e['tanggal'] ?? '') ?? DateTime(2000);
          return e['status'] == 'selesai' &&
              tgl.year == today.year &&
              tgl.month == today.month &&
              tgl.day == today.day;
        }).length;

        totalProses = ordersData.where((e) => e['status'] == 'proses').length;

        activeKurirIds = ordersData
            .where((e) => e['status'] == 'proses' && e['kurir_id'] != null)
            .map<int>((e) => e['kurir_id'])
            .toSet();

        kurirList = allUsers.where((u) => u['role'] == 'kurir').toList();

        setState(() {
          isLoading = false;
        });
      } else {
        setState(() {
          errorMsg = 'Gagal mengambil data';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMsg = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDE6029),
        title: const Text(
          "Dashboard Admin",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TambahKurirPage()),
              );
            },
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : errorMsg.isNotEmpty
              ? Center(child: Text(errorMsg, style: const TextStyle(color: Colors.red)))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _summaryCard("Selesai Hari Ini", totalSelesai, Colors.green),
                          const SizedBox(width: 12),
                          _summaryCard("Sedang Proses", totalProses, Colors.orange),
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text("Status Kurir",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      const SizedBox(height: 12),
                      Expanded(
                        child: ListView.builder(
                          itemCount: kurirList.length,
                          itemBuilder: (context, index) {
                            final kurir = kurirList[index];
                            final isOffline = kurir['status'] == 'offline';
                            final isSedangBertugas = !isOffline && activeKurirIds.contains(kurir['id']);
                            final isTersedia = !isOffline && !isSedangBertugas;

                            String statusLabel;
                            Color statusColor;
                            Color statusBackground;

                            if (isOffline) {
                              statusLabel = "Offline";
                              statusColor = Colors.grey;
                              statusBackground = Colors.grey.withOpacity(0.2);
                            } else if (isSedangBertugas) {
                              statusLabel = "Sedang Bertugas";
                              statusColor = Colors.orange;
                              statusBackground = Colors.orange.withOpacity(0.2);
                            } else {
                              statusLabel = "Tersedia";
                              statusColor = Colors.green;
                              statusBackground = Colors.green.withOpacity(0.2);
                            }

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E1E1E),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  )
                                ],
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.person, color: Colors.white70),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      kurir['name'] ?? 'Tanpa Nama',
                                      style: const TextStyle(color: Colors.white, fontSize: 16),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: statusBackground,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      statusLabel,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
    );
  }

  Widget _summaryCard(String label, int value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text('$value',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: color)),
          ],
        ),
      ),
    );
  }
}
