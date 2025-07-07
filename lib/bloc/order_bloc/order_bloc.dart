import 'package:flutter_bloc/flutter_bloc.dart';
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
          kurirId: event.kurirId, // ← Tambahkan ini

        ));
      } else {
        emit(OrderLoadedState(
          namaKurir: event.namaKurir,
          noHpKurir: event.noHpKurir,
          kurirId: event.kurirId, // ← Tambahkan ini

        ));
      }
    });
  }
}
