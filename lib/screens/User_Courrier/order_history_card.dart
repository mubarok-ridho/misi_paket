import 'package:flutter/material.dart';
import 'order_history_item.dart';

class OrderHistoryCard extends StatelessWidget {
  final OrderHistoryItem orderHistory;

  const OrderHistoryCard({required this.orderHistory});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("${orderHistory.type} ${orderHistory.orderId}",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: orderHistory.statusColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(orderHistory.status,
                    style: const TextStyle(color: Colors.white, fontSize: 10)),
              ),
            ],
          ),

          const SizedBox(height: 8),
          Text("Customer: ${orderHistory.customerName}",
              style: TextStyle(color: Colors.grey[600])),

          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(orderHistory.destination,
                    style: const TextStyle(fontSize: 12)),
              ),
            ],
          ),

          const SizedBox(height: 12),
          Text("${orderHistory.date} • ${orderHistory.time}",
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
