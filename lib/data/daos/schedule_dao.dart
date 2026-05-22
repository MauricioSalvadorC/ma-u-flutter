part of '../database/app_database.dart';

@DriftAccessor(tables: [ScheduleEntries, Subjects])
class ScheduleDao extends DatabaseAccessor<AppDatabase>
    with _$ScheduleDaoMixin {
  ScheduleDao(super.db);

  Stream<List<ScheduleRow>> watchAll() {
    return (select(scheduleEntries)..orderBy([
          (table) => OrderingTerm.asc(table.weekdayIndex),
          (table) => OrderingTerm.asc(table.startsAtMinute),
        ]))
        .watch();
  }

  Future<List<ScheduleRow>> getAll() {
    return (select(scheduleEntries)..orderBy([
          (table) => OrderingTerm.asc(table.weekdayIndex),
          (table) => OrderingTerm.asc(table.startsAtMinute),
        ]))
        .get();
  }

  Future<int> insertScheduleEntry(ScheduleEntriesCompanion entry) {
    return into(scheduleEntries).insert(entry);
  }

  Future<void> insertAll(List<ScheduleEntriesCompanion> rows) async {
    await batch((batch) {
      batch.insertAll(scheduleEntries, rows);
    });
  }
}
