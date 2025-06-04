import 'package:flutter/material.dart';

class PilihKurirPage extends StatelessWidget {
  final List<Map<String, dynamic>> kurirList = [
    {
      "name": "John Doe",
      "phone": "0823 1283 1238",
      "status": "available",
      "photo": "https://via.placeholder.com/150" // bisa diganti asset
    },
    {
      "name": "John Doe",
      "phone": "0823 1283 1238",
      "status": "available",
      "photo": "https://via.placeholder.com/150"
    },
    {
      "name": "John Doe",
      "phone": "0823 1283 1238",
      "status": "onwork",
      "photo": "https://via.placeholder.com/150"
    },
    {
      "name": "John Doe",
      "phone": "0823 1283 1238",
      "status": "onwork",
      "photo": "https://via.placeholder.com/150"
    },
    {
      "name": "John Doe",
      "phone": "0823 1283 1238",
      "status": "off",
      "photo": "https://via.placeholder.com/150"
    },
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'available':
        return Colors.green;
      case 'onwork':
        return Colors.red;
      case 'off':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.orange, Colors.deepOrangeAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 40),
          child: Text(
            "Pilih Kurir\nyang tersedia",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
              height: 1.3,
            ),
          ),
        ),
        toolbarHeight: 140,
      ),
      body: ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: kurirList.length,
        itemBuilder: (context, index) {
          final kurir = kurirList[index];
          final statusColor = _getStatusColor(kurir['status']);

          return Container(
            margin: EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Profile Picture
                Container(
                  margin: EdgeInsets.all(12),
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    image: DecorationImage(
                      image: NetworkImage(kurir['photo']),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                // Name & Phone
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        kurir['name'],
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      SizedBox(height: 4),
                      Text(
                        kurir['phone'],
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Status Strip
            foregroundDecoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: statusColor, width: 10),
              ),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Order"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
