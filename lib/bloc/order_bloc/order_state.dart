import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

abstract class OrderState extends Equatable {
  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoadedState extends OrderState {
  final String? namaBarang;
  final String? catatanBarang;
  final String? ukuran;
  final String? namaMakanan;
  final String? catatanMakanan;
  final String? namaPenumpang;
  final String? tujuan;
  final String? alamatJemput;
  final String? alamatAntar;
  final LatLng? lokasiJemput;
  final LatLng? lokasiAntar;
  final String? namaKurir;
  final String? noHpKurir;
  final int? kurirId; 


  OrderLoadedState({
    this.namaBarang,
    this.catatanBarang,
    this.ukuran,
    this.namaMakanan,
    this.catatanMakanan,
    this.namaPenumpang,
    this.tujuan,
    this.alamatJemput,
    this.alamatAntar,
    this.lokasiJemput,
    this.lokasiAntar,
    this.namaKurir,
    this.noHpKurir,
    this.kurirId,
  });

  OrderLoadedState copyWith({
    String? namaBarang,
    String? catatanBarang,
    String? ukuran,
    String? namaMakanan,
    String? catatanMakanan,
    String? namaPenumpang,
    String? tujuan,
    String? alamatJemput,
    String? alamatAntar,
    LatLng? lokasiJemput,
    LatLng? lokasiAntar,
    String? namaKurir,
    String? noHpKurir,
    int? kurirId,
  }) {
    return OrderLoadedState(
      namaBarang: namaBarang ?? this.namaBarang,
      catatanBarang: catatanBarang ?? this.catatanBarang,
      ukuran: ukuran ?? this.ukuran,
      namaMakanan: namaMakanan ?? this.namaMakanan,
      catatanMakanan: catatanMakanan ?? this.catatanMakanan,
      namaPenumpang: namaPenumpang ?? this.namaPenumpang,
      tujuan: tujuan ?? this.tujuan,
      alamatJemput: alamatJemput ?? this.alamatJemput,
      alamatAntar: alamatAntar ?? this.alamatAntar,
      lokasiJemput: lokasiJemput ?? this.lokasiJemput,
      lokasiAntar: lokasiAntar ?? this.lokasiAntar,
      namaKurir: namaKurir ?? this.namaKurir,
      noHpKurir: noHpKurir ?? this.noHpKurir,
      kurirId: kurirId ?? this.kurirId,
    );
  }

  @override
  List<Object?> get props => [
    namaBarang,
    catatanBarang,
    ukuran,
    namaMakanan,
    catatanMakanan,
    namaPenumpang,
    tujuan,
    alamatJemput,
    alamatAntar,
    lokasiJemput,
    lokasiAntar,
    namaKurir,
    noHpKurir,
    kurirId,
  ];
}
