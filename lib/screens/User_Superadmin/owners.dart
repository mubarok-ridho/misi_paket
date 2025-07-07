import 'package:flutter/material.dart';

class AdminHome extends StatefulWidget {
  @override
  _AdminHomeState createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    CourierListPage(),
    AddCourierPage(),
    TransactionHistoryPage(),
    IncomingOrdersPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining),
            label: 'Kurir',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Tambah Kurir',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Transaksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: 'Pesanan Masuk',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.green,
        onTap: _onItemTapped,
      ),
    );
  }
}

class CourierListPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Daftar Kurir (dummy)'),
    );
  }
}

class AddCourierPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tambah Kurir', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          TextField(
            decoration: InputDecoration(labelText: 'Nama'),
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Username'),
          ),
          TextField(
            decoration: InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {},
            child: Text('Simpan'),
          )
        ],
      ),
    );
  }
}

class TransactionHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text('Transaksi #$index'),
          subtitle: Text('Status: done'),
        );
      },
    );
  }
}

class IncomingOrdersPage extends StatelessWidget {
  final List<String> dummyOrders = [
    'Pesanan 1: Kirim dokumen',
    'Pesanan 2: Antar makanan',
    'Pesanan 3: Jemput orang',
  ];

  final List<String> dummyCouriers = [
    'Kurir A',
    'Kurir B',
    'Kurir C',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: dummyOrders.length,
      itemBuilder: (context, index) {
        return Card(
          margin: EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(dummyOrders[index]),
            trailing: ElevatedButton(
              child: Text('Tugaskan'),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text('Pilih Kurir'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: dummyCouriers.map((courier) => ListTile(
                        title: Text(courier),
                        onTap: () {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('${dummyOrders[index]} ditugaskan ke $courier')),
                          );
                        },
                      )).toList(),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
