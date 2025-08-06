import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:misi_paket/screens/User_Customer/order_model.dart';
import 'package:misi_paket/screens/User_Customer/pesananDiprosesPage.dart';

class OrderListPage extends StatefulWidget {
  const OrderListPage({Key? key}) : super(key: key);

  @override
  State<OrderListPage> createState() => _OrderListPageState();
}

class _OrderListPageState extends State<OrderListPage> {
  List<OrderSummary> _orders = [];
  bool _isInit = true;
  String _selectedStatus = 'proses';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isInit) {
      _isInit = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        fetchOrders();
      });
    }
  }

  Future<void> fetchOrders() async {
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 150, width: 150, child: Lottie.asset('lib/assets/Fainyetir.json')),
            const SizedBox(height: 12),
            const Text("Lagi cari pesenan kamu ...",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        navigator.pop();
        if (mounted) {
          _showSnackbar("Token tidak ditemukan, silakan login ulang.");
        }
        return;
      }

      final response = await http.get(
        Uri.parse('http://localhost:8080/api/my-orders'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List jsonList = json.decode(response.body);
        final fetchedOrders = jsonList.map((e) => OrderSummary.fromJson(e)).toList();

        if (mounted) {
          setState(() => _orders = fetchedOrders);
        }
      } else {
        _showSnackbar('Gagal memuat pesanan. (${response.statusCode})');
      }
    } catch (_) {
      _showSnackbar("Terjadi kesalahan saat mengambil pesanan.");
    } finally {
      navigator.pop();
    }
  }

  void _showSnackbar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message)),
      );
    }
  }

  IconData getIconForLayanan(String layanan) {
    switch (layanan.toLowerCase()) {
      case 'barang':
        return Icons.inventory;
      case 'makanan':
        return Icons.fastfood;
      case 'sembako':
        return Icons.shopping_bag;
      case 'penumpang':
        return Icons.directions_car;
      default:
        return Icons.local_shipping;
    }
  }

  Color getAccentColor(String layanan) {
    switch (layanan.toLowerCase()) {
      case 'barang':
        return Colors.blue.shade400;
      case 'makanan':
        return Colors.redAccent;
      case 'sembako':
        return Colors.tealAccent.shade400;
      case 'penumpang':
        return Colors.purpleAccent;
      default:
        return Colors.grey.shade300;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredOrders = _orders.where((o) => o.status.toLowerCase() == _selectedStatus).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text("Daftar Pesanan", style: TextStyle(color: Colors.white)),
        actions: [
          _buildFilterButton("Proses", 'proses'),
          _buildFilterButton("Selesai", 'selesai'),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: fetchOrders,
        color: Colors.orange,
        child: filteredOrders.isEmpty
    ? ListView(
        children: [
          const SizedBox(height: 100),
          Image.asset(
            'lib/assets/confused.png',
            height: 200,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 24),
          const Center(
            child: Center(
              child: Text(
                "Kayaknya kamu belum buat pesanan deh",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      )

            : ListView.builder(
                itemCount: filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = filteredOrders[index];
                  return _buildOrderCard(order);
                },
              ),
      ),
    );
  }

  Widget _buildFilterButton(String label, String status) {
    final selected = _selectedStatus == status;
    return TextButton(
      onPressed: () => setState(() => _selectedStatus = status),
      child: Text(
        label,
        style: TextStyle(
          color: selected ? Colors.orangeAccent : Colors.white70,
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  Widget _buildOrderCard(OrderSummary order) {
    final icon = getIconForLayanan(order.layanan);
    final accent = getAccentColor(order.layanan);

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => PesananDiprosesPage(order: order)),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: accent.withOpacity(0.3), width: 1),
          boxShadow: [
            BoxShadow(
              color: accent.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              leading: Icon(icon, color: accent, size: 34),
              title: Text(
                "Layanan: ${order.layanan}",
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text("Status: ${order.status}", style: const TextStyle(color: Colors.white70)),
                  if (order.kurirName != null)
                    Text("Kurir: ${order.kurirName!}", style: const TextStyle(color: Colors.white70)),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38),
            ),
          ),
        ),
      ),
    );
  }
}
