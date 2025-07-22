import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class InputTagihanPage extends StatefulWidget {
  final int orderId;

  const InputTagihanPage({super.key, required this.orderId});

  @override
  State<InputTagihanPage> createState() => _InputTagihanPageState();
}

class _InputTagihanPageState extends State<InputTagihanPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController totalController = TextEditingController();
  bool isSubmitting = false;

  Future<void> submitTagihan() async {
    if (!_formKey.currentState!.validate()) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse("http://localhost:8080/api/orders/tagihan");

    final body = jsonEncode({
      "id": widget.orderId,
      "nominal": int.parse(totalController.text),
    });

    try {
      setState(() => isSubmitting = true);
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: body,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Tagihan berhasil dikirim")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Gagal kirim tagihan: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  Future<void> validasiPembayaran() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final url = Uri.parse("http://localhost:8080/api/orders/payment-validasi");

    final body = jsonEncode({"id": widget.orderId});

    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: body,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Pembayaran berhasil divalidasi")),
        );
        Navigator.pop(context); // balik ke halaman sebelumnya
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Gagal validasi: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF24313F),
      appBar: AppBar(
        title: const Text("Input Tagihan"),
        backgroundColor: const Color(0xFF334856),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text("Total Tagihan", style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 6),
              TextFormField(
                controller: totalController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: "Contoh: 35000",
                  hintStyle: TextStyle(color: Colors.white30),
                ),
                validator: (val) => val == null || val.isEmpty ? "Wajib diisi" : null,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: isSubmitting ? null : submitTagihan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  foregroundColor: Colors.white,
                ),
                child: isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Kirim Tagihan"),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: isSubmitting ? null : validasiPembayaran,
                icon: const Icon(Icons.verified_user),
                label: const Text("Validasi Pembayaran"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
