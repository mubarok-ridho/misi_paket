import 'package:flutter/material.dart';
import 'package:misi_paket/screens/owner.dart';
// import 'package:misi_paket/screens/customer.dart';
// import 'package:misi_paket/screens/courier.dart';
// import 'package:misi_paket/screens/login.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rental App',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      // Ganti sesuai role yang ingin diuji
      home: AdminHome(),
      // home: CourierHome(),
      // home: CustomerHome(),
    );
  }
}
