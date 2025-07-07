import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:misi_paket/bloc/order_bloc/order_bloc.dart';
import 'package:misi_paket/screens/User_Customer/PesananDiprosesPage.dart';
import 'package:misi_paket/screens/User_Customer/confirmpage.dart';
import 'package:misi_paket/screens/change_password_page.dart';
import 'package:misi_paket/screens/login.dart';
import 'package:misi_paket/screens/User_Customer/pilih_kurir_page.dart';
import 'package:misi_paket/screens/User_Customer/select_location_page.dart';

void main() {
  runApp(BlocProvider(
    create: (context) => OrderBloc(),
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FaiExpress',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => LoginPage(),

        '/lokasi_picker': (context) {
          final role = ModalRoute.of(context)!.settings.arguments as String? ?? 'barang';
          return LokasiPickerPage(role: role);
        },

        '/pilih_kurir': (context) {
          final role = ModalRoute.of(context)!.settings.arguments as String? ?? 'barang';
          return PilihKurirPage(role: role);
        },

        '/confirm': (context) {
          final role = ModalRoute.of(context)!.settings.arguments as String? ?? 'barang';
          return ConfirmPage(role: role);
        },

        '/pesanan-diproses': (context) => const PesananDiprosesPage(),
        '/change-password': (context) => ChangePasswordPage(),
      },
    );
  }
}
