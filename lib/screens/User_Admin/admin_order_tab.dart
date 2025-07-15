import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'order_detail_admin.dart'; // pastikan file ini ada

class AdminOrderTab extends StatefulWidget {
  const AdminOrderTab({super.key});

  @override
  State<AdminOrderTab> createState() => _AdminOrderTabState();
}

class _AdminOrderTabState extends State<AdminOrderTab> {
  List<dynamic> allOrders = [];
  bool showSelesai = false;
  bool isLoading = true;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final res = await http.get(
        Uri.parse('http://localhost:8080/api/orders'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        setState(() {
          allOrders = data;
          isLoading = false;
        });
      } else {
        throw Exception('Gagal memuat data');
      }
    } catch (e) {
      print('Error fetching orders: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyword = searchController.text.toLowerCase();

    final filteredOrders = allOrders.where((order) {
      final customer = (order['customer']?['name'] ?? '').toLowerCase();
      final layanan = (order['layanan'] ?? '').toLowerCase();
      final idMatch = '#${order['id']}'.contains(keyword);
      final custMatch = customer.contains(keyword);
      final layMatch = layanan.contains(keyword);
      final statusMatch =
          showSelesai ? order['status'] == 'selesai' : order['status'] != 'selesai';
      return statusMatch && (idMatch || custMatch || layMatch);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFFDE6029),
        centerTitle: true,
        title: const Text(
          'Semua Order',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(
            color: const Color(0xFF1E1E1E),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              children: [
                TextField(
                  controller: searchController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    hintText: 'Cari Order ID / Customer / Layanan',
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Colors.orange),
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Tampilkan:',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    Row(
                      children: [
                        Switch.adaptive(
                          value: showSelesai,
                          activeColor: Colors.orange,
                          onChanged: (val) => setState(() => showSelesai = val),
                        ),
                        Text(showSelesai ? 'Selesai' : 'Proses',
                            style: const TextStyle(
                                color: Colors.white, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: Colors.orange),
                  )
                : ListView.builder(
                    itemCount: filteredOrders.length,
                    itemBuilder: (context, index) {
                      final order = filteredOrders[index];
                      final customer = order['customer']?['name'] ?? 'Tidak diketahui';
                      final jenis = order['layanan'] ?? 'Barang';
                      final createdAtStr = order['created_at'] ?? '';
                      final status = order['status'];

                      // Format tanggal dan jam
                      DateTime createdAt =
                          DateTime.tryParse(createdAtStr) ?? DateTime.now();
                      String tanggal =
                          "${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}";
                      String jam =
                          "${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}";

                      Color statusColor =
                          status == 'selesai' ? Colors.green : Colors.orange;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AdminOrderDetailPage(order: order),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
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
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            leading:
                                const Icon(Icons.receipt, color: Colors.orange),
                            title: Text(
                              'Order #${order['id']} - $jenis',
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 4),
                                Text('Customer: $customer',
                                    style: const TextStyle(
                                        color: Colors.white70, fontSize: 13)),
                                Text('Tanggal: $tanggal',
                                    style: const TextStyle(
                                        color: Colors.white54, fontSize: 12)),
                                Text('Jam: $jam',
                                    style: const TextStyle(
                                        color: Colors.white38, fontSize: 12)),
                              ],
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: statusColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                status,
                                style: TextStyle(
                                    color: statusColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
