import 'package:flutter/material.dart';
import 'package:misi_paket/screens/User_Customer/barang_order_form.dart';
import 'package:misi_paket/screens/User_Customer/makanan_order_form.dart';
import 'package:misi_paket/screens/User_Customer/select_location_page.dart';
import 'package:misi_paket/screens/User_Customer/user_profile.dart';
import 'package:latlong2/latlong.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  _CustomerDashboardState createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  int _selectedIndex = 0;
  String currentAddress = "Lokasi Anda";
  LatLng currentLatLng = LatLng(-6.200000, 106.816666);

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  late final List<Widget> pages;

  @override
  void initState() {
    super.initState();
    pages = [
      HomeTab(
        currentAddress: currentAddress,
        onSetLocation: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const LokasiPickerPage(role: 'set_location'),
            ),
          );

          if (result is Map<String, dynamic> && result['address'] != null) {
            setState(() {
              currentAddress = result['address'];
              currentLatLng = result['latlng'];
            });
          }
        },
      ),
      const Center(child: Text('Order Page (placeholder)')),
      ProfilePage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF334856),
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
            icon: Icon(Icons.assignment),
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

class HomeTab extends StatelessWidget {
  final String currentAddress;
  final VoidCallback onSetLocation;

  const HomeTab({super.key, required this.currentAddress, required this.onSetLocation});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Location Row
            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(currentAddress,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                ),
                GestureDetector(
                  onTap: onSetLocation,
                  child: const CircleAvatar(
                    backgroundColor: Colors.orangeAccent,
                    child: Icon(Icons.edit_location_alt, color: Colors.white),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),

            // Banner promo
            Container(
              height: 150,
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: AssetImage('assets/burger_banner.jpg'),
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
              child: Stack(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.bottomLeft,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Special Offer for March",
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        const SizedBox(height: 4),
                        const Text(
                          "We are here with the best desserts in town.",
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            textStyle: const TextStyle(fontSize: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text("Buy Now"),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Menu Buttons
            MenuButton(
              label: "Pengantaran Barang",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FormBarangPage()),
                );
              },
            ),
            const SizedBox(height: 16),
            MenuButton(
              label: "Pengantaran Makanan",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const FormAwalmamPage()),
                );
              },
            ),
            const SizedBox(height: 16),
            MenuButton(
              label: "Pengantaran Penumpang",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LokasiPickerPage(role: 'penumpang'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const MenuButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFDE6029), Color(0xFFD2785C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(2, 4),
            )
          ],
        ),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
