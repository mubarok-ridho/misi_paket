class AdminOrder {
  final int id;
  final String status;
  final String jenis;
  final String tanggal;
  final String alamatJemput;
  final String alamatAntar;
  final String namaCustomer;
  final String namaKurir;

  AdminOrder({
    required this.id,
    required this.status,
    required this.jenis,
    required this.tanggal,
    required this.alamatJemput,
    required this.alamatAntar,
    required this.namaCustomer,
    required this.namaKurir,
  });

  factory AdminOrder.fromJson(Map<String, dynamic> json) {
    return AdminOrder(
      id: json['id'],
      status: json['status'],
      jenis: json['jenis'],
      tanggal: json['created_at'] ?? "-", // pastikan field sesuai DB
      alamatJemput: json['alamat_jemput'] ?? "-",
      alamatAntar: json['alamat_antar'] ?? "-",
      namaCustomer: json['customer_name'] ?? "Tidak diketahui",
      namaKurir: json['kurir_name'] ?? "Belum assigned",
    );
  }
}
