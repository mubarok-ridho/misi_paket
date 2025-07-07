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
  final _ukuranController = TextEditingController();

  @override
  void dispose() {
    _namaBarangController.dispose();
    _catatanController.dispose();
    _ukuranController.dispose();
    super.dispose();
  }

  void _lanjut() {
    final namaBarang = _namaBarangController.text;
    final catatan = _catatanController.text;
    final ukuran = _ukuranController.text;

    if (namaBarang.isEmpty || ukuran.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Mohon lengkapi nama dan ukuran barang")),
      );
      return;
    }

    context.read<OrderBloc>().add(SetBarangEvent(
      namaBarang: namaBarang,
      catatanBarang: catatan,
      ukuran: ukuran,
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Form Barang"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _namaBarangController,
              decoration: const InputDecoration(labelText: "Nama Barang"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ukuranController,
              decoration: const InputDecoration(labelText: "Ukuran Barang (cm³ atau kg)"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _catatanController,
              decoration: const InputDecoration(labelText: "Catatan Tambahan"),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _lanjut,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepOrange,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text("Lanjut Pilih Lokasi", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
