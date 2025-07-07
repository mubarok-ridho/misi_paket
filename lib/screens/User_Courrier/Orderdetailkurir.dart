import 'package:flutter/material.dart';

class OrderDetailKurirPage extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailKurirPage({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final String itemLabel = order['layanan']?.toLowerCase() == 'barang'
        ? 'Nama Barang'
        : order['layanan']?.toLowerCase() == 'makanan'
            ? 'Nama Makanan'
            : 'Catatan';

    return Scaffold(
      backgroundColor: const Color(0xFFF9F9F9),
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        centerTitle: true,
        backgroundColor: Colors.deepOrange,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            headerCard(order),
            const SizedBox(height: 24),
            detailTile(Icons.person, "Nama Customer", order['nama_customer'] ?? "-"),
            detailTile(Icons.local_shipping, "Layanan", order['layanan'] ?? "-"),
            detailTile(Icons.inventory, itemLabel, order['catatan'] ?? "-"),
            detailTile(Icons.location_pin, "Alamat Jemput", order['alamat_jemput'] ?? "-"),
            detailTile(Icons.flag, "Alamat Antar", order['alamat_antar'] ?? "-"),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Navigasi ke Google Maps atau tampilan peta
                    },
                    icon: const Icon(Icons.location_on),
                    label: const Text("Menuju Lokasi Antar"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      // TODO: Logika menyelesaikan pesanan
                    },
                    icon: const Icon(Icons.check_circle),
                    label: const Text("Selesaikan Pesanan"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  // TODO: Navigasi ke halaman chat
                },
                icon: const Icon(Icons.chat, color: Colors.deepOrange),
                label: const Text("Buka Chat",
                    style: TextStyle(
                        color: Colors.deepOrange, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget headerCard(Map<String, dynamic> order) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.shade100,
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 28,
            backgroundColor: Colors.deepOrange,
            child: Icon(Icons.receipt_long, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Pesanan ID",
                    style: TextStyle(fontSize: 13, color: Colors.grey)),
                Text(
                  "#${order['id']}",
                  style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepOrange),
                ),
                const SizedBox(height: 4),
                Text(
                  order['layanan'] ?? "-",
                  style: const TextStyle(fontSize: 14),
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
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.deepOrange),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.grey)),
                const SizedBox(height: 4),
                Text(value,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w500)),
              ],
            ),
          )
        ],
      ),
    );
  }
}
