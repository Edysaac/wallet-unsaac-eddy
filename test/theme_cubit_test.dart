import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wallet_unsaac/core/theme/theme_cubit.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';
import 'package:wallet_unsaac/core/theme/app_theme.dart';
import 'package:wallet_unsaac/core/theme/theme_state.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('el color participa en la igualdad y conserva el modo', () async {
    final cubit = ThemeCubit(
      preferences: ThemePreferences(await SharedPreferences.getInstance()),
      initialMode: ThemeMode.dark,
    );
    expect(cubit.state.seedColor, AppTheme.seed);
    cubit.setSeedColor(Colors.blue);
    expect(cubit.state.mode, ThemeMode.dark);
    expect(cubit.state.seedColor, Colors.blue);
    expect(cubit.state, isNot(const ThemeState(mode: ThemeMode.dark)));
    await cubit.setMode(ThemeMode.light);
    expect(cubit.state.seedColor, Colors.blue);
    await cubit.close();
  });

  test('la paleta deriva del color semilla en ambos modos', () {
    for (final brightness in Brightness.values) {
      final theme = brightness == Brightness.light
          ? AppTheme.light(Colors.blue)
          : AppTheme.dark(Colors.blue);
      expect(
        theme.colorScheme.primary,
        ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: brightness,
        ).primary,
      );
      final original = brightness == Brightness.light
          ? AppTheme.light()
          : AppTheme.dark();
      expect(theme.colorScheme.primary, isNot(original.colorScheme.primary));
    }
  });

  test('guarda y recupera cada modo', () async {
    final preferences = ThemePreferences(await SharedPreferences.getInstance());
    expect(preferences.load(), ThemeMode.system);
    for (final mode in ThemeMode.values) {
      await preferences.save(mode);
      expect(preferences.load(), mode);
    }
  });

  test('valor desconocido o de otro tipo usa sistema', () async {
    SharedPreferences.setMockInitialValues({ThemePreferences.key: 'invalido'});
    expect(
      ThemePreferences(await SharedPreferences.getInstance()).load(),
      ThemeMode.system,
    );
    SharedPreferences.setMockInitialValues({ThemePreferences.key: 42});
    expect(
      ThemePreferences(await SharedPreferences.getInstance()).load(),
      ThemeMode.system,
    );
  });

  test('Cubit recorre los modos y persiste la ?ltima elecci?n', () async {
    final preferences = ThemePreferences(await SharedPreferences.getInstance());
    final cubit = ThemeCubit(
      preferences: preferences,
      initialMode: preferences.load(),
    );
    for (final mode in [
      ThemeMode.light,
      ThemeMode.dark,
      ThemeMode.system,
      ThemeMode.light,
    ]) {
      await cubit.toggle();
      expect(cubit.state.mode, mode);
      expect(preferences.load(), mode);
    }
    await cubit.setMode(ThemeMode.dark);
    await cubit.close();
    final reopened = ThemeCubit(
      preferences: preferences,
      initialMode: preferences.load(),
    );
    expect(reopened.state.mode, ThemeMode.dark);
    await reopened.close();
  });
}
