import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_unsaac/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/balance_state.dart';

class BalanceCubit extends Cubit<BalanceState> {
  BalanceCubit(this._repository) : super(const BalanceInitial());

  final WalletRepository _repository;
  int _request = 0;

  Future<void> load() async {
    final request = ++_request;
    emit(const BalanceLoading());
    try {
      final summary = await _repository.loadSummary();
      if (isClosed || request != _request) return;
      emit(BalanceSuccess(summary));
    } on Exception {
      if (isClosed || request != _request) return;
      emit(
        const BalanceFailure('No se pudo cargar el resumen de la billetera.'),
      );
    }
  }
}
