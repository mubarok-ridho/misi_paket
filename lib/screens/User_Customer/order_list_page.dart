import 'package:flutter/material.dart';
import 'package:misi_paket/screens/User_Customer/order_model.dart';
import 'package:misi_paket/screens/User_Customer/order_service.dart';
import 'package:misi_paket/screens/User_Customer/pesananDiprosesPage.dart';

class OrderListPage extends StatelessWidget {
  const OrderListPage({super.key});

  IconData _getIconByService(String layanan) {
    switch (layanan.toLowerCase()) {
      case 'makanan':
        return Icons.fastfood;
      case 'barang':
        return Icons.inventory_2;
      case 'penumpang':
        return Icons.directions_car;
      default:
        return Icons.local_shipping;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'proses':
        return Colors.orangeAccent;
      case 'selesai':
        return Colors.greenAccent.shade400;
      case 'dibatalkan':
        return Colors.redAccent;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF24313F),
      appBar: AppBar(
        title: const Text('Pesanan Aktif'),
        backgroundColor: const Color(0xFF334856),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
        shadowColor: Colors.black26,
      ),
      body: FutureBuilder<List<OrderSummary>>(
        future: fetchCustomerOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.orangeAccent));
          } else if (snapshot.hasError) {
            return Center(child: Text('❌ ${snapshot.error}', style: const TextStyle(color: Colors.white)));
          }

          final orders = snapshot.data ?? [];
          if (orders.isEmpty) {
            return const Center(
              child: Text(
                'Belum ada pesanan aktif.',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white70),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final isiOrder = order.namaMakanan ??
                  order.namaBarang ??
                  (order.layanan == "penumpang"
                      ? "Layanan Penumpang"
                      : "Pesanan");

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PesananDiprosesPage(order: order),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3C4A57),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.orange.withOpacity(0.1),
                        child: Icon(
                          _getIconByService(order.layanan),
                          color: Colors.orangeAccent,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isiOrder,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              order.alamatAntar,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timelapse,
                            color: _getStatusColor(order.status),
                            size: 20,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            order.status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _getStatusColor(order.status),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
