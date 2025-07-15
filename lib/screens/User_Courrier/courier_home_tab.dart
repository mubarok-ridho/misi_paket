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
  bool isOnline = true;
  String kurirName = "Kurir";
  int selesaiHariIni = 0;
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

    await fetchKurirProfile();
    await fetchOrdersForKurir();
    await fetchCompletedOrdersToday();
  }

  Future<void> fetchKurirProfile() async {
    if (kurirId == null || token == null) return;

    try {
      final res = await http.get(
        Uri.parse("http://localhost:8080/api/kurir/$kurirId"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          kurirName = data['user']['name'];
          isOnline = data['user']['status'] == 'online';
        });
      } else {
        print("❌ Gagal ambil data kurir: ${res.body}");
      }
    } catch (e) {
      print("❌ Gagal ambil data kurir: $e");
    }
  }

  Future<void> fetchOrdersForKurir() async {
    if (kurirId == null || token == null) return;

    try {
      final response = await http.get(
        Uri.parse("http://localhost:8080/api/kurir/$kurirId/orders"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        setState(() {
          orders = jsonDecode(response.body);
        });
      } else {
        print("❌ Gagal ambil data order: ${response.body}");
      }
    } catch (e) {
      print("❌ Error ambil order: $e");
    }
  }

  Future<void> fetchCompletedOrdersToday() async {
    setState(() {
      selesaiHariIni = 4; // dummy
    });
  }

  Future<void> _updateKurirStatus(bool online) async {
    if (kurirId == null || token == null) return;

    try {
      final response = await http.put(
        Uri.parse("http://localhost:8080/api/kurir/status"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: jsonEncode({"id": kurirId, "status": online ? "online" : "offline"}),
      );

      if (response.statusCode == 200) {
        print("✅ Status berhasil diupdate");
      } else {
        print("❌ Gagal update status: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("❌ Error update status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF24313F),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(),
              const SizedBox(height: 20),
              _buildStatusCard(),
              const SizedBox(height: 20),
              _buildStatusSwitch(),
              const SizedBox(height: 24),
              _buildActivityList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF334856),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Colors.orange,
            radius: 30,
            child: Icon(Icons.motorcycle, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Hai, $kurirName",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
              Row(
                children: [
                  Icon(Icons.circle,
                      color: isOnline ? Colors.green : Colors.red, size: 10),
                  const SizedBox(width: 6),
                  Text(
                    isOnline ? "Online" : "Offline",
                    style: const TextStyle(fontSize: 13, color: Colors.white70),
                  ),
                ],
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: isOnline ? Colors.green : Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isOnline ? "ONLINE" : "OFFLINE",
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF3E5568),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Pesanan Selesai Hari Ini",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.white70)),
              Text("$selesaiHariIni pesanan",
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildStatusSwitch() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF334856),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Status Kurir",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
              Text(
                isOnline
                    ? "Anda sedang menerima pesanan"
                    : "Tidak menerima pesanan",
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ],
          ),
          Switch(
            value: isOnline,
            onChanged: (value) async {
              setState(() => isOnline = value);
              await _updateKurirStatus(value);
            },
            activeColor: Colors.green,
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
        ...orders.take(3).map((order) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF334856),
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
                      Text("Pesanan #${order['id']}",
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(order['layanan'] ?? "-",
                          style: const TextStyle(color: Colors.white70, fontSize: 13)),
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
}
