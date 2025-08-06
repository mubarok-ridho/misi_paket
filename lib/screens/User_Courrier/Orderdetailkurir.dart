import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:misi_paket/screens/User_Courrier/InputTagihanPage.dart';
import 'package:misi_paket/screens/chat_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OrderDetailKurirPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailKurirPage({super.key, required this.order});

//   Future<bool> cekStatusPembayaran(int orderId) async {
//   // final response = await http.get(Uri.parse('$baseUrl/orders/$orderId/status'));

//   if (response.statusCode == 200) {
//     final data = jsonDecode(response.body);
//     return data['paid'] == true;
//   } else {
//     throw Exception('Gagal cek status pembayaran');
//   }
// }

  Future<Map<String, dynamic>> fetchOrderById(int orderId) async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token') ?? '';

  final response = await http.get(
    Uri.parse('http://localhost:8080/api/orders/$orderId'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Gagal mengambil data order: ${response.statusCode}');
  }
}


  Future<void> completeOrder(
      BuildContext context, int? tagihan, String? metodeBayar) async {
    if (tagihan == null ||
        tagihan == 0 ||
        metodeBayar == null ||
        metodeBayar.isEmpty) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("⚠️ Tidak Bisa Diselesaikan"),
          content: const Text("Tagihan atau metode bayar belum diisi."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK"),
            ),
          ],
        ),
      );
      return;
    }

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
        // Tampilkan dialog animasi
        showDialog(
  context: context,
  builder: (_) => AlertDialog(
    shape: RoundedRectangleBorder(
      side: BorderSide(color: Colors.orange, width: 2),
      borderRadius: BorderRadius.circular(16),
    ),
    backgroundColor: const Color(0xFF1E1E1E), // dark background
    title: const Center(
      child: Text(
        "🎉 Hore ...!",
        style: TextStyle(
          color: Colors.orange,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
    ),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "Kamu udah selesaiin pesanan ini, semangat kerjanya orang baik!",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          width: 200,
          child: Lottie.asset("lib/assets/Faimanuk.json"),
        ),
      ],
    ),
    actionsAlignment: MainAxisAlignment.center,
    actions: [
      TextButton(
        style: TextButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.orange,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        onPressed: () {
          Navigator.pop(context); // Tutup dialog
          Navigator.pop(context, true); // Kembali ke halaman sebelumnya
        },
        child: const Text(
          "Siap!",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ],
  ),
);

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
            // detailTile(Icons.inventory, itemLabel, order['nama_order'] ?? "-"),
            const SizedBox(height: 28),

            // ✅ Tombol Selesaikan Pesanan
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final freshOrder = await fetchOrderById(order['id']);
                      final tagihanRaw = freshOrder['tagihan'];
                      final metode = freshOrder['payment_status'];

                      final tagihan = tagihanRaw is int
                          ? tagihanRaw
                          : int.tryParse(tagihanRaw.toString()) ?? 0;

                      if (tagihan <= 0 || metode == 'pending' || metode.isEmpty) {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Waduh"),
                            content: const Text(
                                "Coba cek lagii deh, kayanya kamu belum input tagihan atau validasi metode bayar."),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                        );
                        return;
                      }

                      await completeOrder(context, tagihan, metode);
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text("Selesaikan Pesanan"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromARGB(255, 190, 116, 18),
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

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 11, 113, 127),
                    foregroundColor: Color.fromARGB(255, 255, 237, 177),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.orangeAccent),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.chat, size: 28),
                  label: const Text(
                    "Buka Chat",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: () async {
                    final orderId = order['id'];
                    final prefs = await SharedPreferences.getInstance();
                    final kurirId = prefs.getInt('userId');
                    final customerId = order['customer_id'];
                    final senderRole = 'kurir';

                    if (orderId == null ||
                        kurirId == null ||
                        customerId == null) {
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
                          userId: kurirId,
                          receiverId: customerId,
                          orderId: orderId,
                          senderRole: senderRole,
                          receiverName: order['nama_customer'] ?? 'Customer',
                          sender: '',
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color.fromARGB(255, 11, 113, 127),
                    foregroundColor: Color.fromARGB(255, 255, 237, 177),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.orangeAccent),
                    ),
                    elevation: 2,
                  ),
                  icon: const Icon(Icons.attach_money, size: 28),
                  label: const Text(
                    "Tagihan",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => InputTagihanPage(orderId: order['id']),
                      ),
                    );
                  },
                ),
              ],
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
            child: Icon(Icons.receipt_long,
                color: Color.fromARGB(255, 255, 255, 255), size: 28),
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
