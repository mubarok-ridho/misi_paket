import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rental App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: CustomerHome(), // langsung ke halaman Customer
    );
  }
}

class CustomerHome extends StatelessWidget {
  final List<Map<String, dynamic>> couriers = [
    {'name': 'Kurir A', 'status': 'available'},
    {'name': 'Kurir B', 'status': 'offline'},
    {'name': 'Kurir C', 'status': 'on_work'},
  ];

  Color getStatusColor(String status) {
    switch (status) {
      case 'available':
        return Colors.green;
      case 'offline':
        return Colors.red;
      case 'on_work':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  String getStatusLabel(String status) {
    switch (status) {
      case 'available':
        return 'Available';
      case 'offline':
        return 'Offline';
      case 'on_work':
        return 'On Work';
      default:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Customer Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status Kurir:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Expanded(
              child: ListView.builder(
                itemCount: couriers.length,
                itemBuilder: (context, index) {
                  final courier = couriers[index];
                  return Card(
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: getStatusColor(courier['status']),
                      ),
                      title: Text(courier['name']),
                      subtitle: Text(getStatusLabel(courier['status'])),
                      trailing: courier['status'] == 'available'
                          ? TextButton(
                              onPressed: () {
                                // nanti fitur chat
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Chat dengan ${courier['name']}')),
                                );
                              },
                              child: Text('Chat'),
                            )
                          : null,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // nanti ke halaman order pesanan
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Menuju halaman Order...')),
                );
              },
              child: Text('Order Pesanan'),
            ),
            SizedBox(height: 16),
            Text(
              'Status Pesanan: Dalam Proses',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}

class OwnerHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Owner Dashboard')),
      body: Center(child: Text('Owner View')),
    );
  }
}

class CourierHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Kurir Dashboard')),
      body: Center(child: Text('Kurir View')),
    );
  }
}
