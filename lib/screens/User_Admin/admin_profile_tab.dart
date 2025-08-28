import 'package:flutter/material.dart';
import 'package:misi_paket/screens/login.dart';

class AdminProfileTab extends StatelessWidget {
  const AdminProfileTab({super.key});

  void _logout(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Full screen gradient
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0E1116), Color(0xFFDE6029)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Avatar + greeting
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFA65C), Color(0xFFEF5B2E)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.5),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: const CircleAvatar(
                    radius: 45,
                    backgroundColor: Color(0xFF1F232A),
                    child: Icon(Icons.admin_panel_settings,
                        size: 50, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Hai Admin FaiExpress 👋",
                  style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                const SizedBox(height: 6),
                const Text(
                  "admin@gmail.com",
                  style: TextStyle(color: Color(0xFFB0B0B0),fontSize: 16),
                ),
                const SizedBox(height: 12),
                const Chip(
                  label: Text("ADMIN", style: TextStyle(color: Colors.white)),
                  backgroundColor: Color(0xFFEF5B2E),
                ),
                const SizedBox(height: 30),

                // Motivasi Card
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F232A),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.4),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      )
                    ],
                  ),
                  child: Column(
                    children: const [
                      Text(
                        "وَابْتَغِ فِيمَا آتَاكَ اللَّهُ الدَّارَ الْآخِرَةَ وَلَا تَنسَ نَصِيبَكَ مِنَ الدُّنْيَا",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 12),
                      Text(
                        "\"Dan carilah pada apa yang telah dianugerahkan Allah kepadamu (rezeki) negeri akhirat, dan janganlah kamu melupakan bagianmu dari dunia.\" (QS. Al-Qashash: 77)",
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Artinya: Berusaha dan mencari rejeki itu penting, tapi jangan sampai melupakan akhirat. Semangat bekerja & menjadi berkah untuk semua!",
                        style: TextStyle(
                            color: Colors.orangeAccent, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),

                // Ganti Password
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F232A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading:
                        const Icon(Icons.lock, color: Color(0xFFEF5B2E)),
                    title: const Text("Ganti Password",
                        style: TextStyle(color: Colors.white)),
                    trailing: const Icon(Icons.arrow_forward_ios,
                        size: 16, color: Colors.white30),
                    onTap: () {
                      Navigator.pushNamed(context, "/change-password");
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Logout
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F232A),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title:
                        const Text("Logout", style: TextStyle(color: Colors.red)),
                    onTap: () => _logout(context),
                  ),
                ),
                const SizedBox(height: 40),

                // Credit + logo
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "lib/assets/Logo.png", // pastikan path sesuai pubspec.yaml
                      width: 100,
                      height: 100,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      "FaiExpress 2.0",
                      style: TextStyle(color: Colors.white54, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "© 2025 FaiExpress. All rights reserved.",
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
