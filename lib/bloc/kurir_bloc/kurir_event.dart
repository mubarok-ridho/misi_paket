// lib/bloc/kurir_bloc/kurir_event.dart

import 'package:equatable/equatable.dart';

abstract class KurirEvent extends Equatable {
  const KurirEvent();

  @override
  List<Object?> get props => [];
}

class FetchKurirEvent extends KurirEvent {}
