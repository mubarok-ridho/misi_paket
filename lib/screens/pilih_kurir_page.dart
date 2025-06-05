import 'package:flutter/material.dart';
import 'package:misi_paket/screens/confirmpage.dart';

class PilihKurirPage extends StatelessWidget {
  final Map<String, dynamic> barangData;
  PilihKurirPage({required this.barangData});

  final List<Map<String, dynamic>> kurirList = [
    {
      'name': 'Jude Bellingham',
      'phone': '0812 3456 7890',
      'status': 'green',
    },
    {
      'name': 'Vinicius Jr.',
      'phone': '0813 9876 5432',
      'status': 'yellow',
    },
    {
      'name': 'Luka Modrić',
      'phone': '0821 7654 3210',
      'status': 'red',
    },
    {
      'name': 'Toni Kroos',
      'phone': '0823 1283 1238',
      'status': 'red',
    },
    {
      'name': 'Rodrygo Goes',
      'phone': '0822 1122 3344',
      'status': 'dark',
    },
  ];

  Color getStatusColor(String status) {
    switch (status) {
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'red':
        return Colors.red;
      default:
        return Colors.black12;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(20, 50, 20, 30),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade700, Colors.orange.shade300],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: Text(
              "Pilih Kurir\nyang tersedia",
              style: TextStyle(
                fontSize: 24,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // List Kurir
          Expanded(
            child: ListView.builder(
              itemCount: kurirList.length,
              itemBuilder: (context, index) {
                final kurir = kurirList[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ConfirmPage(
                          fullData: {
                            ...barangData,
                            'kurir': kurir['name'],
                          },
                        ),
                      ),
                    );
                  },
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                          offset: Offset(2, 4),
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.white,
                            child: Icon(Icons.person, color: Colors.orange),
                          ),
                          title: Text(
                            kurir['name'],
                            style: TextStyle(color: Colors.white),
                          ),
                          subtitle: Text(
                            kurir['phone'],
                            style: TextStyle(color: Colors.white70),
                          ),
                        ),
                        Container(
                          height: 8,
                          decoration: BoxDecoration(
                            color: getStatusColor(kurir['status']),
                            borderRadius: BorderRadius.vertical(
                              bottom: Radius.circular(16),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),

      // Bottom Nav
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Order"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
