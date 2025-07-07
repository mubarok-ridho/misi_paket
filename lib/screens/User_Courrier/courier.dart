import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'courier_home_tab.dart';
import 'courier_order_tab.dart';
import 'courier_profile_tab.dart';

class CourierDashboard extends StatefulWidget {
  @override
  _CourierDashboardState createState() => _CourierDashboardState();
}

class _CourierDashboardState extends State<CourierDashboard> {
  int _selectedIndex = 0;
  int? kurirId;
  bool isLoading = true;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  @override
  void initState() {
    super.initState();
    _loadKurirId();
  }

Future<void> _loadKurirId() async {
  final prefs = await SharedPreferences.getInstance();
  final id = prefs.getInt('userId'); // ← ubah dari 'kurir_id' jadi 'userId'
  print("✅ Kurir ID from SharedPreferences: $id");

  setState(() {
    kurirId = id;
    isLoading = false;
  });
}

  @override
  Widget build(BuildContext context) {
    if (isLoading || kurirId == null) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final pages = [
      CourierHomeTab(),
      CourierOrderTab(kurirId: kurirId!),
      CourierProfileTab(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF334856),
        selectedItemColor: Colors.orangeAccent,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delivery_dining),
            label: 'Order',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
