// lib/bloc/kurir_bloc/kurir_state.dart

import 'package:equatable/equatable.dart';
import 'package:misi_paket/models/kurir_model.dart';

abstract class KurirState extends Equatable {
  const KurirState();

  @override
  List<Object?> get props => [];
}

class KurirInitial extends KurirState {}

class KurirLoading extends KurirState {}

class KurirLoaded extends KurirState {
  final List<Kurir> kurirList;

  const KurirLoaded(this.kurirList);

  @override
  List<Object?> get props => [kurirList];
}

class KurirError extends KurirState {
  final String message;

  const KurirError(this.message);

  @override
  List<Object?> get props => [message];
}
