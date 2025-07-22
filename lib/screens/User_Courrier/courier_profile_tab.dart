import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:misi_paket/screens/User_Courrier/edit_profile_kurir.dart';
import 'package:misi_paket/screens/change_password_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class CourierProfileTab extends StatefulWidget {
  const CourierProfileTab({super.key});

  @override
  State<CourierProfileTab> createState() => _CourierProfileTabState();
}

class _CourierProfileTabState extends State<CourierProfileTab> {
  Map<String, dynamic>? kurir;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    fetchKurirData();
  }

  Future<void> fetchKurirData() async {
    final prefs = await SharedPreferences.getInstance();
    final kurirId = prefs.getInt('userId');
    final token = prefs.getString('token');

    if (kurirId == null || token == null) {
      setState(() {
        error = 'Token atau ID tidak ditemukan.';
        isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/kurir/$kurirId'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = data['user'];
        setState(() {
          kurir = {
            "name": user['name'] ?? "-",
            "email": user['email'] ?? "-",
            "phone": user['phone'] ?? "-",
            "kendaraan": user['kendaraan'] ?? "-",
            "plat_nomor": user['plat_nomor'] ?? "-",
          };
          isLoading = false;
        });
      } else {
        setState(() {
          error = "Gagal memuat data kurir: ${response.statusCode}";
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
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2A38),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orangeAccent))
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
                            _buildInfoCard("Email", kurir?['email'] ?? "-"),
                            _buildInfoCard("No. Telepon", kurir?['phone'] ?? "-"),
                            _buildInfoCard("Kendaraan", kurir?['kendaraan'] ?? "-"),
                            _buildInfoCard("Plat Nomor", kurir?['plat_nomor'] ?? "-"),
                            const SizedBox(height: 20),
                            _buildActionTile(Icons.edit, "Edit Profil", Colors.orangeAccent, () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const EditKurirProfilePage()),
                              );
                              fetchKurirData(); // Refresh
                            }),
                            _buildActionTile(Icons.lock, "Ubah Password", Colors.orangeAccent, () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
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
            kurir?['name'] ?? '-',
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            kurir?['email'] ?? '-',
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
