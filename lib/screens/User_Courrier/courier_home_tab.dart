import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'activity_item.dart';
import 'status_card.dart';

class CourierHomeTab extends StatefulWidget {
  const CourierHomeTab({super.key});

  @override
  State<CourierHomeTab> createState() => _CourierHomeTabState();
}

class _CourierHomeTabState extends State<CourierHomeTab> {
  bool isOnline = true;
  String kurirName = "Kurir";
  int selesaiHariIni = 0;
  List<dynamic> orders = [];

  @override
  void initState() {
    super.initState();
    fetchKurirProfile();
    fetchOrdersForKurir();
    fetchCompletedOrdersToday(); // opsional
  }

  Future<void> fetchKurirProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final kurirId = prefs.getInt('userId');
    final token = prefs.getString('token');

    if (kurirId != null && token != null) {
      try {
        final res = await http.get(
          Uri.parse("http://localhost:8080/api/kurir/$kurirId"),
          headers: {"Authorization": "Bearer $token"},
        );

        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          setState(() {
            kurirName = data['user']['name'];
          });
        }
      } catch (e) {
        print("❌ Gagal ambil data kurir: $e");
      }
    }
  }

Future<void> fetchOrdersForKurir() async {
  final prefs = await SharedPreferences.getInstance();
  final kurirId = prefs.getInt('userId');
  final token = prefs.getString('token');

  if (kurirId != null && token != null) {
    try {
      final response = await http.get(
        Uri.parse("http://localhost:8080/api/kurir/$kurirId/orders"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          orders = jsonDecode(response.body);
        });
      } else {
        print("❌ Gagal ambil data order: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      print("❌ Error ambil order: $e");
    }
  }
}


  Future<void> fetchCompletedOrdersToday() async {
    setState(() {
      selesaiHariIni = 4; // dummy untuk sementara
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Colors.orangeAccent,
                  child: Icon(Icons.motorcycle, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Selamat Datang, $kurirName",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 16)),
                    Text("Status: ${isOnline ? 'Online' : 'Offline'}",
                        style: TextStyle(
                            color: isOnline ? Colors.green : Colors.red,
                            fontSize: 12)),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isOnline ? Colors.green : Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isOnline ? "ONLINE" : "OFFLINE",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              ],
            ),

            const SizedBox(height: 20),

            // SELESAI HARI INI
            StatusCard(
              title: "Selesai Hari Ini",
              value: selesaiHariIni.toString(),
              icon: Icons.check_circle,
              color: Colors.green,
            ),

            const SizedBox(height: 20),

            // STATUS KERJA
            const Text("Status Kerja",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Status Online",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      Text(
                        isOnline
                            ? "Anda sedang menerima pesanan"
                            : "Anda tidak menerima pesanan",
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: isOnline,
                    onChanged: (value) {
                      setState(() {
                        isOnline = value;
                      });
                    },
                    activeColor: Colors.green,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            const Text("Aktivitas Terkini",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),

            if (orders.isEmpty)
              const Text("Belum ada aktivitas terkini."),
            ...orders.take(3).map((order) {
              return ActivityItem(
                title: "Pesanan #${order['id']} Dalam Proses",
                subtitle: order['layanan'] ?? "-",
                time: "Baru saja", // Bisa pakai timestamp kalau ada
                icon: Icons.local_shipping,
                color: const Color(0xFFDE6029),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
