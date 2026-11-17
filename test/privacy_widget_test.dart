import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_unsaac/features/wallet/data/repositories/in_memory_wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';
import 'package:wallet_unsaac/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/privacy_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/balance_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/pages/wallet_home_page.dart';

class CountingRepository implements WalletRepository {
  int calls = 0;
  final delegate = InMemoryWalletRepository(latency: Duration.zero);

  @override
  Future<WalletSummary> loadSummary() {
    calls++;
    return delegate.loadSummary();
  }
}

void main() {
  testWidgets('oculta y recupera importes sin recargar datos', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = ThemePreferences(await SharedPreferences.getInstance());
    final repository = CountingRepository();
    await tester.pumpWidget(
      RepositoryProvider<WalletRepository>.value(
        value: repository,
        child: MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ThemeCubit(preferences: prefs)),
            BlocProvider(create: (_) => PrivacyCubit()),
            BlocProvider(create: (_) => BalanceCubit(repository)..load()),
          ],
          child: const MaterialApp(
            home: WalletHomePage(
              firebaseStatus: FirebaseStatus.notConfigured(),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('S/ 1,274.60'), findsOneWidget);
    expect(find.text('S/ 1,770.00'), findsOneWidget);
    expect(find.text('S/ 495.40'), findsOneWidget);
    expect(find.text('+ S/ 1,200.00'), findsOneWidget);
    await tester.tap(find.byTooltip('Ocultar saldo'));
    await tester.pumpAndSettle();
    expect(find.text('S/ 1,274.60'), findsNothing);
    expect(find.text('S/ 1,770.00'), findsNothing);
    expect(find.text('S/ 495.40'), findsNothing);
    expect(find.text('+ S/ 1,200.00'), findsNothing);
    expect(find.text('••••••'), findsWidgets);
    await tester.tap(find.byTooltip('Mostrar saldo'));
    await tester.pumpAndSettle();
    expect(find.text('S/ 1,274.60'), findsOneWidget);
    expect(find.text('+ S/ 1,200.00'), findsOneWidget);
    expect(repository.calls, 1);
  });
}
