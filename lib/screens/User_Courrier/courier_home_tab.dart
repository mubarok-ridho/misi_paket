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
        Uri.parse("https://gin-production-77e5.up.railway.app/api/kurir/$kurirId"),
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
        Uri.parse("https://gin-production-77e5.up.railway.app/api/kurir/$kurirId/orders/proses"),
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
        Uri.parse("https://gin-production-77e5.up.railway.app/api/kurir/$kurirId/orders/selesai/today"),
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
        Uri.parse("https://gin-production-77e5.up.railway.app/api/pendapatan/kurir/$kurirId/today"),
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
                _buildMotivationCard(),
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
        color: const Color(0xFF1B2A3A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
  child: Icon(Icons.person, size: 30, color: Colors.white),
            backgroundColor: const Color.fromARGB(255, 167, 96, 4),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Hai, $kurirName",
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationCard() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color.fromARGB(255, 194, 94, 27),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Center(
            child: Text(
              "'Sesungguhnya Allah mencintai mukmin yang bekerja keras.'",
              style: TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(height: 8),
          Center(
            child: Text(
              "HR. Tirmidzi",
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontStyle: FontStyle.italic,
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
              bgColor: const Color(0xFF2E3A59),
              iconColor: const Color(0xFFFFA726),
            ),
            const SizedBox(width: 12),
            _buildSmallCard(
              title: "Selesai Hari Ini",
              value: "$selesaiHariIni",
              icon: Icons.check_circle,
              bgColor: const Color(0xFF3C2F48),
              iconColor: const Color(0xFFFF7043),
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
    required Color bgColor,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Color.fromARGB(255, 255, 133, 81), width: 1), // ini warna outline

        ),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF2C2C2C),
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
        color: const Color(0xFF114455),
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
        const SizedBox(height: 12),
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
              border: Border.all(color: const Color(0xFF00B5D8), width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_shipping, color: Colors.orangeAccent),
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
