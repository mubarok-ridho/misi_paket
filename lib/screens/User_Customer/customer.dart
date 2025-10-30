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
      backgroundColor: const Color(0xFF0F172A),
      body: pages.isNotEmpty
          ? pages[_selectedIndex]
          : const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFF24B1D)),
              ),
            ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF1E293B),
          selectedItemColor: const Color(0xFFF24B1D),
          unselectedItemColor: Colors.grey[400],
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          items: [
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _selectedIndex == 0 
                      ? const Color(0xFFF24B1D).withOpacity(0.15)
                      : Colors.transparent,
                ),
                child: Icon(
                  Icons.home_rounded,
                  size: _selectedIndex == 0 ? 24 : 22,
                ),
              ),
              label: 'Beranda',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _selectedIndex == 1 
                      ? const Color(0xFFF24B1D).withOpacity(0.15)
                      : Colors.transparent,
                ),
                child: Icon(
                  Icons.assignment_rounded,
                  size: _selectedIndex == 1 ? 24 : 22,
                ),
              ),
              label: 'Order',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: _selectedIndex == 2 
                      ? const Color(0xFFF24B1D).withOpacity(0.15)
                      : Colors.transparent,
                ),
                child: Icon(
                  Icons.person_rounded,
                  size: _selectedIndex == 2 ? 24 : 22,
                ),
              ),
              label: 'Profile',
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
    final isMobile = MediaQuery.of(context).size.width < 600;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: isMobile ? 110 : 130,
        width: double.infinity,
        margin: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 12,
              offset: const Offset(2, 4),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Text Content
            Padding(
              padding: EdgeInsets.only(
                left: isMobile ? 20 : 24,
                right: 100,
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: isMobile ? 22 : 26,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
              ),
            ),
            
            // Icon/Image
            Positioned(
              right: -15,
              bottom: -15,
              child: Image.asset(
                iconPath,
                height: isMobile ? 140 : 160,
                width: isMobile ? 140 : 160,
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
          duration: const Duration(milliseconds: 400),
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
    final isMobile = MediaQuery.of(context).size.width < 600;
    final isTablet = MediaQuery.of(context).size.width >= 600 && 
                    MediaQuery.of(context).size.width < 1200;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 20 : isTablet ? 32 : 48,
        ),
        child: Column(
          children: [
            SizedBox(height: isMobile ? 60 : 80),
            
            // Promo Carousel
            _buildPromoCarousel(isMobile),
            
            SizedBox(height: isMobile ? 32 : 40),
            
            // Greeting Card
            _buildGreetingCard(isMobile),
            
            SizedBox(height: isMobile ? 32 : 40),
            
            // Services Grid
            _buildServicesGrid(isMobile),
            
            SizedBox(height: isMobile ? 40 : 60),
          ],
        ),
      ),
    );
  }

  Widget _buildPromoCarousel(bool isMobile) {
    return Column(
      children: [
        SizedBox(
          height: isMobile ? 140 : 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: promoImages.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (context, index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: EdgeInsets.symmetric(horizontal: isMobile ? 4 : 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: AssetImage(promoImages[index]),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        // Page Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(promoImages.length, (index) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: _currentPage == index 
                    ? const Color(0xFFF24B1D) 
                    : Colors.grey.withOpacity(0.5),
                borderRadius: BorderRadius.circular(4),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildGreetingCard(bool isMobile) {
    return Container(
      height: isMobile ? 120 : 140,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF334856), Color(0xFF063178)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 16,
            spreadRadius: 1,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Content
          Padding(
            padding: EdgeInsets.only(
              left: isMobile ? 120 : 140,
              right: 20,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Haii ${widget.userName}',
                  style: TextStyle(
                    fontSize: isMobile ? 22 : 26,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Lagi butuh apa hari ini?',
                  style: TextStyle(
                    fontSize: isMobile ? 14 : 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Character Image
          Positioned(
            left: -20,
            top: -10,
            child: Image.asset(
              'lib/assets/hi_icon.png',
              height: isMobile ? 140 : 160,
              width: isMobile ? 140 : 160,
              fit: BoxFit.contain,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServicesGrid(bool isMobile) {
    final services = [
      {
        'label': "Pengantaran\nBarang",
        'iconPath': 'lib/assets/goods.png',
        'colors': [const Color(0xFFEF5B2E), const Color(0xFFA32F0C)],
        'role': 'barang',
      },
      {
        'label': "Pengantaran\nMakanan",
        'iconPath': 'lib/assets/food.png',
        'colors': [const Color(0xFFA32F0C), const Color(0xFFE36135)],
        'role': 'makanan',
      },
      {
        'label': "Pengantaran\nPenumpang",
        'iconPath': 'lib/assets/passanger.png',
        'colors': [const Color(0xFFEF5B2E), const Color(0xFFA32F0C)],
        'role': 'penumpang',
      },
      {
        'label': "Pengantaran\nSembako",
        'iconPath': 'lib/assets/sembako.png',
        'colors': [const Color(0xFFA32F0C), const Color(0xFFE36135)],
        'role': 'sembako',
      },
    ];

    return Column(
      children: services.map((service) {
        return MenuButton(
          label: service['label'] as String,
          iconPath: service['iconPath'] as String,
          colors: service['colors'] as List<Color>,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => PilihKurirPage(role: service['role'] as String),
              ),
            );
          },
        );
      }).toList(),
    );
  }
}