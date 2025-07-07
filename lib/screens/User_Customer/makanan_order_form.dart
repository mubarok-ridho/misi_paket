import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:misi_paket/bloc/order_bloc/order_bloc.dart';
import 'package:misi_paket/bloc/order_bloc/order_event.dart';
import 'package:misi_paket/screens/User_Customer/select_location_page.dart';

class FormAwalmamPage extends StatefulWidget {
  const FormAwalmamPage({super.key});

  @override
  State<FormAwalmamPage> createState() => _FormAwalmamPageState();
}

class _FormAwalmamPageState extends State<FormAwalmamPage> {
  final namaController = TextEditingController();
  final catatanController = TextEditingController();

  int currentIndex = 0;

  void _submit() {
    final namaMakanan = namaController.text;
    final catatan = catatanController.text;

    if (namaMakanan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama makanan tidak boleh kosong")),
      );
      return;
    }

    context.read<OrderBloc>().add(SetMakananEvent(
      namaMakanan: namaMakanan,
      catatanMakanan: catatan,
    ));

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LokasiPickerPage(role: 'makanan'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        selectedItemColor: Colors.deepOrange,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.local_shipping), label: "Order"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLabel("Nama Makanan"),
                  _buildTextField(namaController, "Contoh: Soto Lamongan"),
                  const SizedBox(height: 16),
                  _buildLabel("Tambahkan catatan"),
                  _buildTextField(catatanController, "Contoh: Extra Pedas"),
                  const SizedBox(height: 24),
                  Center(
                    child: ElevatedButton(
                      onPressed: _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      ),
                      child: const Text("Lanjut Pilih Lokasi", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 16),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.deepOrange, Colors.orangeAccent],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
      ),
      child: Text(
        "Pengantaran\nMakanan",
        style: GoogleFonts.poppins(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.deepOrange,
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white54),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
