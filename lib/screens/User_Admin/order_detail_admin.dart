import 'package:flutter/material.dart';

class AdminOrderDetailPage extends StatelessWidget {
  final dynamic order;

  const AdminOrderDetailPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final customer = order['customer']?['name'] ?? 'Tidak diketahui';
    final kurir = order['kurir']?['name'] ?? 'Belum assigned';
    final layanan = order['layanan'] ?? 'Barang';
    final jemput = order['alamat_jemput'] ?? '-';
    final antar = order['alamat_antar'] ?? '-';

    DateTime createdAt = DateTime.tryParse(order['created_at'] ?? '') ?? DateTime.now();

    final tanggal = "${createdAt.year}-${createdAt.month.toString().padLeft(2, '0')}-${createdAt.day.toString().padLeft(2, '0')}";
    final jam = "${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}";

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        backgroundColor: const Color(0xFFDE6029),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _detailTile('Order ID', '#${order['id']}'),
            _detailTile('Layanan', layanan),
            _detailTile('Customer', customer),
            _detailTile('Kurir', kurir),
            _detailTile('Alamat Jemput', jemput),
            _detailTile('Alamat Antar', antar),
            _detailTile('Tanggal', tanggal),
            _detailTile('Jam', jam),
            _detailTile('Status', order['status']),
          ],
        ),
      ),
    );
  }

  Widget _detailTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ',
              style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500)),
          Expanded(
            child: Text(value,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
          )
        ],
      ),
    );
  }
}
