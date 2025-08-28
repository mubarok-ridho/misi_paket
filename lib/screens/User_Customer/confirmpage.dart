import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

import 'package:misi_paket/bloc/order_bloc/order_bloc.dart';
import 'package:misi_paket/bloc/order_bloc/order_state.dart';
import 'package:misi_paket/screens/User_Customer/order_model.dart';
import 'pesananDiprosesPage.dart';

class ConfirmPage extends StatefulWidget {
  final String role;

  const ConfirmPage({super.key, required this.role});

  @override
  State<ConfirmPage> createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage> {
  Future<void> _submitOrder(BuildContext context, OrderLoadedState state) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final userId = prefs.getInt('userId');

    if (token == null || userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Token tidak tersedia. Silakan login ulang.")),
      );
      return;
    }

    _showLoading(context);

    final response = await http.post(
      Uri.parse("https://gin-production-77e5.up.railway.app/api/orders"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode({
        "customer_id": userId,
        "kurir_id": state.kurirId,
        "layanan": widget.role,
        "status": "proses",
      }),
    );

    Navigator.of(context).pop(); // close loading

    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final order = OrderSummary(
        id: data['order_id'],
        customerId: userId,
        layanan: widget.role,
        status: 'proses',
        kurirName: state.namaKurir,
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PesananDiprosesPage(order: order)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengirim pesanan: ${response.body}")),
      );
    }
  }

  void _showLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset('lib/assets/Fainyetir.json', width: 180, height: 180),
            const SizedBox(height: 16),
            const Text("Sedang memproses pesanan...",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text("Mohon tunggu sebentar ya!",
                style: TextStyle(color: Colors.white70)),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }

  String capitalize(String text) {
    return text[0].toUpperCase() + text.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D1B2A),
      appBar: AppBar(
        title: const Text("Konfirmasi Pesanan"),
        backgroundColor: const Color(0xFF1B263B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is! OrderLoadedState) {
            return const Center(child: CircularProgressIndicator(color: Colors.orange));
          }

          return Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Layanan Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B263B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.orange.shade300.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.local_shipping, color: Color(0xFFEF5B2E)),
                      const SizedBox(width: 12),
                      const Text("Layanan:", style: TextStyle(color: Colors.white70)),
                      const Spacer(),
                      Text(
                        capitalize(widget.role),
                        style: const TextStyle(
                          color: Colors.orangeAccent,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
                const Text(
                  "Pesananmu bakal diantar oleh:",
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const SizedBox(height: 12),
                // Kurir Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        backgroundImage: AssetImage('assets/images/kurir1.png'),
                        radius: 28,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(state.namaKurir ?? "-",
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16)),
                        ],
                      )
                    ],
                  ),
                ),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () => _submitOrder(context, state),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEF5B2E),
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text("Order dan Antar Sekarang",
                      style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
