import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class TambahKurirPage extends StatefulWidget {
  const TambahKurirPage({super.key});

  @override
  State<TambahKurirPage> createState() => _TambahKurirPageState();
}

class _TambahKurirPageState extends State<TambahKurirPage> {
  final _formKey = GlobalKey<FormState>();
  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _noHpCtrl = TextEditingController();
  final _namaKendaraanCtrl = TextEditingController();
  final _platNomorCtrl = TextEditingController();

  bool _loading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final kendaraanGabung =
        "${_namaKendaraanCtrl.text.trim()} ${_platNomorCtrl.text.trim()}";

    try {
      final res = await http.post(
        Uri.parse('https://gin-production-77e5.up.railway.app/register'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          "name": _namaCtrl.text.trim(),
          "email": _emailCtrl.text.trim(),
          "password": _passwordCtrl.text.trim(),
          "role": "kurir",
          "phone": _noHpCtrl.text.trim(),
          "kendaraan": kendaraanGabung,
          "status": "online",
        }),
      );
    
      if (res.statusCode == 200 || res.statusCode == 201 || res.statusCode == 204) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text("✅ Kurir berhasil ditambahkan!"),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context); // kembali ke halaman sebelumnya
      } else {
        final data = jsonDecode(res.body);
        _showError(data['error'] ?? "Gagal menambahkan kurir");
      }
    } catch (e) {
      _showError("Terjadi kesalahan saat menghubungi server.");
    }

    setState(() => _loading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("❌ $message"),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tambah Kurir", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.orange.shade800,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: const Color(0xFF121212),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildField("Nama Kurir", _namaCtrl),
              _buildField("Email Kurir", _emailCtrl, keyboardType: TextInputType.emailAddress),
              _buildField("Password", _passwordCtrl, obscure: true),
              _buildField("No. HP", _noHpCtrl, keyboardType: TextInputType.phone),
              _buildField("Nama Kendaraan", _namaKendaraanCtrl),
              _buildField("Plat Nomor", _platNomorCtrl),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text("Tambah Kurir"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade800,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  onPressed: _loading ? null : _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller,
      {bool obscure = false, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: keyboardType,
        validator: (val) => val == null || val.trim().isEmpty ? "Wajib diisi" : null,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF1E1E1E),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.white24),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.orange.shade800, width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
