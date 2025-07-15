import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:misi_paket/bloc/order_bloc/order_bloc.dart';
import 'package:misi_paket/bloc/order_bloc/order_state.dart';
import 'package:misi_paket/screens/User_Customer/order_model.dart';
import 'package:lottie/lottie.dart';
import 'pesananDiprosesPage.dart';

class ConfirmPage extends StatefulWidget {
  final String role;

  const ConfirmPage({super.key, required this.role});

  @override
  State<ConfirmPage> createState() => _ConfirmPageState();
}

class _ConfirmPageState extends State<ConfirmPage> {
  final TextEditingController catatanController = TextEditingController();

  @override
  void dispose() {
    catatanController.dispose();
    super.dispose();
  }

  void showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Lottie.asset(
              'lib/assets/Fainyetir.json',
              width: 200,
              height: 200,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 16),
            const Text(
              "Sedang memproses pesanan...",
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              "Mohon tunggu sebentar ya!",
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

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

    showLoadingDialog(context);

    final url = Uri.parse("http://localhost:8080/api/orders");

    final payload = {
      "customer_id": userId,
      "kurir_id": state.kurirId,
      "alamat_jemput": state.alamatJemput,
      "alamat_antar": state.alamatAntar,
      "layanan": widget.role,
      "nama_barang": state.namaBarang,
      "nama_makanan": state.namaMakanan,
      "nama_penumpang": state.namaPenumpang,
      "catatan": catatanController.text,
      "status": "proses",
      "lat_jemput": state.lokasiJemput?.latitude,
      "lng_jemput": state.lokasiJemput?.longitude,
      "lat_antar": state.lokasiAntar?.latitude,
      "lng_antar": state.lokasiAntar?.longitude,
    };

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(payload),
    );

    Navigator.of(context).pop(); // Tutup loading

    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = jsonDecode(response.body);
      final orderBaru = OrderSummary(
        id: responseData['order_id'],
        customerId: userId,
        alamatJemput: state.alamatJemput ?? "-",
        alamatAntar: state.alamatAntar ?? "-",
        layanan: widget.role,
        status: 'proses',
        namaBarang: state.namaBarang,
        namaMakanan: state.namaMakanan,
        lokasiJemput: state.lokasiJemput,
        lokasiAntar: state.lokasiAntar,
        kurirId: state.kurirId!,
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PesananDiprosesPage(order: orderBaru)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mengirim pesanan: ${response.body}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Konfirmasi Pesanan"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is! OrderLoadedState) {
            return const Center(child: CircularProgressIndicator());
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildKurirInfo(state),
              const SizedBox(height: 16),
              _buildAlamatCard("Jemput", state.alamatJemput ?? "-"),
              const SizedBox(height: 10),
              _buildAlamatCard("Antar", state.alamatAntar ?? "-"),
              const SizedBox(height: 20),
              _buildLayananDetail(state),
              if (widget.role == 'penumpang') ...[
                const SizedBox(height: 12),
                TextField(
                  controller: catatanController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    labelText: 'Catatan Tambahan',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                )
              ],
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: () => _submitOrder(context, state),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.check, color: Colors.white),
                label: const Text("Order dan Antar Sekarang", style: TextStyle(color: Colors.white)),
              )
            ],
          );
        },
      ),
    );
  }

  Widget _buildKurirInfo(OrderLoadedState state) {
    return Card(
      color: const Color(0xFF1C1B33),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: const CircleAvatar(
          backgroundImage: AssetImage('assets/images/kurir1.png'),
          radius: 26,
        ),
        title: Text(state.namaKurir ?? "-", style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(state.noHpKurir ?? "-", style: const TextStyle(color: Colors.white70)),
      ),
    );
  }

  Widget _buildAlamatCard(String label, String alamat) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.deepOrange.shade100),
      ),
      child: Row(
        children: [
          Icon(Icons.location_on, color: Colors.deepOrange),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(alamat, style: const TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLayananDetail(OrderLoadedState state) {
    final TextStyle labelStyle = TextStyle(fontSize: 14, color: Colors.grey.shade700);
    final TextStyle valueStyle = const TextStyle(fontSize: 15, fontWeight: FontWeight.w600);

    if (widget.role == 'barang') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Barang", style: labelStyle),
          Text("${state.namaBarang} (${state.ukuran})", style: valueStyle),
          const SizedBox(height: 6),
          Text("Catatan: ${state.catatanBarang ?? '-'}", style: labelStyle),
        ],
      );
    } else if (widget.role == 'makanan') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Makanan", style: labelStyle),
          Text(state.namaMakanan ?? "-", style: valueStyle),
          const SizedBox(height: 6),
          Text("Catatan: ${state.catatanMakanan ?? '-'}", style: labelStyle),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Penumpang", style: labelStyle),
          Text(state.namaPenumpang ?? "-", style: valueStyle),
          const SizedBox(height: 6),
          Text("Tujuan: ${state.tujuan ?? '-'}", style: labelStyle),
        ],
      );
    }
  }
}