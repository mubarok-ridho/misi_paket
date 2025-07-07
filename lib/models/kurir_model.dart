// lib/models/kurir_model.dart

class Kurir {
  final String nama;
  final String noHp;

  Kurir({
    required this.nama,
    required this.noHp,
  });

  // Convert dari JSON (misalnya dari API)
  factory Kurir.fromJson(Map<String, dynamic> json) {
    return Kurir(
      nama: json['nama'],
      noHp: json['noHp'],
    );
  }

  // Convert ke JSON (untuk disimpan atau dikirim ke backend)
  Map<String, dynamic> toJson() {
    return {
      'nama': nama,
      'noHp': noHp,
    };
  }
}
