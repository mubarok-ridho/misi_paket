import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'edit_profile_page.dart';
import 'order_history_page.dart';
import 'profile_menu_item.dart';

class CourierProfileTab extends StatelessWidget {
  Future<Map<String, dynamic>?> fetchKurirData() async {
    final prefs = await SharedPreferences.getInstance();
    final kurirId = prefs.getInt('userId');
    final token = prefs.getString('token');

    if (kurirId == null || token == null) return null;

    final response = await http.get(
      Uri.parse('http://localhost:8080/api/kurir/$kurirId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("❌ Gagal ambil data kurir: ${response.body}");
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: fetchKurirData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator(color: Colors.orangeAccent));
        }

        final kurir = snapshot.data?['user'];

        return SafeArea(
          child: Container(
            color: const Color(0xFF1F2A38),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.orangeAccent,
                    child: Icon(Icons.person, size: 50, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    kurir?['name'] ?? 'Nama Kurir',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "ID: KUR${kurir?['id'] ?? '---'}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 28),

                  ProfileMenuItem(
                    icon: Icons.edit,
                    title: "Edit Profile",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => EditProfilePage()),
                      );
                    },
                  ),
                  ProfileMenuItem(
                    icon: Icons.history,
                    title: "Riwayat Pesanan",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => OrderHistoryPage()),
                      );
                    },
                  ),
                  ProfileMenuItem(
                    icon: Icons.logout,
                    title: "Keluar",
                    onTap: () async {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear(); // logout
                      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
                    },
                    isDestructive: true,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
