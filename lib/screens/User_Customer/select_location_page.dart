import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:misi_paket/bloc/order_bloc/order_bloc.dart';
import 'package:misi_paket/bloc/order_bloc/order_event.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LokasiPickerPage extends StatefulWidget {
  final String role;
  const LokasiPickerPage({Key? key, required this.role}) : super(key: key);

  @override
  _LokasiPickerPageState createState() => _LokasiPickerPageState();
}

class _LokasiPickerPageState extends State<LokasiPickerPage> {
  LatLng center = LatLng(-6.200000, 106.816666);
  LatLng? lokasiJemput;
  LatLng? lokasiAntar;

  final jemputController = TextEditingController();
  final antarController = TextEditingController();
  final jemputFocus = FocusNode();
  final antarFocus = FocusNode();
  final mapController = MapController();
  bool isLoading = false;

  FocusNode? lastFocus;

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
  void dispose() {
    jemputController.dispose();
    antarController.dispose();
    jemputFocus.dispose();
    antarFocus.dispose();
    super.dispose();
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
              MarkerLayer(
                markers: [
                  if (lokasiJemput != null)
                    Marker(
                      point: lokasiJemput!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, size: 40, color: Colors.green),
                    ),
                  if (lokasiAntar != null)
                    Marker(
                      point: lokasiAntar!,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.location_on, size: 40, color: Colors.red),
                    ),
                ],
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
                    "Lokasi jemput",
                    jemputController,
                    jemputFocus,
                    (coords) {
                      setState(() {
                        lokasiJemput = coords;
                        center = coords;
                      });
                      mapController.move(coords, 15);
                      lastFocus = jemputFocus;
                    },
                  ),
                  SizedBox(height: 10),
                  _buildInputBox(
                    "Lokasi antar",
                    antarController,
                    antarFocus,
                    (coords) {
                      setState(() {
                        lokasiAntar = coords;
                        center = coords;
                      });
                      mapController.move(coords, 15);
                      lastFocus = antarFocus;
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

                                if (lastFocus == jemputFocus) {
                                  jemputController.text = alamat;
                                  lokasiJemput = center;
                                } else if (lastFocus == antarFocus) {
                                  antarController.text = alamat;
                                  lokasiAntar = center;
                                }

                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Alamat berhasil diatur")),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                              ),
                              child: Text("Set Lokasi", style: TextStyle(color: Colors.white)),
                            ),
                            SizedBox(height: 8),
                            ElevatedButton(
  onPressed: () async {
    if (widget.role == 'dashboard') {
      final alamat = await getAddressFromLatLng(center);
      Navigator.pop(context, {
        'address': alamat,
        'latlng': center,
      });
    } else {
      // ✅ Validasi: lokasi jemput & antar harus dipilih
      if (lokasiJemput == null || lokasiAntar == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Pilih dan set lokasi jemput & antar terlebih dahulu.")),
        );
        return;
      }

      // ✅ Validasi: jemput & antar tidak boleh sama
      if (lokasiJemput == lokasiAntar) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lokasi jemput dan antar tidak boleh sama.")),
        );
        return;
      }

      // ✅ Lanjut ke proses normal
      context.read<OrderBloc>().add(SetLokasiEvent(
        role: widget.role,
        alamatJemput: jemputController.text,
        lokasiJemput: lokasiJemput!,
        alamatAntar: antarController.text,
        lokasiAntar: lokasiAntar!,
      ));

    print("Jemput: ${lokasiJemput!.latitude}, ${lokasiJemput!.longitude}");
print("Antar : ${lokasiAntar!.latitude}, ${lokasiAntar!.longitude}"); 


      Navigator.pushNamed(
        context,
        '/pilih_kurir',
        arguments: widget.role,
      );
    }
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
  ),
  child: Text(
    widget.role == 'dashboard' ? "Simpan Lokasi" : "Konfirmasi & Pilih Kurir",
    style: TextStyle(color: Colors.white),
  ),
),

                          ],
                        ),
                ],
              ),
            ),
          ),
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
            title: Text(suggestion.displayName, style: TextStyle(color: Colors.white)),
          );
        },
        onSuggestionSelected: (suggestion) {
          onSuggestionSelected(suggestion.coordinates);
          lastFocus = focusNode;
          FocusScope.of(context).unfocus();
        },
        suggestionsBoxDecoration: SuggestionsBoxDecoration(
          color: Colors.grey[900],
          elevation: 5,
          borderRadius: BorderRadius.circular(12),
        ),
        hideOnEmpty: true,
      ),
    );
  }
}

class LocationSuggestion {
  final String displayName;
  final LatLng coordinates;
  LocationSuggestion(this.displayName, this.coordinates);
}
