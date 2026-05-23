part of '../database/app_database.dart';

@DriftAccessor(tables: [Subjects])
class SubjectsDao extends DatabaseAccessor<AppDatabase>
    with _$SubjectsDaoMixin {
  SubjectsDao(super.db);

  Stream<List<SubjectRow>> watchAll() {
    return (select(subjects)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([(table) => OrderingTerm.asc(table.name)]))
        .watch();
  }

  Future<List<SubjectRow>> getAll() {
    return (select(subjects)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([(table) => OrderingTerm.asc(table.name)]))
        .get();
  }

  Stream<List<SubjectRow>> watchDeleted() {
    return (select(subjects)
          ..where((table) => table.deletedAt.isNotNull())
          ..orderBy([(table) => OrderingTerm.desc(table.deletedAt)]))
        .watch();
  }

  Future<void> upsertSubject(SubjectsCompanion subject) {
    return into(subjects).insertOnConflictUpdate(subject);
  }

  Future<void> insertAll(List<SubjectsCompanion> rows) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(subjects, rows);
    });
  }

  Future<bool> moveToTrash(String id) {
    return (update(subjects)..where((table) => table.id.equals(id)))
        .write(SubjectsCompanion(deletedAt: Value(DateTime.now())))
        .then((rows) => rows > 0);
  }

  Future<bool> restoreSubject(String id) {
    return (update(subjects)..where((table) => table.id.equals(id)))
        .write(const SubjectsCompanion(deletedAt: Value(null)))
        .then((rows) => rows > 0);
  }
}
