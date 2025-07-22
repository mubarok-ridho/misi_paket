class OrderSummary {
  final int id;
  final int customerId;
  final String layanan;
  final String status;
  final String? kurirName;
  final int? kurirId; // ✅ tambahkan ini

  OrderSummary({
    required this.id,
    required this.customerId,
    required this.layanan,
    required this.status,
    this.kurirName,
    this.kurirId,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    return OrderSummary(
      id: json['id'],
      customerId: json['customer_id'],
      layanan: json['layanan'],
      status: json['status'],
      kurirName: json['kurir']?['name'],
      kurirId: json['kurir']?['id'], // ✅ ambil ID kurir
    );
  }
}
