import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:misi_paket/bloc/order_bloc/order_bloc.dart';
import 'package:misi_paket/bloc/order_bloc/order_state.dart';

class PesananDiprosesPage extends StatefulWidget {
  const PesananDiprosesPage({super.key});

  @override
  State<PesananDiprosesPage> createState() => _PesananDiprosesPageState();
}

class _PesananDiprosesPageState extends State<PesananDiprosesPage> {
  LatLng? _kurirPosition;
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _startPollingLokasiKurir();
  }

  void _startPollingLokasiKurir() {
    final state = context.read<OrderBloc>().state;
    if (state is OrderLoadedState && state.kurirId != null) {
      _fetchKurirLocation(state.kurirId!);
      _locationTimer = Timer.periodic(const Duration(seconds: 5), (_) {
        _fetchKurirLocation(state.kurirId!);
      });
    }
  }

  Future<void> _fetchKurirLocation(int kurirId) async {
    try {
      final response = await http
          .get(Uri.parse("http://localhost:8080/kurir/track/$kurirId"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final lat = data['lat'] as double;
        final lng = data['lng'] as double;
        setState(() {
          _kurirPosition = LatLng(lat, lng);
        });
      } else {
        print("⚠️ Tidak bisa ambil lokasi: ${response.body}");
      }
    } catch (e) {
      print("❌ Gagal ambil lokasi kurir: $e");
    }
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Pesanan Diproses"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<OrderBloc, OrderState>(
        builder: (context, state) {
          if (state is OrderLoadedState) {
            final alamatAntar = state.alamatAntar ?? "-";
            final alamatJemput = state.alamatJemput ?? "-";
            final kurirLatLng = _kurirPosition ?? const LatLng(-7.424, 109.244);

            return Column(
              children: [
                Expanded(
                  child: FlutterMap(
                    options: MapOptions(
                      center: kurirLatLng,
                      zoom: 14.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                        subdomains: const ['a', 'b', 'c'],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: kurirLatLng,
                            width: 40,
                            height: 40,
                            child: const Icon(Icons.motorcycle,
                                color: Colors.deepOrange, size: 32),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text("Kurir sedang menuju lokasi",
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text("Jemput: $alamatJemput"),
                      Text("Antar: $alamatAntar"),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Navigasi ke halaman chat jika sudah ada
                        },
                        icon: const Icon(Icons.chat),
                        label: const Text("Chat dengan Kurir"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
