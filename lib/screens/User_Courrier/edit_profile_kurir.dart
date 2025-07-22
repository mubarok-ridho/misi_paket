import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EditKurirProfilePage extends StatefulWidget {
  const EditKurirProfilePage({super.key});

  @override
  State<EditKurirProfilePage> createState() => _EditKurirProfilePageState();
}

class _EditKurirProfilePageState extends State<EditKurirProfilePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController kendaraanController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController platNomorController = TextEditingController();

  String? token;
  String? kurirId;

  @override
  void initState() {
    super.initState();
    loadTokenAndId().then((_) => fetchKurirProfile());
  }

  Future<void> loadTokenAndId() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString('token');
    kurirId = prefs.getInt('userId')?.toString();
  }

  Future<void> fetchKurirProfile() async {
    if (kurirId == null || token == null) return;

    try {
      final res = await http.get(
        Uri.parse("http://localhost:8080/api/kurir/$kurirId"),
        headers: {"Authorization": "Bearer $token"},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body)['user']; // ✅ FIXED KEY
        setState(() {
          nameController.text = data['name'] ?? '';
          phoneController.text = data['phone'] ?? '';
          kendaraanController.text = data['kendaraan'] ?? '';
          emailController.text = data['email'] ?? '';
          platNomorController.text = data['plat_nomor'] ?? '';
        });
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  Future<void> updateProfile() async {
    if (kurirId == null || token == null) return;

    try {
      final res = await http.put(
        Uri.parse("http://localhost:8080/api/kurir/up/$kurirId"),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json"
        },
        body: jsonEncode({
          "name": nameController.text,
          "phone": phoneController.text,
          "kendaraan": kendaraanController.text,
          "email": emailController.text,
          "plat_nomor": platNomorController.text,
        }),
      );

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Profil berhasil diperbarui")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error updating profile: $e");
    }
  }

  InputDecoration buildInputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFFB0B0B0)),
      enabledBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFF2A2A2A)),
        borderRadius: BorderRadius.circular(12),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFE23D19), width: 1.8),
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: const Color(0xFF1A1A1A),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        title: const Text("Edit Profil Kurir"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: nameController,
              style: const TextStyle(color: Colors.white),
              decoration: buildInputDecoration("Nama"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              style: const TextStyle(color: Colors.white),
              decoration: buildInputDecoration("No. Telepon"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: kendaraanController,
              style: const TextStyle(color: Colors.white),
              decoration: buildInputDecoration("Kendaraan"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              style: const TextStyle(color: Colors.white),
              decoration: buildInputDecoration("Email"),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: platNomorController,
              style: const TextStyle(color: Colors.white),
              decoration: buildInputDecoration("Plat Nomor"),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE23D19),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: updateProfile,
                child: const Text(
                  "Simpan Perubahan",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
