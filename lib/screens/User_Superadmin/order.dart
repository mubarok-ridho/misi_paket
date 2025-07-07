import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Admin Dashboard',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: AdminDashboard(),
    );
  }
}

class AdminDashboard extends StatefulWidget {
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  final pages = [
    AdminHomeTab(),
    CreateCourierTab(),
    OrderHistoryTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Color(0xFF334856),
        selectedItemColor: Colors.orangeAccent,
        unselectedItemColor: Colors.white70,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_add),
            label: 'Tambah Kurir',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
        ],
      ),
    );
  }
}

class AdminHomeTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                children: [
                  Icon(Icons.admin_panel_settings, color: Color(0xFFDE6029)),
                  SizedBox(width: 5),
                  Text("Admin Dashboard",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                  Spacer(),
                  CircleAvatar(
                    backgroundColor: Color(0xFFDE6029),
                    child: Icon(Icons.person, color: Colors.white),
                  )
                ],
              ),
              SizedBox(height: 20),

              // Statistics Banner
              Container(
                height: 150,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFDE6029), Color(0xFFF58A5C)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  padding: EdgeInsets.all(16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Dashboard Statistik",
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18)),
                      SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard("Total Kurir", "12"),
                          _buildStatCard("Pesanan Hari Ini", "45"),
                          _buildStatCard("Pesanan Selesai", "1,234"),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),

              // Quick Actions
              Text("Aksi Cepat",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 16),

              AdminMenuButton(
                  label: "Buat Akun Kurir Baru",
                  icon: Icons.person_add,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => CreateCourierPage()),
                    );
                  }),
              SizedBox(height: 16),
              AdminMenuButton(
                  label: "Lihat Riwayat Pesanan",
                  icon: Icons.history,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => OrderHistoryPage()),
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(value,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold)),
          SizedBox(height: 4),
          Text(title,
              style: TextStyle(color: Colors.white70, fontSize: 10),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class CreateCourierTab extends StatefulWidget {
  @override
  _CreateCourierTabState createState() => _CreateCourierTabState();
}

class _CreateCourierTabState extends State<CreateCourierTab> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _teleponController = TextEditingController();
  final _alamatController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.person_add, color: Color(0xFFDE6029)),
                  SizedBox(width: 8),
                  Text("Tambah Kurir",
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 20),

              // Form
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildTextField(
                      controller: _namaController,
                      label: "Nama Lengkap",
                      icon: Icons.person,
                    ),
                    SizedBox(height: 16),
                    _buildTextField(
                      controller: _emailController,
                      label: "Email",
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16),

                    // Password Field
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        labelText: "Password",
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Color(0xFFDE6029)),
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility
                                : Icons.visibility_off,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password tidak boleh kosong';
                        }
                        if (value.length < 6) {
                          return 'Password minimal 6 karakter';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    _buildTextField(
                      controller: _teleponController,
                      label: "Nomor Telepon",
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                    ),
                    SizedBox(height: 16),

                    // Alamat Field
                    _buildTextField(
                      controller: _alamatController,
                      label: "Alamat",
                      icon: Icons.location_on,
                      maxLines: 3,
                    ),
                    SizedBox(height: 30),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFDE6029),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Buat Akun Kurir",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFFDE6029)),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label tidak boleh kosong';
        }
        return null;
      },
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      // Simulasi pembuatan akun
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Berhasil"),
          content: Text("Akun kurir ${_namaController.text} berhasil dibuat!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _clearForm();
              },
              child: Text("OK"),
            ),
          ],
        ),
      );
    }
  }

  void _clearForm() {
    _namaController.clear();
    _emailController.clear();
    _teleponController.clear();
    _alamatController.clear();
    _passwordController.clear();
  }
}

class OrderHistoryTab extends StatefulWidget {
  @override
  _OrderHistoryTabState createState() => _OrderHistoryTabState();
}

