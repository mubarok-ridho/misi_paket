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
    return Container(
      color: const Color(0xFF0E1116), // dark background
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFFEF5B2E),
              child: Icon(Icons.admin_panel_settings, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 16),
            const Text(
              "Hai Admin FaiExpress 👋",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            const SizedBox(height: 8),
            const Text(
              "admin@faiexpress.id",
              style: TextStyle(color: Color(0xFFB0B0B0)),
            ),
            const SizedBox(height: 8),
            const Chip(
              label: Text("ADMIN", style: TextStyle(color: Colors.white)),
              backgroundColor: Color(0xFFEF5B2E),
            ),
            const SizedBox(height: 24),

            // Motivasi Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF1F232A),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Tetap semangat yaa! 🚀\nPesanan makin banyak = makin rame = makin seru. Ingat, admin adalah jantungnya sistem 💪🔥",
                style: TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 36),

            // Ganti Password
            ListTile(
              leading: const Icon(Icons.lock, color: Color(0xFFEF5B2E)),
              title: const Text("Ganti Password", style: TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white30),
              onTap: () {
                Navigator.pushNamed(context, "/change-password");
              },
            ),
            const Divider(color: Colors.white24),

            // Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: () => _logout(context),
            ),
          ],
        ),
      ),
    );
  }
}
