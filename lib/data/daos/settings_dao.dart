part of '../database/app_database.dart';

@DriftAccessor(tables: [AppSettingsEntries])
class SettingsDao extends DatabaseAccessor<AppDatabase>
    with _$SettingsDaoMixin {
  SettingsDao(super.db);

  Future<String?> getValue(String key) async {
    final row = await (select(
      appSettingsEntries,
    )..where((table) => table.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> setValue({required String key, required String value}) {
    return into(appSettingsEntries).insertOnConflictUpdate(
      AppSettingsEntriesCompanion(key: Value(key), value: Value(value)),
    );
  }
}
