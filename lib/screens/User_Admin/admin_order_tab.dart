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
  String selectedDateFilter = 'Hari ini'; // default
  final List<String> dateFilters = ['Hari ini', '7 Hari', '30 Hari'];
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
        Uri.parse('https://gin-production-77e5.up.railway.app/api/orders'),
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
      final kurir =
          (order['kurir']?['name'] ?? '').toLowerCase(); // tambahkan ini
      final kurirMatch = kurir.contains(keyword); // dan ini
      final customer = (order['customer']?['name'] ?? '').toLowerCase();
      final layanan = (order['layanan'] ?? '').toLowerCase();
      final idMatch = '#${order['id']}'.contains(keyword);
      final custMatch = customer.contains(keyword);
      final layMatch = layanan.contains(keyword);
      final statusMatch = showSelesai
          ? order['status'] == 'selesai'
          : order['status'] != 'selesai';

      final createdAtStr = order['created_at'] ?? '';
      final createdAt =
          DateTime.tryParse(createdAtStr)?.toUtc().add(Duration(hours: 7)) ??
              DateTime.now();

      bool dateMatch = false;
      final now = DateTime.now();

      if (selectedDateFilter == 'Hari ini') {
        dateMatch = createdAt.year == now.year &&
            createdAt.month == now.month &&
            createdAt.day == now.day;
      } else if (selectedDateFilter == '7 Hari') {
        dateMatch = createdAt.isAfter(now.subtract(Duration(days: 6)));
      } else if (selectedDateFilter == '30 Hari') {
        dateMatch = createdAt.isAfter(now.subtract(Duration(days: 29)));
      }

      return statusMatch &&
          dateMatch &&
          (idMatch || custMatch || layMatch || kurirMatch);
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
                    hintText: 'Cari Order ID / Customer / Layanan / Kurir',
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
                    const Text('Filter Waktu:',
                        style: TextStyle(color: Colors.white, fontSize: 16)),
                    DropdownButton<String>(
                      value: selectedDateFilter,
                      dropdownColor: const Color(0xFF2A2A2A),
                      style: const TextStyle(color: Colors.white),
                      underline: Container(),
                      items: dateFilters.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            selectedDateFilter = value;
                          });
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Status:',
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
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
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
                      final createdAtStr = order['created_at'] ?? '';
                      final createdAt = DateTime.tryParse(createdAtStr)
                              ?.toUtc()
                              .add(Duration(hours: 7)) ??
                          DateTime.now();

                      // final customer = order['customer']?['name'] ?? 'Tidak diketahui';
                      final kurir = order['kurir']?['name'] ?? 'Belum assigned';
                      final jenis = order['layanan'] ?? 'Barang';
                      final status = order['status'];

// Convert UTC → WIB (+7 jam)
                      final createdAtWIB =
                          createdAt.toUtc().add(Duration(hours: 7));

                      String tanggal =
                          "${createdAtWIB.year}-${createdAtWIB.month.toString().padLeft(2, '0')}-${createdAtWIB.day.toString().padLeft(2, '0')}";
                      String jam =
                          "${createdAtWIB.hour.toString().padLeft(2, '0')}:${createdAtWIB.minute.toString().padLeft(2, '0')}";

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
                                Text('Kurir: $kurir',
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
