import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:misi_paket/bloc/order_bloc/order_bloc.dart';
import 'package:misi_paket/bloc/order_bloc/order_state.dart';

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

    final url = Uri.parse("http://localhost:8080/api/orders");
    final payload = {
      "customer_id": userId,
      "kurir_id": state.kurirId,
      "alamat_jemput": state.alamatJemput,
      "alamat_antar": state.alamatAntar,
      "nama_barang": state.namaBarang,
      "nama_makanan": state.namaMakanan,
      "catatan": catatanController.text,
      "layanan": widget.role,
      "status": "proses",
    };

    print("📦 JSON yang dikirim: ${jsonEncode(payload)}");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(payload),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      // ✅ Redirect ke halaman PesananDiproses setelah sukses
      Navigator.pushNamedAndRemoveUntil(
        context,
        "/pesanan-diproses",
        (route) => false,
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
        elevation: 0,
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoadedState) {
            final namaKurir = state.namaKurir ?? 'Kurir Tidak Diketahui';
            final noHpKurir = state.noHpKurir ?? 'Nomor Tidak Tersedia';
            final alamatJemput = state.alamatJemput ?? '-';
            final alamatAntar = state.alamatAntar ?? '-';

            return Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                children: [
                  _buildKurirCard(namaKurir, noHpKurir),
                  const SizedBox(height: 16),
                  _buildAlamatCard("Alamat Penjemputan", alamatJemput),
                  const SizedBox(height: 12),
                  _buildAlamatCard("Alamat Pengantaran", alamatAntar, isAntar: true),
                  const SizedBox(height: 16),
                  if (widget.role == 'barang')
                    _buildDetailCard("Detail Barang", state.namaBarang, state.catatanBarang, state.ukuran)
                  else if (widget.role == 'makanan')
                    _buildDetailCard("Detail Makanan", state.namaMakanan, state.catatanMakanan)
                  else
                    _buildDetailCard("Info Penumpang", "Layanan penumpang siap dijemput", "Tidak ada catatan tambahan"),
                  const SizedBox(height: 16),
                  if (widget.role == 'penumpang')
                    TextField(
                      controller: catatanController,
                      decoration: InputDecoration(
                        labelText: 'Tambahkan catatan',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      maxLines: 2,
                    ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => _submitOrder(context, state),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepOrange,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      "Order dan antar sekarang",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  Widget _buildKurirCard(String nama, String phone) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: const Color(0xFF1C1B33),
      elevation: 4,
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: const CircleAvatar(
          backgroundImage: AssetImage('assets/images/kurir1.png'),
          radius: 24,
        ),
        title: Text(nama, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(phone, style: const TextStyle(color: Colors.white70)),
      ),
    );
  }

  Widget _buildAlamatCard(String title, String alamat, {bool isAntar = false}) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: sectionTitleStyle()),
            const SizedBox(height: 4),
            Text(alamat, style: addressStyle()),
            if (isAntar) ...[
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFFF6B00)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // TODO: aksi ganti alamat
                  },
                  child: const Text("Ganti Alamat", style: TextStyle(color: Color(0xFFFF6B00))),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(String title, String? nama, String? catatan, [String? tambahan]) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: sectionTitleStyle()),
            const SizedBox(height: 6),
            Text(
              nama ?? '-',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.deepOrange,
                fontSize: 16,
              ),
            ),
            if (tambahan != null) ...[
              const SizedBox(height: 4),
              Text("Ukuran: $tambahan"),
            ],
            const SizedBox(height: 4),
            Text(catatan ?? '-')
          ],
        ),
      ),
    );
  }

  TextStyle sectionTitleStyle() {
    return TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.grey[700]);
  }

  TextStyle addressStyle() {
    return const TextStyle(fontSize: 14, fontWeight: FontWeight.w500);
  }
}
