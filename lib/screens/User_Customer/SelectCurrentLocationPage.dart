import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_typeahead/flutter_typeahead.dart';

class SelectCurrentLocationPage extends StatefulWidget {
  const SelectCurrentLocationPage({super.key});

  @override
  State<SelectCurrentLocationPage> createState() => _SelectCurrentLocationPageState();
}

class _SelectCurrentLocationPageState extends State<SelectCurrentLocationPage> {
  LatLng center = const LatLng(-6.2, 106.8);
  final mapController = MapController();
  final addressController = TextEditingController();
  bool isLoading = false;

  Future<String> getAddressFromLatLng(LatLng latLng) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?format=jsonv2&lat=${latLng.latitude}&lon=${latLng.longitude}');
    try {
      final response = await http.get(url, headers: {'User-Agent': 'misi_paket_app'});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['display_name'] ?? 'Alamat tidak ditemukan';
      }
    } catch (_) {}
    return 'Alamat tidak ditemukan';
  }

  Future<List<LocationSuggestion>> fetchSuggestions(String query) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5');
    final response = await http.get(url, headers: {'User-Agent': 'misi_paket_app'});
    if (response.statusCode == 200) {
      final List raw = jsonDecode(response.body);
      return raw.map((item) {
        final display = item['display_name'] as String;
        final lat = double.tryParse(item['lat']) ?? 0;
        final lon = double.tryParse(item['lon']) ?? 0;
        return LocationSuggestion(display, LatLng(lat, lon));
      }).toList();
    }
    return [];
  }

  Future<void> saveAndReturn() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_address', addressController.text);
    await prefs.setDouble('selected_lat', center.latitude);
    await prefs.setDouble('selected_lng', center.longitude);

    Navigator.pop(context, {
      'address': addressController.text,
      'latlng': center,
    });
  }

  @override
  void dispose() {
    addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text("Pilih Lokasi Anda"),
        backgroundColor: const Color(0xFF2B2B2B),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
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
                urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                userAgentPackageName: 'com.example.misi_paket',
              ),
            ],
          ),

          // Pin di tengah
          Center(child: Icon(Icons.location_on, size: 40, color: Colors.orange)),

          // Search Bar Alamat
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              elevation: 6,
              child: TypeAheadField<LocationSuggestion>(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: addressController,
                  style: const TextStyle(fontSize: 16),
                  decoration: const InputDecoration(
                    hintText: "Cari alamat...",
                    prefixIcon: Icon(Icons.search),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  ),
                ),
                suggestionsCallback: fetchSuggestions,
                itemBuilder: (context, suggestion) {
                  return ListTile(title: Text(suggestion.displayName));
                },
                onSuggestionSelected: (suggestion) {
                  addressController.text = suggestion.displayName;
                  mapController.move(suggestion.coordinates, 15);
                  setState(() => center = suggestion.coordinates);
                },
                suggestionsBoxDecoration: SuggestionsBoxDecoration(
                  color: Colors.white,
                  elevation: 4,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          // Tombol simpan
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: () async {
                    setState(() => isLoading = true);
                    final alamat = await getAddressFromLatLng(center);
                    addressController.text = alamat;
                    setState(() => isLoading = false);
                  },
                  icon: const Icon(Icons.pin_drop),
                  label: const Text("Ambil Alamat dari Pin"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: isLoading ? null : saveAndReturn,
                  icon: const Icon(Icons.save),
                  label: const Text("Simpan Lokasi"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF24B1D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class LocationSuggestion {
  final String displayName;
  final LatLng coordinates;
  LocationSuggestion(this.displayName, this.coordinates);
}
