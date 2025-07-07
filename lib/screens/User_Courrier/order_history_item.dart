import 'package:flutter/material.dart';

/// Representasi satu entri riwayat pesanan.
class OrderHistoryItem {
  final String orderId;
  final String type;
  final String customerName;
  final String destination;
  final String date;
  final String time;
  final String status;
  final Color statusColor;

  OrderHistoryItem({
    required this.orderId,
    required this.type,
    required this.customerName,
    required this.destination,
    required this.date,
    required this.time,
    required this.status,
    required this.statusColor,
  });
}
