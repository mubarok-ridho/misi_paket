import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:misi_paket/screens/User_Customer/edit_profile_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:misi_paket/screens/User_Customer/pilih_kurir_page.dart';
import 'package:misi_paket/screens/User_Customer/user_profile.dart';
import 'package:misi_paket/screens/User_Customer/order_list_page.dart';

class CustomerDashboard extends StatefulWidget {
  const CustomerDashboard({super.key});

  @override
  _CustomerDashboardState createState() => _CustomerDashboardState();
}

class _CustomerDashboardState extends State<CustomerDashboard> {
  int _selectedIndex = 0;
  String currentAddress = "";
  LatLng currentLatLng = const LatLng(-6.200000, 106.816666);
  String userName = "User";
  bool _locationLoaded = false;
  bool _nameLoaded = false;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  List<Widget> pages = [];

  @override
  void initState() {
    super.initState();
    _loadSavedLocation();
    _loadUserName();
  }

  Future<void> _loadUserName() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    try {
      final response = await http.get(
        Uri.parse('http://localhost:8080/api/users/profile'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final name = data['name'];
        setState(() => userName = name);
      }
    } catch (e) {
      print('Error fetching user name: $e');
    }

    _nameLoaded = true;
    _trySetPages();
  }

  Future<void> _loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final address = prefs.getString('selected_address');
    final lat = prefs.getDouble('selected_lat');
    final lng = prefs.getDouble('selected_lng');

    if (address != null && lat != null && lng != null) {
      setState(() {
        currentAddress = address;
        currentLatLng = LatLng(lat, lng);
      });
    }

    _locationLoaded = true;
    _trySetPages();
  }

  void _trySetPages() {
    if (_locationLoaded && _nameLoaded) {
      _setPages();
    }
  }

  void _setPages() {
    pages = [
      HomeTab(
        currentAddress: currentAddress,
        userName: userName,
        onSetLocation: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const EditProfilePage(),
            ),
          );

          if (result is Map<String, dynamic> && result['address'] != null) {
            setState(() {
              currentAddress = result['address'];
              currentLatLng = result['latlng'];
            });
            _saveLocation(result['address'], result['latlng']);
          }
        },
      ),
      const OrderListPage(),
      ProfilePage(),
    ];
    setState(() {});
  }

  Future<void> _saveLocation(String address, LatLng latlng) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_address', address);
    await prefs.setDouble('selected_lat', latlng.latitude);
    await prefs.setDouble('selected_lng', latlng.longitude);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      body: pages.isNotEmpty
          ? pages[_selectedIndex]
          : const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2B2B2B),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            backgroundColor: const Color(0xFF2B2B2B),
            selectedItemColor: const Color(0xFFF24B1D),
            unselectedItemColor: Colors.white70,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'Beranda',
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
        ),
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final String iconPath;
  final List<Color> colors;

  const MenuButton({
    super.key,
    required this.label,
    required this.onTap,
    required this.iconPath,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            height: 100,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 8,
                  offset: const Offset(2, 4),
                )
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: -24,
            bottom: -22,
            child: Image.asset(
              iconPath,
              height: 160,
              width: 160,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  final String currentAddress;
  final String userName;
  final VoidCallback onSetLocation;

  const HomeTab({
    super.key,
    required this.currentAddress,
    required this.userName,
    required this.onSetLocation,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              children: [
                const SizedBox(height: 24),
                Container(
                  height: 260,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFF1E1E1E), Color(0xFF2B2B2B)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.elliptical(500, 180),
                      bottomRight: Radius.elliptical(500, 180),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 18, left: 16, right: 16),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.white),
                        const SizedBox(width: 8),
                        Expanded(
                          child: GestureDetector(
                            onTap: onSetLocation,
                            child: Text(
                              currentAddress,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                decoration: TextDecoration.underline,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Container(
                  transform: Matrix4.translationValues(0, -180, 0),
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 150,
                        child: PageView(
                          children: [
                            promoCard('lib/assets/promo1.png'),
                            promoCard('lib/assets/promo2.jpg'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      greetingCard(),
                      const SizedBox(height: 32),
                      MenuButton(
                        label: "Pengantaran \nBarang",
                        iconPath: 'lib/assets/goods.png',
                        colors: [Color(0xFFEF5B2E), Color.fromARGB(255, 179, 53, 14)],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PilihKurirPage(role: 'barang'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      MenuButton(
                        label: "Pengantaran \nMakanan",
                        iconPath: 'lib/assets/food.png',
                        colors: [Color(0xFFEF5B2E), Color(0xFFE36135)],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PilihKurirPage(role: 'makanan'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      MenuButton(
                        label: "Pengantaran \nPenumpang",
                        iconPath: 'lib/assets/passanger.png',
                        colors: [Color(0xFFEF5B2E), Color(0xFFB3350E)],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PilihKurirPage(role: 'penumpang'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      MenuButton(
                        label: "Pengantaran \nSembako",
                        iconPath: 'lib/assets/sembako.png',
                        colors: [Color(0xFFEF5B2E), Color(0xFFB3350E)],
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const PilihKurirPage(role: 'sembako'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget greetingCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF334856), Color(0xFF063178)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color.fromARGB(80, 0, 0, 0),
            blurRadius: 16,
            spreadRadius: 2,
            offset: Offset(4, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset('lib/assets/hi_icon.png', height: 80, width: 80),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hai, $userName',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Mau pesan apa hari ini?',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget promoCard(String imagePath) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
