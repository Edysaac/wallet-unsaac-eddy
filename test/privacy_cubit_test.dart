import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/privacy_cubit.dart';

void main() {
  test('inicia visible y alterna entre oculto y visible', () async {
    final cubit = PrivacyCubit();
    expect(cubit.state.hidden, isFalse);
    cubit.toggle();
    expect(cubit.state.hidden, isTrue);
    cubit.toggle();
    expect(cubit.state.hidden, isFalse);
    await cubit.close();
  });
}
