// FILE: customer_home.dart
import 'package:flutter/material.dart';

class CustomerHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Dashboard Customer'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Pesan Kurir'),
              Tab(text: 'Profil'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            MakeOrderTab(),
            Center(child: Text('Profil Customer (dummy)')),
          ],
        ),
      ),
    );
  }
}

class MakeOrderTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          TextField(
            decoration: InputDecoration(labelText: 'Jenis Pesanan (barang/makanan/orang)'),
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Detail Pesanan'),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: Text('Kirim Pesanan'),
          )
        ],
      ),
    );
  }
}
