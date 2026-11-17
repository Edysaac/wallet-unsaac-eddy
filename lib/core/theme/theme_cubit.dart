import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:wallet_unsaac/core/theme/theme_preferences.dart';
import 'package:wallet_unsaac/core/theme/theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit({
    required this.preferences,
    ThemeMode initialMode = ThemeMode.system,
  }) : super(ThemeState(mode: initialMode));

  final ThemePreferences preferences;
  Future<void> _pendingSave = Future.value();

  Future<void> toggle() => setMode(switch (state.mode) {
    ThemeMode.light => ThemeMode.dark,
    ThemeMode.dark => ThemeMode.system,
    ThemeMode.system => ThemeMode.light,
  });

  Future<void> setMode(ThemeMode mode) {
    emit(state.copyWith(mode: mode));
    _pendingSave = _pendingSave.then((_) => preferences.save(mode));
    return _pendingSave;
  }

  Future<void> useSystemMode() => setMode(ThemeMode.system);
}
