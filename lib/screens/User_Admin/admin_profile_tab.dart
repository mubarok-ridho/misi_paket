import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:misi_paket/screens/login.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AdminProfileTab extends StatefulWidget {
  const AdminProfileTab({super.key});

  @override
  State<AdminProfileTab> createState() => _AdminProfileTabState();
}

class _AdminProfileTabState extends State<AdminProfileTab> {
  String nama = '';
  String email = '';
  String role = '';
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  Future<void> _fetchProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final userId = prefs.getInt('userId');

    final res = await http.get(
      Uri.parse("http://localhost:8080/api/users/$userId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      setState(() {
        nama = data['nama'];
        email = data['email'];
        role = data['role'];
        loading = false;
      });
    } else {
      setState(() {
        nama = "Gagal memuat data";
        loading = false;
      });
    }
  }

  void _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Center(child: CircularProgressIndicator())
        : Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.orange.shade700,
                  child: const Icon(Icons.admin_panel_settings, size: 50, color: Colors.white),
                ),
                const SizedBox(height: 16),
                Text(nama, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(email, style: const TextStyle(color: Colors.grey)),
                const SizedBox(height: 4),
                Chip(
                  label: Text(role.toUpperCase(), style: const TextStyle(color: Colors.white)),
                  backgroundColor: Colors.orange,
                ),
                const SizedBox(height: 24),

                ListTile(
                  leading: const Icon(Icons.lock, color: Colors.orange),
                  title: const Text("Ganti Password"),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pushNamed(context, "/change-password");
                  },
                ),
                const Divider(),

                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Logout", style: TextStyle(color: Colors.red)),
                  onTap: _logout,
                ),
              ],
            ),
          );
  }
}
