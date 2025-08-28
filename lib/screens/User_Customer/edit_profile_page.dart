import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;
  String? userId;
  String? token;

  @override
  void initState() {
    super.initState();
    _loadTokenAndUser();
  }

  Future<void> _loadTokenAndUser() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    userId = prefs.getInt('userId')?.toString();

    if (token == null || userId == null) return;

    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
  if (!mounted || token == null || userId == null) return;

  _showLoadingDialog("Lagi cari profil kamu ...");

  try {
    final response = await http.get(
      Uri.parse('https://gin-production-77e5.up.railway.app/api/users/$userId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    Navigator.of(context).pop(); // tutup loading

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);

      if (responseData['user'] != null) {
        final user = responseData['user'];
        setState(() {
          _nameController.text = user['name'] ?? '';
          _phoneController.text = user['phone'] ?? '';
          _emailController.text = user['email'] ?? '';
        });
      } else {
        _showSnackbar('Data profil tidak ditemukan');
      }
    } else if (response.statusCode == 404) {
      _showSnackbar('Customer tidak ditemukan');
    } else {
      _showSnackbar('Gagal memuat data profil');
    }
  } catch (e) {
    Navigator.of(context).pop();
    _showSnackbar('Terjadi kesalahan koneksi');
  }
}


  Future<void> _saveProfile() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');

  if (token == null || token.isEmpty) {
    _showSnackbar('Token user tidak tersedia');
    setState(() => _isLoading = false);
    return;
  }

  _showLoadingDialog("Menyimpan perubahan ...");

  try {
    final response = await http.put(
      Uri.parse('https://gin-production-77e5.up.railway.app/api/update-profile'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
      }),
    );

    Navigator.of(context).pop(); // tutup loading

    if (response.statusCode == 200) {
      _showSnackbar('Profil berhasil diperbarui');
      Navigator.pop(context, true);
    } else {
      final res = json.decode(response.body);
      _showSnackbar(res['error'] ?? 'Gagal menyimpan perubahan');
    }
  } catch (e) {
    Navigator.of(context).pop();
    _showSnackbar('Terjadi kesalahan saat menyimpan');
  }

  setState(() => _isLoading = false);
}

  void _showSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showLoadingDialog(String message) {
  if (!mounted) return;

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) => Dialog(
      backgroundColor: Colors.transparent,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 150,
            width: 150,
            child: Lottie.asset('lib/assets/Fainyetir.json'),
          ),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    ),
  );
}


  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: const Color(0xFF1E293B),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        title: const Text("Edit Profil"),
        backgroundColor: const Color(0xFF1E293B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration("Nama Lengkap"),
                style: const TextStyle(color: Colors.white),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: _inputDecoration("No. Telepon"),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Nomor telepon wajib diisi' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _emailController,
                decoration: _inputDecoration("Email"),
                style: const TextStyle(color: Colors.white),
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value == null || value.isEmpty ? 'Email wajib diisi' : null,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Simpan Perubahan",
                          style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
