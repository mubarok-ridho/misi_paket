import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
        title: Text("Profil Saya"),
        elevation: 0,
      ),
      body: Container(
        color: Colors.grey[100],
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.orange,
              child: Icon(Icons.person, size: 60, color: Colors.white),
            ),
            SizedBox(height: 16),
            Text(
              "Nama Pengguna",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 4),
            Text(
              "email@example.com",
              style: TextStyle(color: Colors.grey[600]),
            ),
            SizedBox(height: 24),
            Divider(),
            ListTile(
              leading: Icon(Icons.edit, color: Colors.deepOrange),
              title: Text("Edit Profil"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.lock, color: Colors.deepOrange),
              title: Text("Ubah Password"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.redAccent),
              title: Text("Keluar"),
              onTap: () {
                // TODO: implement logout
              },
            )
          ],
        ),
      ),
    );
  }
}
