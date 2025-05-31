import 'package:flutter/material.dart';
import 'screens/customer.dart';
import 'screens/owner.dart';
import 'screens/courier.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'kocak',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: CustomerHome(), // langsung ke halaman Customer
    );
  }
}
