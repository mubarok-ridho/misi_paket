import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:misi_paket/bloc/order_bloc/order_bloc.dart';
import 'package:misi_paket/screens/User_Customer/confirmpage.dart';
import 'package:misi_paket/screens/User_Customer/order_model.dart';
import 'package:misi_paket/screens/User_Customer/pesananDiprosesPage.dart';
import 'package:misi_paket/screens/change_password_page.dart';
import 'package:misi_paket/screens/login.dart';
import 'package:misi_paket/screens/User_Customer/pilih_kurir_page.dart';

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();

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

        '/pilih_kurir': (context) {
          final role = ModalRoute.of(context)!.settings.arguments as String? ?? 'barang';
          return PilihKurirPage(role: role);
        },

        '/confirm': (context) {
          final role = ModalRoute.of(context)!.settings.arguments as String? ?? 'barang';
          return ConfirmPage(role: role);
        },
      '/pesanan-diproses': (context) {
        final order = ModalRoute.of(context)!.settings.arguments as OrderSummary;
        return PesananDiprosesPage(order: order);
      },

        '/change-password': (context) => ChangePasswordPage(),
      },
    );
  }
}
