import 'package:flutter/material.dart';
import 'package:misi_paket/read_only_chat_page.dart';

class AdminOrderDetailPage extends StatelessWidget {
  final dynamic order;

  const AdminOrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final customer = order['customer']?['name'] ?? 'Tidak diketahui';
    final kurir = order['kurir']?['name'] ?? 'Belum assigned';
    final layanan = order['layanan'] ?? 'Barang';
    // final jemput = order['alamat_jemput'] ?? '-';
    // final antar = order['alamat_antar'] ?? '-';

    DateTime createdAt = DateTime.tryParse(order['created_at'] ?? '') ?? DateTime.now();
    final tanggal = "${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}";
    final jam = "${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}";

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
        child: 
ListView(
  children: [
    _buildCard('📌 Layanan', layanan),
    _buildCard('👤 Customer', customer),
    _buildCard('🚚 Kurir', kurir),
    _buildCard('📅 Tanggal', tanggal),
    _buildCard('⏰ Jam', jam),
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

  ],
)

      ),
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
