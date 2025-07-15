import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:misi_paket/screens/User_Courrier/Orderdetailkurir.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'order_card.dart';

class CourierOrderTab extends StatefulWidget {
  final int kurirId;

  const CourierOrderTab({super.key, required this.kurirId});

  @override
  State<CourierOrderTab> createState() => _CourierOrderTabState();
}

class _CourierOrderTabState extends State<CourierOrderTab> {
  List<dynamic> orders = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final url = Uri.parse(
          "http://localhost:8080/api/kurir/${widget.kurirId}/orders");
      final response = await http.get(
        url,
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          orders = jsonDecode(response.body);
          isLoading = false;
        });
      } else {
        print("❌ Gagal ambil order: ${response.statusCode} ${response.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF24313F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.orange),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Pesanan Masuk",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (orders.isEmpty)
                      const Text(
                        "Belum ada pesanan aktif.",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ...orders.map((order) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  OrderDetailKurirPage(order: order),
                            ),
                          );
                        },
                        child: OrderCard(
                          orderId: "#${order['id']}",
                          type: order['layanan'] ?? "-",
                          customerName: order['nama_customer'] ?? "-",
                          pickup: order['alamat_jemput'] ?? '-',
                          destination: order['alamat_antar'] ?? '-',
                          distance: "-", // opsional
                          status: order['status'] ?? '-',
                          statusColor: getStatusColor(order['status']),
                        ),
                      );
                    }).toList(),
                  ],
                ),
        ),
      ),
    );
  }

  Color getStatusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'proses':
        return Colors.orange;
      case 'selesai':
        return Colors.green;
      case 'batal':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
