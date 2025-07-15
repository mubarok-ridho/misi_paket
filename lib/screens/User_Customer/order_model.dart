import 'package:latlong2/latlong.dart';

class OrderSummary {
  final int id;
  final int customerId;
  final String alamatAntar;
  final String layanan;
  final String status;
  final String? namaBarang;
  final String? namaMakanan;
  final int kurirId;
  final String alamatJemput;
  final LatLng? lokasiJemput;
  final LatLng? lokasiAntar;

  OrderSummary({
    required this.id,
    required this.customerId,
    required this.kurirId,
    required this.alamatJemput,
    required this.alamatAntar,
    required this.layanan,
    required this.status,
    this.namaBarang,
    this.namaMakanan,
    this.lokasiJemput,
    this.lokasiAntar,
  });

  factory OrderSummary.fromJson(Map<String, dynamic> json) {
    return OrderSummary(
      id: json['id'],
      customerId: json['customer_id'],
      alamatAntar: json['alamat_antar'] ?? '-',
      layanan: json['layanan'] ?? 'lainnya',
      status: json['status'] ?? 'proses',
      namaBarang: json['nama_barang'],
      namaMakanan: json['nama_makanan'],
      kurirId: json['kurir_id'],
      alamatJemput: json['alamat_jemput'] ?? '-',
      lokasiJemput: null,
      lokasiAntar: null,
    );
  }
}
