import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:misi_paket/screens/User_Courrier/InputTagihanPage.dart';
import 'package:misi_paket/screens/chat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderDetailKurirPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailKurirPage({super.key, required this.order});

  Future<void> completeOrder(BuildContext context) async {
    final url = Uri.parse("http://localhost:8080/api/orders/status");
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode({
          "id": order['id'],
          "status": "selesai",
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Pesanan berhasil diselesaikan")),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("❌ Gagal menyelesaikan pesanan: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final String itemLabel = order['layanan']?.toLowerCase() == 'barang'
        ? 'Nama Barang'
        : order['layanan']?.toLowerCase() == 'makanan'
            ? 'Nama Makanan'
            : 'Catatan';

    return Scaffold(
      backgroundColor: const Color(0xFF24313F),
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        centerTitle: true,
        backgroundColor: const Color(0xFF334856),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            headerCard(order),
            const SizedBox(height: 24),

            detailTile(
                Icons.person, "Nama Customer", order['nama_customer'] ?? "-"),
            detailTile(
                Icons.local_shipping, "Layanan", order['layanan'] ?? "-"),
            detailTile(Icons.inventory, itemLabel, order['nama_order'] ?? "-"),
            const SizedBox(height: 28),

            // ✅ Tombol Selesaikan Pesanan
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => completeOrder(context),
                    icon: const Icon(Icons.check_circle),
                    label: const Text("Selesaikan Pesanan"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ✅ Tombol Buka Chat
            Center(
              child: TextButton.icon(
                onPressed: () async {
                  print('🧾 order keys: ${order.keys}');
                  print('📦 order full: $order');
              
                  final orderId = order['id'];
                  final prefs = await SharedPreferences.getInstance();
                  final kurirId = prefs.getInt('userId');
                  final customerId = order['customer_id'];
                  final senderRole = 'kurir';
              
                  print('orderId: $orderId');
                  print('kurirId: $kurirId');
                  print('customerId: $customerId');
                  if (orderId == null || kurirId == null || customerId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content:
                              Text('Gagal membuka chat, data tidak lengkap')),
                    );
                    return;
                  }
              
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ChatPage(
                        userId: kurirId, // user yang sedang login (kurir)
                        receiverId: customerId, // lawan bicara
                        orderId: orderId, // ID pesanan
                        senderRole:senderRole, // untuk backend tahu peran pengirim
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.chat, color: Colors.orangeAccent),
                label: const Text(
                  "Buka Chat",
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // ✅ Tombol Input Tagihan
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => InputTagihanPage(orderId: order['id']),
                    ),
                  );
                  // ScaffoldMessenger.of(context).showSnackBar(
                  //   const SnackBar(
                  //       content: Text("🚧 Fitur Input Tagihan belum tersedia")),
                  // );
                },
                icon:
                    const Icon(Icons.attach_money, color: Colors.orangeAccent),
                label: const Text(
                  "Tagihan",
                  style: TextStyle(
                    color: Colors.orangeAccent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget headerCard(Map<String, dynamic> order) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF334856),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.orange,
            child: Icon(Icons.receipt_long, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Pesanan ID",
                    style: TextStyle(fontSize: 13, color: Colors.white70)),
                Text(
                  "#${order['id']}",
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange),
                ),
                const SizedBox(height: 4),
                Text(
                  "Layanan ${order['layanan'] ?? "-"}",
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget detailTile(IconData icon, String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF334856),
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 5,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.orangeAccent),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: Colors.white70,
                    )),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    )),
              ],
            ),
          )
        ],
      ),
    );
  }
}
