import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:misi_paket/screens/User_Courrier/edit_profile_kurir.dart';
import 'package:misi_paket/screens/change_password_page.dart';
import 'package:misi_paket/screens/login.dart';
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
        Uri.parse('https://gin-production-77e5.up.railway.app/api/kurir/$kurirId'),
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
    await prefs.remove('token');

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.cyan))
          : error != null
              ? Center(child: Text(error!, style: const TextStyle(color: Colors.white70)))
              : Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF0A1E2D), Color(0xFF006974)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    SafeArea(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            const SizedBox(height: 20),
                            // Avatar Pop
                            Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(height: 140),
                                Positioned(
                                  top: 0,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: const LinearGradient(
                                            colors: [Color(0xFF00B5D8), Color(0xFF006974)]),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.cyan.withOpacity(0.6),
                                            blurRadius: 12,
                                            offset: const Offset(0, 4),
                                          )
                                        ],
                                      ),
                                      child: const CircleAvatar(
                                        radius: 55,
                                        backgroundColor: Color(0xFF1F232A),
                                        child: Icon(Icons.person, size: 60, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              kurir?['name'] ?? '-',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              kurir?['email'] ?? '-',
                              style: const TextStyle(color: Color(0xFFA5B0BA), fontSize: 14),
                            ),
                            const SizedBox(height: 50),

                            _buildInfoCard("Email", kurir?['email'] ?? "-"),
                            _buildInfoCard("No. Telepon", kurir?['phone'] ?? "-"),
                            _buildInfoCard("Kendaraan", kurir?['kendaraan'] ?? "-"),
                            _buildInfoCard("Plat Nomor", kurir?['plat_nomor'] ?? "-"),
                            const SizedBox(height: 20),

                            _buildActionTile(Icons.edit, "Edit Profil", Colors.cyanAccent, () async {
                              await Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const EditKurirProfilePage()),
                              );
                              fetchKurirData();
                            }),
                            _buildActionTile(Icons.lock, "Ubah Password", Colors.cyanAccent, () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const ChangePasswordPage()),
                              );
                            }),
                            _buildActionTile(Icons.logout, "Logout", Colors.redAccent, () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Konfirmasi"),
                                  content: const Text("Yakin ingin log out?"),
                                  actions: [
                                    TextButton(
                                      child: const Text("Batal"),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    TextButton(
                                      child: const Text("Log Out", style: TextStyle(color: Colors.red)),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        logout();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }),
                            _buildActionTile(Icons.exit_to_app, "Keluar Aplikasi", Colors.grey, () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text("Keluar Aplikasi"),
                                  content: const Text("Yakin mau keluar dari aplikasi?"),
                                  actions: [
                                    TextButton(
                                      child: const Text("Batal"),
                                      onPressed: () => Navigator.pop(context),
                                    ),
                                    TextButton(
                                      child: const Text("Keluar", style: TextStyle(color: Colors.red)),
                                      onPressed: () {
                                        Navigator.pop(context);
                                        SystemNavigator.pop();
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 40),

                            // Credit Footer
                            Column(
                              children: [
                                Image.asset(
                                  "lib/assets/Logo.png",
                                  height: 60,
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  "© 2025 FaiExpress",
                                  style: TextStyle(color: Colors.white54, fontSize: 12),
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildInfoCard(String title, String value) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: const Color(0xFF1F2A35),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        title: Text(title,
            style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
        subtitle: Text(value, style: const TextStyle(color: Colors.white, fontSize: 16)),
        leading: const Icon(Icons.info_outline, color: Colors.cyanAccent),
      ),
    );
  }

  Widget _buildActionTile(IconData icon, String label, Color color, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: const Color(0xFF1F2A35),
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
