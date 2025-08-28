import 'dart:async';
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
        Uri.parse('https://gin-production-77e5.up.railway.app/api/users/profile'),
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
          }
        },
      ),
      const OrderListPage(),
      ProfilePage(),
    ];
    setState(() {});
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
            height: 120,
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
                    fontSize: 28,
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
              height: 185,
              width: 185,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }
}

// Ini bagian HomeTab yang gue ubah jadi StatefulWidget dengan auto scroll promoCard di atas
class HomeTab extends StatefulWidget {
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
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<String> promoImages = [
    'lib/assets/promo1.png',
    'lib/assets/promo2.png',
    'lib/assets/promo3.png',
  ];
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAutoScroll();
  }

  void _startAutoScroll() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_pageController.hasClients) {
        _currentPage++;
        if (_currentPage >= promoImages.length) {
          _currentPage = 0;
        }
        _pageController.animateToPage(
          _currentPage,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 17), // kasih jarak kiri kanan semua isi 8 px
              child: Column(
                children: [
                  const SizedBox(height: 90), // kasih jarak 16px dari atas
              
                  // Promo card dipindah paling atas biar nongol duluan
                  Padding(
                    padding: const EdgeInsets.only(top:15),
                    child: SizedBox(
                      height: MediaQuery.of(context).size.width * 0.355,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: promoImages.length,
                        itemBuilder: (context, index) {
                          return promoCard(promoImages[index]);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 50),
                  greetingCard(),
                  const SizedBox(height: 35),
                  MenuButton(
                    label: "Pengantaran \nBarang",
                    iconPath: 'lib/assets/goods.png',
                    colors: [
                      Color(0xFFEF5B2E),
                      Color.fromARGB(255, 163, 47, 12)
                    ],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PilihKurirPage(role: 'barang'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  MenuButton(
                    label: "Pengantaran \nMakanan",
                    iconPath: 'lib/assets/food.png',
                    colors: [Color.fromARGB(255, 163, 47, 12), Color(0xFFE36135)],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PilihKurirPage(role: 'makanan'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  MenuButton(
                    label: "Pengantaran \nPenumpang",
                    iconPath: 'lib/assets/passanger.png',
                    colors: [Color(0xFFEF5B2E), Color.fromARGB(255, 163, 47, 12)],
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PilihKurirPage(role: 'penumpang'),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 2),
                  MenuButton(
                    label: "Pengantaran \nSembako",
                    iconPath: 'lib/assets/sembako.png',
                    colors: [Color.fromARGB(255, 163, 47, 12), Color(0xFFE36135)],
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
          ),
        );
      },
    );
  }

  Widget greetingCard() {
    return SizedBox(
      height: 120,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background card
          Container(
            padding: const EdgeInsets.only(
                left: 135, right: 20, top: 16, bottom: 16),
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
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Haii ${widget.userName}',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Lagi butuh apa hari ini?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Gambar yang menumpuk dan keluar dari card
          Positioned(
            left: -10,
            top: -20,
            child: Image.asset(
              'lib/assets/hi_icon.png',
              height: 140,
              width: 140,
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
