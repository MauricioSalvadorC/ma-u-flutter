import 'package:flutter/material.dart';

import '../../data/database/app_database.dart';

class AppSettingsRepository {
  const AppSettingsRepository(this._database);

  static const _themeModeKey = 'theme_mode';
  static const _seedColorKey = 'seed_color';

  final AppDatabase _database;

  Future<ThemeMode?> getThemeMode() async {
    final value = await _database.settingsDao.getValue(_themeModeKey);
    return switch (value) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      'system' => ThemeMode.system,
      _ => null,
    };
  }

  Future<Color?> getSeedColor() async {
    final value = await _database.settingsDao.getValue(_seedColorKey);
    final colorValue = int.tryParse(value ?? '');
    return colorValue == null ? null : Color(colorValue);
  }

  Future<void> setThemeMode(ThemeMode themeMode) {
    return _database.settingsDao.setValue(
      key: _themeModeKey,
      value: themeMode.name,
    );
  }

  Future<void> setSeedColor(Color color) {
    return _database.settingsDao.setValue(
      key: _seedColorKey,
      value: color.toARGB32().toString(),
    );
  }
}
