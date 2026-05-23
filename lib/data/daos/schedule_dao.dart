part of '../database/app_database.dart';

@DriftAccessor(tables: [ScheduleEntries, Subjects])
class ScheduleDao extends DatabaseAccessor<AppDatabase>
    with _$ScheduleDaoMixin {
  ScheduleDao(super.db);

  Stream<List<ScheduleRow>> watchAll() {
    return (select(scheduleEntries)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([
            (table) => OrderingTerm.asc(table.weekdayIndex),
            (table) => OrderingTerm.asc(table.startsAtMinute),
          ]))
        .watch();
  }

  Future<List<ScheduleRow>> getAll() {
    return (select(scheduleEntries)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([
            (table) => OrderingTerm.asc(table.weekdayIndex),
            (table) => OrderingTerm.asc(table.startsAtMinute),
          ]))
        .get();
  }

  Stream<List<ScheduleRow>> watchDeleted() {
    return (select(scheduleEntries)
          ..where((table) => table.deletedAt.isNotNull())
          ..orderBy([(table) => OrderingTerm.desc(table.deletedAt)]))
        .watch();
  }

  Future<int> insertScheduleEntry(ScheduleEntriesCompanion entry) {
    return into(scheduleEntries).insert(entry);
  }

  Future<bool> updateScheduleEntry(ScheduleEntriesCompanion entry) {
    final id = entry.id.value;
    return (update(scheduleEntries)..where((table) => table.id.equals(id)))
        .write(entry)
        .then((rows) => rows > 0);
  }

  Future<void> insertAll(List<ScheduleEntriesCompanion> rows) async {
    await batch((batch) {
      batch.insertAll(scheduleEntries, rows);
    });
  }

  Future<bool> moveToTrash(int id) {
    return (update(scheduleEntries)..where((table) => table.id.equals(id)))
        .write(ScheduleEntriesCompanion(deletedAt: Value(DateTime.now())))
        .then((rows) => rows > 0);
  }

  Future<bool> restoreScheduleEntry(int id) {
    return (update(scheduleEntries)..where((table) => table.id.equals(id)))
        .write(const ScheduleEntriesCompanion(deletedAt: Value(null)))
        .then((rows) => rows > 0);
  }
}
