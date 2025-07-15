// lib/bloc/order_bloc/order_event.dart

import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

// Barang Event
class SetBarangEvent extends OrderEvent {
  final String namaBarang;
  final String catatanBarang;
  final String ukuran;

  const SetBarangEvent({
    required this.namaBarang,
    required this.catatanBarang,
    required this.ukuran,
  });

  @override
  List<Object?> get props => [namaBarang, catatanBarang, ukuran];
}

// Makanan Event
class SetMakananEvent extends OrderEvent {
  final String namaMakanan;
  final String catatanMakanan;

  const SetMakananEvent({
    required this.namaMakanan,
    required this.catatanMakanan,
  });

  @override
  List<Object?> get props => [namaMakanan, catatanMakanan];
}

// Penumpang Event
class SetPenumpangEvent extends OrderEvent {
  final String namaPenumpang;
  final String tujuan;

  const SetPenumpangEvent({
    required this.namaPenumpang,
    required this.tujuan,
  });

  @override
  List<Object?> get props => [namaPenumpang, tujuan];
}

// Lokasi Event
class SetLokasiEvent extends OrderEvent {
  final LatLng lokasiJemput;
  final String alamatJemput;
  final LatLng? lokasiAntar;
  final String? alamatAntar;

const SetLokasiEvent({
    required this.lokasiJemput,
    required this.alamatJemput,
    this.lokasiAntar,
    this.alamatAntar, required String role,
  });

  @override
  List<Object?> get props => [lokasiJemput, alamatJemput, lokasiAntar, alamatAntar];
}

class SubmitOrderEvent extends OrderEvent {
  final String layanan;
  final int customerId;

  const SubmitOrderEvent({
    required this.layanan,
    required this.customerId,
  });

  @override
  List<Object?> get props => [layanan, customerId];
}


// Kurir Event
class SetKurirEvent extends OrderEvent {
  final String namaKurir;
  final String noHpKurir;
  final int kurirId;

  const SetKurirEvent({
    required this.namaKurir,
    required this.noHpKurir,
    required this.kurirId,

  });

  @override
  List<Object?> get props => [namaKurir, noHpKurir];
}
