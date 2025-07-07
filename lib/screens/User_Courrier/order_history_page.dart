import 'package:flutter/material.dart';
import 'order_history_item.dart';
import 'order_history_card.dart';

class OrderHistoryPage extends StatelessWidget {
  final List<OrderHistoryItem> orderHistory = [
    OrderHistoryItem(
      orderId: "#OH001",
      type: "Makanan",
      customerName: "Andi Wijaya",
      destination: "Jl. Rawa Bebek No. 15",
      date: "17 Jun 2025",
      time: "14:30",
      status: "Selesai",
      statusColor: Colors.green,
    ),
    OrderHistoryItem(
      orderId: "#OH002",
      type: "Barang",
      customerName: "Siti Nurhaliza",
      destination: "Apartemen Mediterania",
      date: "17 Jun 2025",
      time: "12:15",
      status: "Selesai",
      statusColor: Colors.green,
    ),
    OrderHistoryItem(
      orderId: "#OH003",
      type: "Penumpang",
      customerName: "Budi Santoso",
      destination: "Stasiun Kemayoran",
      date: "16 Jun 2025",
      time: "18:45",
      status: "Dibatalkan",
      statusColor: Colors.red,
    ),
    OrderHistoryItem(
      orderId: "#OH004",
      type: "Makanan",
      customerName: "Lisa Permata",
      destination: "Jl. Kemang Raya No. 88",
      date: "16 Jun 2025",
      time: "16:20",
      status: "Selesai",
      statusColor: Colors.green,
    ),
    OrderHistoryItem(
      orderId: "#OH005",
      type: "Barang",
      customerName: "Ahmad Fauzi",
      destination: "Mall Grand Indonesia",
      date: "15 Jun 2025",
      time: "11:30",
      status: "Selesai",
      statusColor: Colors.green,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Riwayat Pesanan"),
        backgroundColor: const Color(0xFF334856),
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Kartu Total
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFDE6029), Color(0xFFD2785C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text("Total Pesanan",
                        style: TextStyle(color: Colors.white70, fontSize: 12)),
                    Text("127",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              const SizedBox(height: 16),
              const Text("Riwayat Pesanan",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // List Riwayat
              Expanded(
                child: ListView.builder(
                  itemCount: orderHistory.length,
                  itemBuilder: (context, index) {
                    return OrderHistoryCard(orderHistory: orderHistory[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
