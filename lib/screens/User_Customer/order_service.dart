import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:misi_paket/screens/User_Customer/order_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<List<OrderSummary>> fetchCustomerOrders() async {
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('token');
  final userId = prefs.getInt('userId'); // Ambil user ID

  if (token == null || userId == null) {
    throw Exception('Token atau User ID tidak ditemukan');
  }

  final response = await http.get(
    Uri.parse('https://gin-production-77e5.up.railway.app/api/my-orders'),
    headers: {'Authorization': 'Bearer $token'},
  );

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);

    // 🔥 FILTER: hanya milik user & status proses
    return data
        .map((json) => OrderSummary.fromJson(json))
        .where((order) =>
            order.customerId == userId &&
            order.status.toLowerCase() == 'proses')
        .toList();
  } else {
    throw Exception('Gagal memuat daftar order');
  }
}
