import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';
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
      final response = await http.get(Uri.parse('http://localhost:8080/kurir/available'));

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
      appBar: AppBar(
        title: const Text("Pilih Kurir/Driver"),
        backgroundColor: Colors.deepOrange,
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: kurirList.length,
              itemBuilder: (context, index) {
                final kurir = kurirList[index];
                return ListTile(
                  leading: const CircleAvatar(
                    backgroundColor: Colors.orangeAccent,
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                  title: Text(kurir['name']),
                  subtitle: Text(kurir['phone']),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    context.read<OrderBloc>().add(SetKurirEvent(
                    namaKurir: kurir['name'],
                    noHpKurir: kurir['phone'],
                    kurirId: kurir['id'], // ← ini penting untuk dipakai di ConfirmPage
                  ));


                    Navigator.pushNamed(
                      context,
                      '/confirm',
                      arguments: widget.role,
                    );
                  },
                );
              },
            ),
    );
  }
}
