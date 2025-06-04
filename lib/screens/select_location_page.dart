import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'pilih_kurir_page.dart';
import 'package:latlong2/latlong.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';

class LokasiPickerPage extends StatefulWidget {
  @override
  State<LokasiPickerPage> createState() => _LokasiPickerPageState();
}

class _LokasiPickerPageState extends State<LokasiPickerPage> {
  final TextEditingController jemputController = TextEditingController();
  final TextEditingController antarController = TextEditingController();
  final FocusNode jemputFocus = FocusNode();
  final FocusNode antarFocus = FocusNode();
  final MapController mapController = MapController();
  LatLng center = LatLng(-6.2, 106.8);
  bool isLoading = false;

  Future<String> getAddressFromLatLng(LatLng latLng) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${latLng.latitude}&lon=${latLng.longitude}',
    );
    try {
      final response = await http.get(url, headers: {'User-Agent': 'misi_paket_app'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['display_name'] ?? 'Alamat tidak ditemukan';
      }
    } catch (_) {}
    return 'Alamat tidak ditemukan';
  }

  Future<List<LocationSuggestion>> fetchLocationSuggestions(String query) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5',
    );
    final response = await http.get(url, headers: {'User-Agent': 'misi_paket_app'});
    if (response.statusCode == 200) {
      final List raw = jsonDecode(response.body);
      return raw.map((item) {
        final display = item['display_name'] as String;
        final lat = double.tryParse(item['lat'] as String) ?? 0;
        final lon = double.tryParse(item['lon'] as String) ?? 0;
        return LocationSuggestion(display, LatLng(lat, lon));
      }).toList();
    }
    return [];
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
                urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.misi_paket',
              ),
            ],
          ),

          Center(child: Icon(Icons.location_on, size: 40, color: Colors.orange)),

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
                  _buildInputBox(
                    "Lokasi jemput paket kamu",
                    jemputController,
                    jemputFocus,
                    (coords) {
                      setState(() {
                        center = coords;
                      });
                      mapController.move(coords, 15);
                    },
                  ),
                  SizedBox(height: 10),
                  _buildInputBox(
                    "Lokasi antar paket kamu",
                    antarController,
                    antarFocus,
                    (coords) {
                      setState(() {
                        center = coords;
                      });
                      mapController.move(coords, 15);
                    },
                  ),
                ],
              ),
            ),
          ),

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
    : Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              setState(() => isLoading = true);
              final alamat = await getAddressFromLatLng(center);
              setState(() => isLoading = false);

              if (jemputFocus.hasFocus) {
                jemputController.text = alamat;
              } else if (antarFocus.hasFocus) {
                antarController.text = alamat;
              } else {
                if (jemputController.text.isEmpty) {
                  jemputController.text = alamat;
                } else {
                  antarController.text = alamat;
                }
              }

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Alamat berhasil diatur")),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
            child: Text("Set Lokasi",
                style: TextStyle(color: Colors.white)),
          ),
          SizedBox(height: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PilihKurirPage(),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: Text("Konfirmasi & Pilih Kurir",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),

                ],
              ),
            ),
          ),
        ],
      ),
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

  Widget _buildInputBox(
    String hint,
    TextEditingController controller,
    FocusNode focusNode,
    Function(LatLng) onSuggestionSelected,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TypeAheadField<LocationSuggestion>(
        textFieldConfiguration: TextFieldConfiguration(
          controller: controller,
          focusNode: focusNode,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            border: InputBorder.none,
            hintText: hint,
            hintStyle: TextStyle(color: Colors.white70),
          ),
        ),
        suggestionsCallback: (pattern) async {
          if (pattern.trim().isEmpty) return [];
          return await fetchLocationSuggestions(pattern);
        },
        itemBuilder: (context, suggestion) {
          return ListTile(
            title: Text(
              suggestion.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          );
        },
        onSuggestionSelected: (suggestion) {
          controller.text = suggestion.name;
          onSuggestionSelected(suggestion.coords);
        },
        noItemsFoundBuilder: (context) => Padding(
          padding: EdgeInsets.all(12),
          child: Text(
            'Tidak ada lokasi ditemukan',
            style: TextStyle(color: Colors.white70),
          ),
        ),
        suggestionsBoxDecoration: SuggestionsBoxDecoration(
          color: Colors.black87,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class LocationSuggestion {
  final String name;
  final LatLng coords;
  LocationSuggestion(this.name, this.coords);
}
