import 'package:flutter/material.dart';
import 'package:misi_paket/read_only_chat_page.dart';
import 'package:http/http.dart' as http;

class AdminOrderDetailPage extends StatelessWidget {
  final dynamic order;

  const AdminOrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final customer = order['customer']?['name'] ?? 'Tidak diketahui';
    final kurir = order['kurir']?['name'] ?? 'Belum assigned';
    final layanan = order['layanan'] ?? 'Barang';


    DateTime createdAt =
    DateTime.tryParse(order['created_at'] ?? '') ?? DateTime.now();

// Convert dari UTC ke WIB (+7 jam)
final createdAtWIB = createdAt.toUtc().add(Duration(hours: 7));

final tanggal =
    "${createdAtWIB.year}-${createdAtWIB.month.toString().padLeft(2, '0')}-${createdAtWIB.day.toString().padLeft(2, '0')}";
final jam =
    "${createdAtWIB.hour.toString().padLeft(2, '0')}:${createdAtWIB.minute.toString().padLeft(2, '0')}";



    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        backgroundColor: const Color(0xFFDE6029), // branding orange
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              _buildCard('📌 Layanan', layanan),
              _buildCard('👤 Customer', customer),
              _buildCard('🚚 Kurir', kurir),
              _buildCard('📅 Tanggal', tanggal),
              _buildCard('⏰ Jam', jam),
              _buildCard('💰 Nominal Tagihan', 'Rp ${order['nominal'] ?? 'Belum Dikonfirmasi Kurir'}'),
              _buildCard('🟠 Status Pembayaran', order['payment_status'] ?? 'Belum Dikonfirmasi Kurir'),
              _buildCard('💳 Metode Pembayaran', order['metode_bayar'] ?? 'Belum Dikonfirmasi Kurir'),
              _buildCard('🟠 Status', order['status']),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReadOnlyChatPage(
                        orderId: order['id'],
                        customerId: order['customer']['id'],
                        kurirId: order['kurir']['id'],
                      ),
                    ),
                  );
                },
                child: const Text("Lihat Chat"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFDE6029),
                  foregroundColor: Colors.white,
                ),
              ),
              if ((order['status'] ?? '') == 'selesai') ...[
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text("Hapus Chat?"),
                        content: const Text(
                            "Yakin ingin menghapus semua chat untuk pesanan ini?"),
                        actions: [
                          TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Batal")),
                          TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Hapus")),
                        ],
                      ),
                    );

                    if (confirmed != true) return;

                    final response = await http.delete(
                      Uri.parse(
                          "https://gin-production-77e5.up.railway.app/messages/order/${order['id']}"),
                    );

                    if (response.statusCode == 200) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text("✅ Chat berhasil dihapus")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text("❌ Gagal hapus chat: ${response.body}")),
                      );
                    }
                  },
                  icon: const Icon(Icons.delete_forever),
                  label: const Text("Hapus Chat"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ],
          )),
    );
  }

  Widget _buildCard(String title, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white70,
                fontWeight: FontWeight.w500,
              )),
          const SizedBox(height: 4),
          Text(value,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              )),
        ],
      ),
    );
  }
}
