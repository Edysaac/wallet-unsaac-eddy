import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferences {
  const ThemePreferences(this._preferences);

  static const key = 'wallet.theme_mode';
  final SharedPreferences _preferences;

  ThemeMode load() {
    final value = _preferences.get(key);
    return ThemeMode.values.where((mode) => mode.name == value).firstOrNull ??
        ThemeMode.system;
  }

  Future<void> save(ThemeMode mode) async {
    await _preferences.setString(key, mode.name);
  }
}
