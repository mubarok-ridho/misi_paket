// lib/bloc/kurir_bloc/kurir_bloc.dart

import 'package:flutter_bloc/flutter_bloc.dart';
import 'kurir_event.dart';
import 'kurir_state.dart';
import 'package:misi_paket/models/kurir_model.dart';

class KurirBloc extends Bloc<KurirEvent, KurirState> {
  KurirBloc() : super(KurirInitial()) {
    on<FetchKurirEvent>((event, emit) async {
      emit(KurirLoading());

      try {
        // Simulasi ambil dari database atau API
        await Future.delayed(Duration(seconds: 1));
        final dummyKurirList = [
          Kurir(nama: 'Jude Bellingham', noHp: '0812 3456 7890'),
          Kurir(nama: 'Harry Kane', noHp: '0813 9876 5432'),
        ];

        emit(KurirLoaded(dummyKurirList));
      } catch (e) {
        emit(KurirError('Gagal memuat data kurir'));
      }
    });
  }
}
