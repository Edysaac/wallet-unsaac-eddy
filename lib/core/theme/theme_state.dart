import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:wallet_unsaac/core/theme/app_theme.dart';

/// Estado del tema de la aplicación.
///
/// Es inmutable: cada cambio produce una instancia nueva mediante
/// `copyWith`. `Equatable` compara por valor, así que dos estados con el mismo
/// `mode` son iguales y BLoC puede omitir emisiones redundantes.
class ThemeState extends Equatable {
  const ThemeState({
    this.mode = ThemeMode.system,
    this.seedColor = AppTheme.seed,
  });

  final ThemeMode mode;
  final Color seedColor;

  bool get isDark => mode == ThemeMode.dark;

  ThemeState copyWith({ThemeMode? mode, Color? seedColor}) => ThemeState(
    mode: mode ?? this.mode,
    seedColor: seedColor ?? this.seedColor,
  );

  @override
  List<Object?> get props => [mode, seedColor];
}
