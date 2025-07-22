import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';

class CourierHomeTab extends StatefulWidget {
  const CourierHomeTab({super.key});

  @override
  State<CourierHomeTab> createState() => _CourierHomeTabState();
}

class _CourierHomeTabState extends State<CourierHomeTab> with RouteAware {
  String kurirName = "Kurir";
  int selesaiHariIni = 0;
  int prosesHariIni = 0;
  int totalPendapatan = 0;
  List<dynamic> orders = [];

  int? kurirId;
  String? token;

  @override
  void initState() {
    super.initState();
    initPrefsAndFetch();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    initPrefsAndFetch();
  }

  Future<void> initPrefsAndFetch() async {
    final prefs = await SharedPreferences.getInstance();
    kurirId = prefs.getInt('userId');
    token = prefs.getString('token');

    if (kurirId != null && token != null) {
      await Future.wait([
        fetchKurirProfile(),
        fetchOrdersProses(),
        fetchOrdersSelesaiToday(),
        fetchPendapatanToday(),
      ]);
    }
  }

  Future<void> fetchKurirProfile() async {
    try {
      final res = await http.get(
        Uri.parse("http://localhost:8080/api/kurir/$kurirId"),
        headers: {"Authorization": "Bearer $token"},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final user = data['user'];
        if (user != null && user['name'] != null) {
          setState(() {
            kurirName = user['name'];
          });
        }
      }
    } catch (_) {}
  }

  Future<void> fetchOrdersProses() async {
    try {
      final res = await http.get(
        Uri.parse("http://localhost:8080/api/kurir/$kurirId/orders/proses"),
        headers: {"Authorization": "Bearer $token"},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          prosesHariIni = data.length;
          orders = data;
        });
      }
    } catch (_) {}
  }

  Future<void> fetchOrdersSelesaiToday() async {
    try {
      final res = await http.get(
        Uri.parse("http://localhost:8080/api/kurir/$kurirId/orders/selesai/today"),
        headers: {"Authorization": "Bearer $token"},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          selesaiHariIni = data.length;
        });
      }
    } catch (_) {}
  }

  Future<void> fetchPendapatanToday() async {
    try {
      final res = await http.get(
        Uri.parse("http://localhost:8080/api/pendapatan/kurir/$kurirId/today"),
        headers: {"Authorization": "Bearer $token"},
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          totalPendapatan = (data['total_pendapatan'] as num).toInt();
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: initPrefsAndFetch,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(),
                const SizedBox(height: 24),
                _buildStatusCards(),
                const SizedBox(height: 24),
                _buildActivityList(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color.fromARGB(255, 135, 18, 18), Color.fromARGB(255, 131, 31, 31)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.motorcycle, color: Color(0xFFE23D19), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              "Hai, $kurirName",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCards() {
    return Column(
      children: [
        Row(
          children: [
            _buildSmallCard(
              title: "Diproses",
              value: "$prosesHariIni",
              icon: Icons.timelapse,
              bgColor: Color.fromARGB(255, 13, 99, 186),
              iconColor: Color.fromARGB(255, 231, 104, 0),
            ),
            const SizedBox(width: 12),
            _buildSmallCard(
              title: "Selesai Hari Ini",
              value: "$selesaiHariIni",
              icon: Icons.check_circle,
              bgColor: Color.fromARGB(255, 4, 94, 81),
              iconColor: Color.fromARGB(255, 231, 104, 0),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildIncomeCard(),
      ],
    );
  }

  Widget _buildSmallCard({
  required String title,
  required String value,
  required IconData icon,
  required Color bgColor, // Tidak dipakai, tapi tetap disimpan kalau mau fleksibel
  required Color iconColor,
}) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.all(2), // Border thickness
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFA726), Color(0xFFEF6C00)], // Oranye terang ke oranye gelap
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C), // Abu tua
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Icon(icon, color: iconColor, size: 35),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}


  Widget _buildIncomeCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color.fromARGB(255, 11, 68, 53), Color.fromARGB(255, 16, 117, 158)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.attach_money, color: Colors.white, size: 30),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Pendapatan Hari Ini", style: TextStyle(color: Colors.white70)),
              Text("Rp$totalPendapatan",
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Aktivitas Terkini",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
        const SizedBox(height: 12),
        if (orders.isEmpty)
          const Text("Belum ada aktivitas terkini.", style: TextStyle(color: Colors.white60)),
        ...orders.take(5).map((order) {
          final customerName = order['nama_customer'] ?? 'Tidak diketahui';
          final layanan = order['layanan'] ?? '-';
          final layananFormatted = "Layanan ${capitalize(layanan)}";

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1C1C1C),
              border: Border.all(color: const Color(0xFFE23D19), width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_shipping, color: Colors.orange),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Customer: $customerName",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(layananFormatted, style: const TextStyle(color: Colors.white70, fontSize: 13)),
                    ],
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  String capitalize(String input) {
    if (input.isEmpty) return input;
    return input[0].toUpperCase() + input.substring(1);
  }
}
