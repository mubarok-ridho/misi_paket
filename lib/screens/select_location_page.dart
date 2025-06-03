import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LokasiPickerPage extends StatefulWidget {
  @override
  State<LokasiPickerPage> createState() => _LokasiPickerPageState();
}

class _LokasiPickerPageState extends State<LokasiPickerPage> {
  final TextEditingController jemputController = TextEditingController();
  final TextEditingController antarController = TextEditingController();
  final MapController mapController = MapController();
  LatLng center = LatLng(-6.2, 106.8); // default Jakarta
  bool isLoading = false;

  Future<String> getAddressFromLatLng(LatLng latLng) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${latLng.latitude}&lon=${latLng.longitude}',
    );

    try {
      final response = await http.get(url, headers: {
        'User-Agent': 'misi_paket_app',
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('display_name')) {
          return data['display_name'];
        } else {
          print("Data tidak sesuai format: ${response.body}");
          return 'Alamat tidak ditemukan';
        }
      } else {
        print("Status bukan 200: ${response.statusCode}");
        return 'Alamat tidak ditemukan';
      }
    } catch (e) {
      print("Gagal mengambil alamat: $e");
      return 'Alamat tidak ditemukan';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              center: center,
              zoom: 15,
              onPositionChanged: (pos, _) {
                setState(() {
                  center = pos.center!;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.misi_paket',
              ),
            ],
          ),

          // PIN TETAP DI TENGAH
          Center(
            child: Icon(Icons.location_on, size: 40, color: Colors.orange),
          ),

          // BOX INPUT ALAMAT (HANYA 1x)
          Positioned(
            top: 60,
            left: 20,
            right: 20,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.orange.withOpacity(0.9),
              ),
              padding: EdgeInsets.all(12),
              child: Column(
                children: [
                  _buildInputBox("Lokasi jemput paket kamu", jemputController),
                  SizedBox(height: 10),
                  _buildInputBox("Lokasi antar paket kamu", antarController),
                ],
              ),
            ),
          ),

          // BOTTOM PANEL
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blueGrey[800],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_pin, color: Colors.red),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "Titik dipilih: ${center.latitude.toStringAsFixed(5)}, ${center.longitude.toStringAsFixed(5)}",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  isLoading
                      ? CircularProgressIndicator(color: Colors.orange)
                      : ElevatedButton(
                          onPressed: () async {
                            setState(() => isLoading = true);
                            final alamat = await getAddressFromLatLng(center);
                            setState(() => isLoading = false);

                            if (jemputController.text.isEmpty) {
                              jemputController.text = alamat;
                            } else if (antarController.text.isEmpty) {
                              antarController.text = alamat;
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Kedua alamat sudah diisi."),
                                ),
                              );
                              return;
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Alamat berhasil diatur."),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                          child: Text(
                            "Set Lokasi",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0, // Sesuaikan
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Order"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }

  Widget _buildInputBox(String hint, TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        controller: controller,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: InputBorder.none,
          hintText: hint,
          hintStyle: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }
}