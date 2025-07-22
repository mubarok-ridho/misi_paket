class Kurir {
  final String nama;
  final String noHp;

  Kurir({
    required this.nama,
    required this.noHp,
  });

  factory Kurir.fromJson(Map<String, dynamic> json) {
    return Kurir(
      nama: json['name'] ?? '',     // sesuaikan key dengan response
      noHp: json['no_hp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': nama,
      'no_hp': noHp,
    };
  }
}
