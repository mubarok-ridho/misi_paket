import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:misi_paket/screens/User_Customer/CustomerTagihanPage.dart';
import 'package:misi_paket/screens/chat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:misi_paket/screens/User_Customer/customer.dart';
import 'package:misi_paket/screens/User_Customer/order_model.dart';

class PesananDiprosesPage extends StatefulWidget {
  final OrderSummary order;

  const PesananDiprosesPage({super.key, required this.order});

  @override
  State<PesananDiprosesPage> createState() => _PesananDiprosesPageState();
}

class _PesananDiprosesPageState extends State<PesananDiprosesPage> {
  String? _kurirName;
  String? _kendaraan;
  int? _pesananAktif;
  int? _kurirId;

  @override
  void initState() {
    super.initState();
    _fetchKurirDetail();
  }

  Future<void> _fetchKurirDetail() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null) return;

  final url = Uri.parse("http://localhost:8080/api/orders/${widget.order.id}");
  final response = await http.get(url, headers: {
    "Authorization": "Bearer $token",
  });

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    final kurirData = data['kurir'];

    // ✅ Ambil dan simpan user_id ke shared preferences
    final userIdFromApi = data['user_id'];
    if (userIdFromApi != null) {
      await prefs.setInt('user_id', userIdFromApi);
      print("DEBUG: user_id dari API disimpan: $userIdFromApi");
    }

    if (kurirData != null) {
      setState(() {
        _kurirName = kurirData['name'];
        _kendaraan = kurirData['vehicle'];
        _pesananAktif = kurirData['active_orders'];
        _kurirId = kurirData['id'];
      });
    } else {
      print("DEBUG: kurirData null");
    }
  } else {
    print("DEBUG: Failed to fetch kurir data. Status: ${response.statusCode}");
  }
}


  void _navigateToDashboard(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const CustomerDashboard()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _navigateToDashboard(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF24313F),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1C1B33),
          foregroundColor: Colors.white,
          title: const Text('Pesanan Diproses'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_kurirName != null) _buildKurirInfo(),
              const SizedBox(height: 24),
              _buildDetailInfo("Jenis Layanan", widget.order.layanan),
              const SizedBox(height: 32),

              // Tombol Chat
              ElevatedButton.icon(
  onPressed: () async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt('user_id');
    final token = prefs.getString('token');
    final senderName = prefs.getString('user_name'); // pastikan disimpan saat login
    final senderRole = 'customer';
print("DEBUG userId: $userId");
print("DEBUG token: $token");
print("DEBUG senderName: $senderName");
print("DEBUG kurirId: $_kurirId");
print("DEBUG kurirName: $_kurirName");

    if (userId != null && token != null  && _kurirId != null && _kurirName != null) {
      Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ChatPage(
      userId: userId,
      receiverId: _kurirId!,
      orderId: widget.order.id,
            senderRole: senderRole,
          ),
        ),
      );
    } else {
      print("DEBUG: Data tidak lengkap untuk membuka chat");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Gagal membuka chat: data tidak lengkap")),
      );
    }
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFFFF7E30),
    minimumSize: const Size.fromHeight(50),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  icon: const Icon(Icons.chat),
  label: const Text("Buka Chat dengan Kurir"),
),

              const SizedBox(height: 12),

              // Tombol Lihat Tagihan
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => CustomerTagihanPage(orderId: widget.order.id),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1C1B33),
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.receipt_long),
                label: const Text("Lihat Tagihan"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildKurirInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF32414E),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor: Colors.orangeAccent,
            child: Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Pesananmu bakal diantar sama:",
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
                const SizedBox(height: 6),
                Text(
                  _kurirName ?? "-",
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Kendaraan: $_kendaraan",
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
                Text(
                  "Pesanan aktif: $_pesananAktif",
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailInfo(String label, String? value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2F3B48),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.deepOrange.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.local_shipping, color: Colors.orangeAccent),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(height: 4),
              Text(value ?? "-", style: const TextStyle(color: Colors.white, fontSize: 15)),
            ],
          ),
        ],
      ),
    );
  }
}
