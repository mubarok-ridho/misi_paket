class KurirStats {
  final int pesananProses;
  final int pesananSelesai;
  final int pendapatanHariIni;

  KurirStats({
    required this.pesananProses,
    required this.pesananSelesai,
    required this.pendapatanHariIni,
  });

  factory KurirStats.fromJson(Map<String, dynamic> json) {
    return KurirStats(
      pesananProses: json['pesanan_proses'],
      pesananSelesai: json['pesanan_selesai'],
      pendapatanHariIni: json['pendapatan_hari_ini'],
    );
  }
}
