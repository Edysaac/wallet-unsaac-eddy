import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';
import 'package:wallet_unsaac/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/balance_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/balance_state.dart';

class TestRepository implements WalletRepository {
  TestRepository(this.responses);
  final List<Future<WalletSummary> Function()> responses;
  int calls = 0;
  @override
  Future<WalletSummary> loadSummary() => responses[calls++]();
}

void main() {
  const summary = WalletSummary(movements: []);
  const failure = BalanceFailure(
    'No se pudo cargar el resumen de la billetera.',
  );

  blocTest<BalanceCubit, BalanceState>(
    'emite carga y éxito',
    build: () => BalanceCubit(TestRepository([() async => summary])),
    act: (cubit) => cubit.load(),
    expect: () => [const BalanceLoading(), const BalanceSuccess(summary)],
  );

  blocTest<BalanceCubit, BalanceState>(
    'emite carga y fallo',
    build: () => BalanceCubit(TestRepository([() async => throw Exception()])),
    act: (cubit) => cubit.load(),
    expect: () => [const BalanceLoading(), failure],
  );

  blocTest<BalanceCubit, BalanceState>(
    'reintenta tras un fallo',
    build: () => BalanceCubit(
      TestRepository([() async => throw Exception(), () async => summary]),
    ),
    act: (cubit) async {
      await cubit.load();
      await cubit.load();
    },
    expect: () => [
      const BalanceLoading(),
      failure,
      const BalanceLoading(),
      const BalanceSuccess(summary),
    ],
  );

  test('no emite después del cierre durante la carga', () async {
    final response = Completer<WalletSummary>();
    final cubit = BalanceCubit(TestRepository([() => response.future]));
    final load = cubit.load();
    await cubit.close();
    response.complete(summary);
    await load;
  });
}
