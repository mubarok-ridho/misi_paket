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
  bool isReadOnly = false;
  bool showEditButton = false;

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

  Future<void> fetchExistingTagihan() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final url = Uri.parse("http://localhost:8080/api/orders/${widget.orderId}");

    try {
      final response = await http.get(url, headers: {
        "Authorization": "Bearer $token",
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final order = data['order'];

        if (order['nominal'] != null) {
          totalController.text = order['nominal'].toString();
          setState(() {
            isReadOnly = true; // jika sudah ada tagihan → readonly
            showEditButton = true; // munculkan tombol edit
          });
        }
      } else {
        print("❌ Gagal ambil data order: ${response.body}");
      }
    } catch (e) {
      print("❌ Error saat ambil tagihan: $e");
    }
  }

  void enableEditing() {
    setState(() {
      isReadOnly = false;
      showEditButton = false;
    });
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
  void initState() {
    super.initState();
    fetchExistingTagihan(); // tambahkan ini
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF24313F),
      appBar: AppBar(
        title: const Text("Tagihan"),
        backgroundColor: const Color(0xFF334856),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text("Total Tagihan",
                  style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 6),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextFormField(
                        controller: totalController,
                        keyboardType: TextInputType.number,
                        readOnly: isReadOnly,
                        decoration: InputDecoration(
                          labelText: "Total Tagihan",
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    // Tombol edit di pojok kanan atas
                    if (showEditButton)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: enableEditing,
                          tooltip: 'Edit Tagihan',
                        ),
                      ),
                  ],
                ),
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
                    : Text(
                        showEditButton ? "Kirim Tagihan" : "Simpan Perubahan"),
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
