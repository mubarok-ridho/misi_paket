import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:misi_paket/bloc/order_bloc/order_bloc.dart';
import 'package:misi_paket/bloc/order_bloc/order_event.dart';
import 'package:misi_paket/screens/User_Customer/select_location_page.dart';

class FormBarangPage extends StatefulWidget {
  const FormBarangPage({super.key});

  @override
  State<FormBarangPage> createState() => _FormBarangPageState();
}

class _FormBarangPageState extends State<FormBarangPage> {
  final _namaBarangController = TextEditingController();
  final _catatanController = TextEditingController();
  final _panjangController = TextEditingController();
  final _lebarController = TextEditingController();
  final _tinggiController = TextEditingController();

  @override
  void dispose() {
    _namaBarangController.dispose();
    _catatanController.dispose();
    _panjangController.dispose();
    _lebarController.dispose();
    _tinggiController.dispose();
    super.dispose();
  }

  void _lanjut() {
    final namaBarang = _namaBarangController.text.trim();
    final catatan = _catatanController.text.trim();
    final panjang = _panjangController.text.trim();
    final lebar = _lebarController.text.trim();
    final tinggi = _tinggiController.text.trim();

    if (namaBarang.isEmpty || panjang.isEmpty || lebar.isEmpty || tinggi.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mohon lengkapi nama dan ukuran barang"),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final ukuranFormatted = "$panjang x $lebar x $tinggi";

    context.read<OrderBloc>().add(SetBarangEvent(
      namaBarang: namaBarang,
      catatanBarang: catatan,
      ukuran: ukuranFormatted,
    ));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LokasiPickerPage(role: 'barang'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text("Form Barang"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            Center(
              child: Icon(Icons.inventory_2_rounded, size: 80, color: Colors.deepOrange),
            ),
            const SizedBox(height: 20),
            Text(
              "Detail Barang",
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _namaBarangController,
              decoration: InputDecoration(
                labelText: "Nama Barang",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.label_important_rounded),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Ukuran Barang (cm)",
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _panjangController,
                    decoration: InputDecoration(
                      labelText: "Panjang",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _lebarController,
                    decoration: InputDecoration(
                      labelText: "Lebar",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _tinggiController,
                    decoration: InputDecoration(
                      labelText: "Tinggi",
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _catatanController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: "Catatan Tambahan",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.notes),
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _lanjut,
                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                label: const Text("Lanjut Pilih Lokasi", style: TextStyle(fontSize: 16)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
