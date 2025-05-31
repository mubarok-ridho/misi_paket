// FILE: courier_home.dart
import 'package:flutter/material.dart';

class CourierHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Dashboard Kurir'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Notifikasi'),
              Tab(text: 'Pesanan'),
              Tab(text: 'Profil'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(child: Text('Notifikasi (dummy)')),
            AssignedOrdersTab(),
            Center(child: Text('Profil Kurir (dummy)')),
          ],
        ),
      ),
    );
  }
}

class AssignedOrdersTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return Card(
          child: ListTile(
            title: Text('Pesanan #$index'),
            subtitle: Text('Dari: Customer $index'),
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Detail Pesanan'),
                  content: Text('Detail lengkap pesanan #$index'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Tutup'),
                    )
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}