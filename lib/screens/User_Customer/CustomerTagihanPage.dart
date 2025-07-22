import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CustomerTagihanPage extends StatefulWidget {
  final int orderId;

  const CustomerTagihanPage({super.key, required this.orderId});

  @override
  State<CustomerTagihanPage> createState() => _CustomerTagihanPageState();
}

class _CustomerTagihanPageState extends State<CustomerTagihanPage> {
  bool isLoading = true;
  Map<String, dynamic>? order;
  String? selectedMethod;
  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    fetchTagihan();
  }

  Future<void> fetchTagihan() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");

    final url = Uri.parse("http://localhost:8080/api/orders/${widget.orderId}");

    try {
      final response = await http.get(url, headers: {
        "Authorization": "Bearer $token",
      });

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          order = data['order'];
          selectedMethod = data['order']['metode_bayar'];
          isLoading = false;
        });
      } else {
        print("❌ Gagal ambil data tagihan: ${response.body}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("❌ Error: $e");
      setState(() => isLoading = false);
    }
  }

  Future<void> submitPaymentMethod() async {
    if (selectedMethod == null) return;

    setState(() => isSubmitting = true);

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final url = Uri.parse("http://localhost:8080/api/orders/${widget.orderId}/metode_bayar");

    final body = jsonEncode({
      "metode_bayar": selectedMethod,
    });

    try {
      final response = await http.put(
        url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: body,
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("✅ Metode bayar berhasil dikirim")),
        );
        fetchTagihan(); // refresh status
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("❌ Gagal: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Error: $e")),
      );
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF24313F),
      appBar: AppBar(
        title: const Text("Tagihan"),
        backgroundColor: const Color(0xFF334856),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.orange))
          : order == null || order!['nominal'] == null
              ? const Center(
                  child: Text(
                    "Kurir belum menginputkan tagihan.",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Total Tagihan",
                          style: TextStyle(color: Colors.white70, fontSize: 16)),
                      const SizedBox(height: 8),
                      Text("Rp ${order!['nominal']}",
                          style: const TextStyle(
                              color: Colors.orangeAccent,
                              fontSize: 28,
                              fontWeight: FontWeight.bold)),
                      const SizedBox(height: 24),
                      const Divider(color: Colors.white24),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.info, color: Colors.white70),
                          const SizedBox(width: 8),
                          Text(
                            "Status Pembayaran: ${order!['payment_status'] ?? 'Belum ada'}",
                            style: const TextStyle(color: Colors.white, fontSize: 14),
                          )
                        ],
                      ),
                      const SizedBox(height: 24),
                      const Text("Pilih Metode Pembayaran",
                          style: TextStyle(color: Colors.white70)),
                      const SizedBox(height: 6),
                      DropdownButtonFormField<String>(
  value: ['cash', 'transfer'].contains(selectedMethod) ? selectedMethod : null,
  items: ['cash', 'transfer'].map((method) {
    return DropdownMenuItem(
      value: method,
      child: Text(
        method == 'cash' ? 'Bayar Cash' : 'Transfer Bank',
        style: const TextStyle(color: Colors.black87),
      ),
    );
  }).toList(),
  onChanged: (value) {
    setState(() => selectedMethod = value);
  },
  dropdownColor: Colors.white,
  decoration: InputDecoration(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
),

                      const SizedBox(height: 16),

                      // Jika transfer, tampilkan info rekening
                      if (selectedMethod == 'transfer')
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF334856),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text("Transfer ke rekening berikut:",
                                  style: TextStyle(color: Colors.white70)),
                              SizedBox(height: 8),
                              Text("Bank ABC - 1234567890 a.n. FaiExpress",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: isSubmitting ? null : submitPaymentMethod,
                        icon: const Icon(Icons.payment),
                        label: isSubmitting
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Bayar Sekarang"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      )
                    ],
                  ),
                ),
    );
  }
}
