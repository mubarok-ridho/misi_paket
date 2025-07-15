import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  OrderBloc() : super(OrderInitial()) {
    on<SetBarangEvent>((event, emit) {
      final currentState = state;
      if (currentState is OrderLoadedState) {
        emit(currentState.copyWith(
          namaBarang: event.namaBarang,
          catatanBarang: event.catatanBarang,
          ukuran: event.ukuran,
        ));
      } else {
        emit(OrderLoadedState(
          namaBarang: event.namaBarang,
          catatanBarang: event.catatanBarang,
          ukuran: event.ukuran,
        ));
      }
    });

    on<SetMakananEvent>((event, emit) {
      final currentState = state;
      if (currentState is OrderLoadedState) {
        emit(currentState.copyWith(
          namaMakanan: event.namaMakanan,
          catatanMakanan: event.catatanMakanan,
        ));
      } else {
        emit(OrderLoadedState(
          namaMakanan: event.namaMakanan,
          catatanMakanan: event.catatanMakanan,
        ));
      }
    });

    on<SetPenumpangEvent>((event, emit) {
      final currentState = state;
      if (currentState is OrderLoadedState) {
        emit(currentState.copyWith(
          namaPenumpang: event.namaPenumpang,
          tujuan: event.tujuan,
        ));
      } else {
        emit(OrderLoadedState(
          namaPenumpang: event.namaPenumpang,
          tujuan: event.tujuan,
        ));
      }
    });

    on<SetLokasiEvent>((event, emit) {
      final currentState = state;
      if (currentState is OrderLoadedState) {
        emit(currentState.copyWith(
          alamatJemput: event.alamatJemput,
          alamatAntar: event.alamatAntar,
          lokasiJemput: event.lokasiJemput,
          lokasiAntar: event.lokasiAntar,
        ));
      } else {
        emit(OrderLoadedState(
          alamatJemput: event.alamatJemput,
          alamatAntar: event.alamatAntar,
          lokasiJemput: event.lokasiJemput,
          lokasiAntar: event.lokasiAntar,
        ));
      }
    });

    on<SetKurirEvent>((event, emit) {
      final currentState = state;
      if (currentState is OrderLoadedState) {
        emit(currentState.copyWith(
          namaKurir: event.namaKurir,
          noHpKurir: event.noHpKurir,
          kurirId: event.kurirId,
        ));
      } else {
        emit(OrderLoadedState(
          namaKurir: event.namaKurir,
          noHpKurir: event.noHpKurir,
          kurirId: event.kurirId,
        ));
      }
    });

    on<SubmitOrderEvent>((event, emit) async {
      final currentState = state;
      if (currentState is! OrderLoadedState) return;

      try {
        final body = {
          "layanan": event.layanan,
          "customer_id": event.customerId,
          "alamat_jemput": currentState.alamatJemput,
          "alamat_antar": currentState.alamatAntar,
          "lat_jemput": currentState.lokasiJemput?.latitude,
          "lng_jemput": currentState.lokasiJemput?.longitude,
          "lat_antar": currentState.lokasiAntar?.latitude,
          "lng_antar": currentState.lokasiAntar?.longitude,
          "kurir_id": currentState.kurirId,
          "nama_barang": currentState.namaBarang,
          "catatan_barang": currentState.catatanBarang,
          "ukuran": currentState.ukuran,
          "nama_makanan": currentState.namaMakanan,
          "catatan_makanan": currentState.catatanMakanan,
          "nama_penumpang": currentState.namaPenumpang,
          "tujuan": currentState.tujuan,
        };

        final response = await http.post(
          Uri.parse("http://localhost:8080/orders"), // Ganti dengan URL kamu
          headers: {"Content-Type": "application/json"},
          body: jsonEncode(body),
        );

        if (response.statusCode == 201 || response.statusCode == 200) {
          // Sukses kirim order
          print("✅ Order berhasil dibuat!");
          emit(OrderInitial()); // Reset state jika perlu
        } else {
          print("❌ Gagal submit order: ${response.body}");
        }
      } catch (e) {
        print("❌ Error saat submit order: $e");
      }
    });
  }
}
