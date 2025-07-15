import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:misi_paket/screens/User_Customer/customer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:misi_paket/screens/User_Customer/chatpage.dart';
import 'package:misi_paket/screens/User_Customer/order_model.dart';

class PesananDiprosesPage extends StatefulWidget {
  final OrderSummary order;

  const PesananDiprosesPage({super.key, required this.order});

  @override
  State<PesananDiprosesPage> createState() => _PesananDiprosesPageState();
}

class _PesananDiprosesPageState extends State<PesananDiprosesPage> {
  LatLng? _kurirPosition;
  LatLng? _lokasiJemput;
  LatLng? _lokasiAntar;
  List<LatLng> _routePoints = [];
  Timer? _locationTimer;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetailAndStartTracking();
  }

  Future<void> _fetchOrderDetailAndStartTracking() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) return;

    final url = Uri.parse("http://localhost:8080/api/orders/${widget.order.id}");
    final response = await http.get(url, headers: {
      "Authorization": "Bearer $token",
    });

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final jemputLat = double.tryParse(data['lat_jemput'].toString());
      final jemputLng = double.tryParse(data['lng_jemput'].toString());
      final antarLat = double.tryParse(data['lat_antar'].toString());
      final antarLng = double.tryParse(data['lng_antar'].toString());

      if (jemputLat != null && jemputLng != null && antarLat != null && antarLng != null) {
        setState(() {
          _lokasiJemput = LatLng(jemputLat, jemputLng);
          _lokasiAntar = LatLng(antarLat, antarLng);
        });

        _fetchPolylineRoute();
        _startPollingLokasiKurir();
      }
    }
  }

  void _startPollingLokasiKurir() {
    _fetchKurirLocation(widget.order.kurirId);
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      _fetchKurirLocation(widget.order.kurirId);
    });
  }

  Future<void> _fetchKurirLocation(int kurirId) async {
    try {
      final response = await http.get(
        Uri.parse("http://localhost:8080/kurir/track/$kurirId"),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final lat = data['lat'];
        final lng = data['lng'];

        if (lat != null && lng != null) {
          setState(() {
            _kurirPosition = LatLng(lat.toDouble(), lng.toDouble());
          });
        }
      }
    } catch (_) {}
  }

  Future<void> _fetchPolylineRoute() async {
    if (_lokasiJemput == null || _lokasiAntar == null) return;

    final url = Uri.parse(
        "https://router.project-osrm.org/route/v1/driving/${_lokasiAntar!.longitude},${_lokasiAntar!.latitude};${_lokasiJemput!.longitude},${_lokasiJemput!.latitude}?overview=full&geometries=geojson");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final coords = data['routes'][0]['geometry']['coordinates'] as List;

      setState(() {
        _routePoints = coords.map((point) => LatLng(point[1], point[0])).toList();
      });
    }
  }

  @override
  void dispose() {
    _locationTimer?.cancel();
    super.dispose();
  }

  void _navigateToDashboard(BuildContext context) {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const CustomerDashboard()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_lokasiJemput == null || _lokasiAntar == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final jemput = _lokasiJemput!;
    final antar = _lokasiAntar!;
    final center = LatLng(
      (jemput.latitude + antar.latitude) / 2,
      (jemput.longitude + antar.longitude) / 2,
    );
    final kurir = _kurirPosition ?? center;

    return WillPopScope(
      onWillPop: () async {
        _navigateToDashboard(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF24313F),
        body: Stack(
          children: [
            FlutterMap(
              options: MapOptions(center: center, zoom: 14.0),
              children: [
                TileLayer(
                  urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                  subdomains: const ['a', 'b', 'c'],
                ),
                if (_routePoints.isNotEmpty)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: _routePoints,
                        strokeWidth: 5,
                        color: const Color(0xFF0B82A3),
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: jemput,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.my_location, color: Color(0xFFFF7E30), size: 36),
                    ),
                    Marker(
                      point: antar,
                      width: 40,
                      height: 40,
                      child: const Icon(Icons.pin_drop, color: Color(0xFFE04924), size: 36),
                    ),
                    Marker(
                      point: kurir,
                      width: 40,
                      height: 40,
                      child: Image.asset(
                        'lib/assets/icons/motor_kurir.png',
                        errorBuilder: (_, __, ___) => const Icon(Icons.motorcycle, color: Colors.blue, size: 36),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF3C4A57),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildAlamatInfo("Lokasi Penjemputan", widget.order.alamatJemput),
                    const SizedBox(height: 12),
                    _buildAlamatInfo("Lokasi Pengantaran", widget.order.alamatAntar),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatPageCustomer(orderId: widget.order.id.toString()),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF7E30),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.chat),
                      label: const Text("Buka Chat dengan Kurir"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlamatInfo(String label, String? alamat) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.location_on, color: Colors.orangeAccent),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white)),
              const SizedBox(height: 4),
              Text(alamat ?? '-', style: const TextStyle(color: Color(0xFFA5B0BA))),
            ],
          ),
        ),
      ],
    );
  }
}
