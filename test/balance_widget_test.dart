import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';
import 'package:wallet_unsaac/features/wallet/domain/entities/wallet_summary.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/balance_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/cubit/privacy_cubit.dart';
import 'package:wallet_unsaac/features/wallet/presentation/pages/wallet_home_page.dart';

import 'balance_cubit_test.dart' show TestRepository;

void main() {
  testWidgets('muestra carga, error y éxito al reintentar', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = ThemePreferences(await SharedPreferences.getInstance());
    final first = Completer<WalletSummary>();
    final second = Completer<WalletSummary>();
    final repository = TestRepository([
      () => first.future,
      () => second.future,
    ]);
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => ThemeCubit(preferences: prefs)),
          BlocProvider(create: (_) => PrivacyCubit()),
          BlocProvider(create: (_) => BalanceCubit(repository)..load()),
        ],
        child: const MaterialApp(
          home: WalletHomePage(firebaseStatus: FirebaseStatus.notConfigured()),
        ),
      ),
    );
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    first.completeError(Exception('sin conexión'));
    await tester.pumpAndSettle();
    expect(
      find.text('No se pudo cargar el resumen de la billetera.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Reintentar'));
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    second.complete(const WalletSummary(movements: []));
    await tester.pumpAndSettle();
    expect(find.text('Saldo disponible'), findsOneWidget);
    expect(find.text('Todavía no registraste movimientos.'), findsOneWidget);
    expect(repository.calls, 2);
  });
}