class _OrderHistoryTabState extends State<OrderHistoryTab> {
  final List<Map<String, dynamic>> _allOrders = [
    {
      'id': 'ORD001',
      'kurir': 'Ahmad Wijaya',
      'pelanggan': 'Budi Santoso',
      'jenis': 'Pengantaran Makanan',
      'status': 'Selesai',
      'tanggal': '15 Jun 2025',
    },
    {
      'id': 'ORD002',
      'kurir': 'Siti Nurhaliza',
      'pelanggan': 'Dewi Lestari',
      'jenis': 'Pengantaran Barang',
      'status': 'Selesai',
      'tanggal': '15 Jun 2025',
    },
    {
      'id': 'ORD003',
      'kurir': 'Rizki Pratama',
      'pelanggan': 'Andi Setiawan',
      'jenis': 'Pengantaran Penumpang',
      'status': 'Selesai',
      'tanggal': '14 Jun 2025',
    },
    {
      'id': 'ORD004',
      'kurir': 'Maya Sari',
      'pelanggan': 'Rudi Hermawan',
      'jenis': 'Pengantaran Makanan',
      'status': 'Selesai',
      'tanggal': '14 Jun 2025',
    },
  ];

  List<Map<String, dynamic>> _filteredOrders = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredOrders = _allOrders;
    _searchController.addListener(_searchOrders);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchOrders() {
    final query = _searchController.text.toLowerCase();

    if (query.isEmpty) {
      setState(() {
        _filteredOrders = _allOrders;
      });
      return;
    }

    setState(() {
      _filteredOrders = _allOrders.where((order) {
        final id = order['id'].toString().toLowerCase();
        final kurir = order['kurir'].toString().toLowerCase();
        final pelanggan = order['pelanggan'].toString().toLowerCase();

        return id.contains(query) ||
            kurir.contains(query) ||
            pelanggan.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(Icons.history, color: Color(0xFFDE6029)),
                SizedBox(width: 8),
                Text("Riwayat Pesanan",
                    style:
                        TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            SizedBox(height: 20),

            // Search Bar
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey.shade600),
                  SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText:
                            "Cari berdasarkan ID, nama kurir, atau pelanggan",
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    IconButton(
                      icon: Icon(Icons.clear, color: Colors.grey.shade600),
                      onPressed: () {
                        _searchController.clear();
                      },
                    ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Order List
            Expanded(
              child: _filteredOrders.isEmpty
                  ? Center(
                      child: Text(
                        "Tidak ada pesanan yang ditemukan",
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredOrders.length,
                      itemBuilder: (context, index) {
                        final order = _filteredOrders[index];
                        return _buildOrderCard(order);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                order['id'],
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFFDE6029)),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  order['status'],
                  style: TextStyle(
                      color: Colors.green.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.person, size: 16, color: Colors.grey.shade600),
              SizedBox(width: 4),
              Text("Kurir: ${order['kurir']}",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.account_circle, size: 16, color: Colors.grey.shade600),
              SizedBox(width: 4),
              Text("Pelanggan: ${order['pelanggan']}",
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(Icons.category, size: 16, color: Colors.grey.shade600),
              SizedBox(width: 4),
              Text(order['jenis'],
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade700)),
            ],
          ),
          SizedBox(height: 8),
          Text(order['tanggal'],
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        ],
      ),
    );
  }
}

class CreateCourierPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tambah Kurir"),
        backgroundColor: Color(0xFFDE6029),
        foregroundColor: Colors.white,
      ),
      body: CreateCourierTab(),
    );
  }
}

class OrderHistoryPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Riwayat Pesanan"),
        backgroundColor: Color(0xFFDE6029),
        foregroundColor: Colors.white,
      ),
      body: OrderHistoryTab(),
    );
  }
}

class AdminMenuButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const AdminMenuButton({
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFDE6029), Color(0xFFF58A5C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(2, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
          ],
        ),
      ),
    );
  }
}
