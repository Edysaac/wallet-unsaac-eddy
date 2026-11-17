import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wallet_unsaac/app.dart';
import 'package:wallet_unsaac/core/config/firebase_status.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));
  testWidgets('la pantalla principal muestra el saldo de demostración', (
    tester,
  ) async {
    await tester.pumpWidget(
      WalletApp(
        firebaseStatus: const FirebaseStatus.notConfigured(),
        themePreferences: ThemePreferences(
          await SharedPreferences.getInstance(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Wallet UNSAAC'), findsOneWidget);
    expect(find.text('Saldo disponible'), findsOneWidget);
    expect(find.text('S/ 1,274.60'), findsOneWidget);

    await tester.dragUntilVisible(
      find.text('Firebase: no configurado (modo local)'),
      find.byType(ListView),
      const Offset(0, -250),
    );
    await tester.pumpAndSettle();
    expect(find.text('Firebase: no configurado (modo local)'), findsOneWidget);
  });

  testWidgets('el botón de tema alterna MaterialApp a modo oscuro', (
    tester,
  ) async {
    await tester.pumpWidget(
      WalletApp(
        firebaseStatus: const FirebaseStatus.notConfigured(),
        themePreferences: ThemePreferences(
          await SharedPreferences.getInstance(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    MaterialApp app() => tester.widget<MaterialApp>(find.byType(MaterialApp));

    expect(app().themeMode, ThemeMode.system);

    await tester.tap(find.byTooltip('Tema actual: sistema'));
    await tester.pumpAndSettle();

    expect(app().themeMode, ThemeMode.light);
    expect(find.byTooltip('Tema actual: claro'), findsOneWidget);
  });
}
