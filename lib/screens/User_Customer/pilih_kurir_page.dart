import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import 'package:misi_paket/bloc/order_bloc/order_bloc.dart';
import 'package:misi_paket/bloc/order_bloc/order_event.dart';

class PilihKurirPage extends StatefulWidget {
  final String role;

  const PilihKurirPage({super.key, required this.role});

  @override
  State<PilihKurirPage> createState() => _PilihKurirPageState();
}

class _PilihKurirPageState extends State<PilihKurirPage> {
  List<Map<String, dynamic>> kurirList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAvailableKurir();
  }

  Future<void> fetchAvailableKurir() async {
    try {
      final response = await http.get(Uri.parse('https://gin-production-77e5.up.railway.app/kurir/available'));

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          kurirList = List<Map<String, dynamic>>.from(data);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception('Gagal mengambil data kurir');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1E1E),
      appBar: AppBar(
        title: const Text("Pilih Kurir/Driver"),
        backgroundColor: const Color.fromARGB(255, 51, 72, 86),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'lib/assets/Fainyetir.json',
                    width: 200,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Bentar ya, lagi cari kurir yang available nih!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: kurirList.length,
              itemBuilder: (context, index) {
                final kurir = kurirList[index];
                return GestureDetector(
                  onTap: () {
                    context.read<OrderBloc>().add(SetKurirEvent(
                          namaKurir: kurir['name'],
                          noHpKurir: kurir['no_hp'],
                          kurirId: kurir['id'],
                        ));

                    Navigator.pushNamed(
                      context,
                      '/confirm',
                      arguments: widget.role,
                    );
                  },
                  child: Card(
                    color: const Color(0xFF2B2B2B),
                    elevation: 4,
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      leading: CircleAvatar(
                        radius: 26,
                        backgroundColor: const Color(0xFFEF5B2E),
                        child: const Icon(Icons.person, color: Colors.white, size: 30),
                      ),
                      title: Text(
                        kurir['name'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      // subtitle: Text(
                      //   kurir['no_hp'],
                      //   style: const TextStyle(
                      //     color: Colors.white70,
                      //     fontSize: 14,
                      //   ),
                      // ),
                      trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 18),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
