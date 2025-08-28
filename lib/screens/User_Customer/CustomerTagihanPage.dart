import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class CustomerTagihanPage extends StatefulWidget {
  final int orderId;

  const CustomerTagihanPage({super.key, required this.orderId});

  @override
  State<CustomerTagihanPage> createState() => _CustomerTagihanPageState();
}

class GradientBorderPainter extends CustomPainter {
  final double strokeWidth;
  final double radius;
  final Gradient gradient;

  GradientBorderPainter({
    required this.strokeWidth,
    required this.radius,
    required this.gradient,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));

    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
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

    final url = Uri.parse("https://gin-production-77e5.up.railway.app/api/orders/${widget.orderId}");

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
    final url = Uri.parse(
        "https://gin-production-77e5.up.railway.app/api/orders/${widget.orderId}/metode_bayar");

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

Widget buildBankCard({
  required String image,
  required String rekening,
  required String nama,
  required LinearGradient borderGradient,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    child: CustomPaint(
      painter: GradientBorderPainter(
        gradient: borderGradient,
        strokeWidth: 2,
        radius: 16,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                image,
                width: 80,
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          rekening,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: rekening));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('✅ Nomor rekening disalin!'),
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.copy,
                          color: Color.fromARGB(179, 223, 70, 4),
                          size: 22,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    nama,
                    style: const TextStyle(
                      color: Color.fromARGB(194, 203, 203, 203),
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
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
              : SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Total Tagihan",
                            style:
                                TextStyle(color: Colors.white70, fontSize: 16)),
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
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 14),
                            )
                          ],
                        ),
                        const SizedBox(height: 24),
                        const Text("Pilih Metode Pembayaran",
                            style: TextStyle(color: Colors.white70)),
                        const SizedBox(height: 6),
                        DropdownButtonFormField<String>(
                          value: ['cash', 'transfer'].contains(selectedMethod)
                              ? selectedMethod
                              : null,
                          items: ['cash', 'transfer'].map((method) {
                            return DropdownMenuItem(
                              value: method,
                              child: Text(
                                method == 'cash' ? 'Bayar Cash' : 'Transfer',
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
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 10),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                      if (selectedMethod == 'cash') ...[
  const Text("Metode pembayaran: Cash / Tunai",
      style: TextStyle(color: Colors.white70)),
  const SizedBox(height: 12),
  Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(14),
      gradient: LinearGradient(
        colors: [Color(0xFF3A3A3A), Color(0xFF2A2A2A)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      border: Border.all(color: Colors.white24, width: 1),
    ),
    padding: const EdgeInsets.all(16),
    child: Row(
      children: [
        const Icon(Icons.attach_money_rounded, color: Colors.greenAccent, size: 40),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Bayar langsung ke kurir pas kurirnya sampai yaa!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Jumlah yang harus kamu bayar:',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
                                      Text("Rp ${order!['nominal']}",

                style: const TextStyle(
                  color: Colors.amberAccent,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  ),
],


                        // Jika transfer, tampilkan rekening
                        if (selectedMethod == 'transfer') ...[
                          const Text("Pilih salah satu rekening tujuan:",
                              style: TextStyle(color: Colors.white70)),
                          const SizedBox(height: 12),
                          buildBankCard(
                            image: 'lib/assets/bni.png',
                            rekening: '0895571973',
                            nama: 'Muhammad Faisal',
                            borderGradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 7, 109, 172),
                                Color.fromARGB(255, 215, 86, 16)
                              ],
                            ),
                          ),
                          buildBankCard(
                            image: 'lib/assets/mandiri.png',
                            rekening: '1080026850769',
                            nama: 'Anggi Andriani Perangin \nAngin',
                            borderGradient: const LinearGradient(
                              colors: [Color(0xFF003399), Color(0xFFFFD700)],
                            ),
                          ),
                          buildBankCard(
                            image: 'lib/assets/dana.png',
                            rekening: '085262131336',
                            nama: 'Anggi Andriani Perangin \nAngin',
                            borderGradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 6, 50, 181),
                                Color.fromARGB(255, 9, 93, 250)
                              ],
                            ),
                          ),
                        ],
                        // const SizedBox(height: 24),
                        // Center(
                        //   child: ElevatedButton.icon(
                        //     onPressed:
                        //         isSubmitting ? null : submitPaymentMethod,
                        //     icon: const Icon(Icons.payment),
                        //     label: isSubmitting
                        //         ? const SizedBox(
                        //             height: 26,
                        //             width: 27,
                        //             child: CircularProgressIndicator(
                        //               color: Colors.white,
                        //               strokeWidth: 2,
                        //             ))
                        //         : const Text("Konfirmasi Pembayaran"),
                        //     style: ElevatedButton.styleFrom(
                        //       backgroundColor:
                        //           const Color.fromARGB(255, 6, 83, 111),
                        //       foregroundColor: Colors.white,
                        //       padding: const EdgeInsets.symmetric(vertical: 14),
                        //       shape: RoundedRectangleBorder(
                        //         borderRadius: BorderRadius.circular(12),
                        //       ),
                        //     ),
                        //   ),
                        // )
                      ],
                    ),
                  ),
                ),
    );
  }
}
