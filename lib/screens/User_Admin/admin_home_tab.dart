import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:misi_paket/models/kurir_model.dart';
import 'package:misi_paket/screens/User_Admin/Kurirdetail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'tambah_kurir_page.dart'; // pastikan file ini ada

class AdminHomeTab extends StatefulWidget {
  const AdminHomeTab({super.key});

  @override
  State<AdminHomeTab> createState() => _AdminHomeTabState();
}

class _AdminHomeTabState extends State<AdminHomeTab> {
  int totalProses = 0;
  int totalSelesai = 0;
  int totalPendapatan = 0;
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
        Uri.parse('https://gin-production-77e5.up.railway.app/api/orders'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final userRes = await http.get(
        Uri.parse('https://gin-production-77e5.up.railway.app/api/users'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final pendapatanRes = await http.get(
        Uri.parse('https://gin-production-77e5.up.railway.app/api/pendapatan/total-all-today'),
        headers: {'Authorization': 'Bearer $token'},
      );

      final selesaiTodayRes = await http.get(
        Uri.parse('https://gin-production-77e5.up.railway.app/api/orders/total-selesai-today'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (ordersRes.statusCode == 200 &&
          userRes.statusCode == 200 &&
          pendapatanRes.statusCode == 200 &&
          selesaiTodayRes.statusCode == 200) {
        final ordersData = jsonDecode(ordersRes.body) as List;
        final allUsers = jsonDecode(userRes.body) as List;
        final pendapatanData = jsonDecode(pendapatanRes.body);
        final selesaiTodayData = jsonDecode(selesaiTodayRes.body);

        totalProses = ordersData.where((e) => e['status'] == 'proses').length;

        activeKurirIds = ordersData
            .where((e) => e['status'] == 'proses' && e['kurir_id'] != null)
            .map<int>((e) => e['kurir_id'])
            .toSet();

        // kurirList = allUsers.where((u) => u['role'] == 'kurir').toList();
        kurirList = allUsers.where((u) => u['role'] == 'kurir' && u['status_kerja'] == 'aktif').toList();


        totalPendapatan = pendapatanData['total_pendapatan'] ?? 0;
        totalSelesai = selesaiTodayData['total_orders_selesai'] ?? 0;

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

  String formatRupiah(int amount) {
    final formatter =
        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    return formatter.format(amount);
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
              ? Center(
                  child: Text(errorMsg,
                      style: const TextStyle(color: Colors.red)))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          _summaryCard(
                              "Selesai Hari Ini", totalSelesai, Colors.green),
                          const SizedBox(width: 12),
                          _summaryCard(
                              "Sedang Proses", totalProses, Colors.orange),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _summaryCard("Pendapatan Hari Ini",
                              formatRupiah(totalPendapatan), Colors.blue),
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
                            final isSedangBertugas = !isOffline &&
                                activeKurirIds.contains(kurir['id']);

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
                              statusBackground =
                                  Colors.orange.withOpacity(0.2);
                            } else {
                              statusLabel = "Tersedia";
                              statusColor = Colors.green;
                              statusBackground =
                                  Colors.green.withOpacity(0.2);
                            }

                            return InkWell(
onTap: () async {
  final result = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => KurirDetailPage(
        kurir: Kurir.fromJson(kurir as Map<String, dynamic>),
        kurirId: kurir['id'],
      ),
    ),
  );

  // Kalau result true (berarti ada update), baru refresh
  if (result == true) {
    setState(() {
      isLoading = true;
    });
    await fetchDashboardData(); // refresh data
  }
},
  child: Container(
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
          padding:
              const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
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

  Widget _summaryCard(String label, dynamic value, Color color) {
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
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w500, color: color)),
          ],
        ),
      ),
    );
  }
}
