import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:misi_paket/screens/User_Customer/edit_profile_page.dart';
import 'package:misi_paket/screens/change_password_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? user;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        setState(() {
          error = 'Token tidak ditemukan.';
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse("http://localhost:8080/api/users/profile"),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          user = {
            "name": data["name"] ?? "-",
            "email": data["email"] ?? "-",
            "phone": data["phone"] ?? "-",
          };
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Gagal memuat profil: ${response.statusCode}";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Terjadi kesalahan: $e";
        isLoading = false;
      });
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2A38),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.white70)))
              : Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Column(
                          children: [
                            _buildInfoCard("Nama Lengkap", user?['name'] ?? "-"),
                            _buildInfoCard("Email", user?['email'] ?? "-"),
                            _buildInfoCard("No. Telepon", user?['phone'] ?? "-"),
                            const SizedBox(height: 20),
                            _buildActionTile(Icons.edit, "Edit Profil", Colors.orangeAccent, () async {
                              if (user != null && mounted) {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => EditProfilePage(
                                    ),
                                  ),
                                );
                                fetchProfile(); // Refresh setelah kembali
                              }
                            }),
                            _buildActionTile(Icons.lock, "Ubah Password", Colors.orangeAccent, () {

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChangePasswordPage()),
    );

                            }),
                            _buildActionTile(Icons.logout, "Keluar", Colors.redAccent, logout),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 220,
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF24313F), Color(0xFF3C4A57)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.elliptical(400, 120),
          bottomRight: Radius.elliptical(400, 120),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircleAvatar(
            radius: 45,
            backgroundColor: Colors.orange,
            child: Icon(Icons.person, size: 55, color: Colors.white),
          ),
          const SizedBox(height: 12),
          Text(
            user?['name'] ?? '-',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            user?['email'] ?? '-',
            style: const TextStyle(color: Color(0xFFA5B0BA), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      color: const Color(0xFF2F3D4C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        title: Text(title,
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
        subtitle: Text(value,
            style: const TextStyle(color: Colors.white, fontSize: 16)),
        leading: const Icon(Icons.info_outline, color: Colors.orangeAccent),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String label, Color color, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      color: const Color(0xFF2F3D4C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(label, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white30, size: 16),
        onTap: onTap,
      ),
    );
  }
}
