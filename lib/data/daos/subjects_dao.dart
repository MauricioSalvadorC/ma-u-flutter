part of '../database/app_database.dart';

@DriftAccessor(tables: [Subjects])
class SubjectsDao extends DatabaseAccessor<AppDatabase>
    with _$SubjectsDaoMixin {
  SubjectsDao(super.db);

  Stream<List<SubjectRow>> watchAll() {
    return (select(
      subjects,
    )..orderBy([(table) => OrderingTerm.asc(table.name)])).watch();
  }

  Future<List<SubjectRow>> getAll() {
    return (select(
      subjects,
    )..orderBy([(table) => OrderingTerm.asc(table.name)])).get();
  }

  Future<void> upsertSubject(SubjectsCompanion subject) {
    return into(subjects).insertOnConflictUpdate(subject);
  }

  Future<void> insertAll(List<SubjectsCompanion> rows) async {
    await batch((batch) {
      batch.insertAllOnConflictUpdate(subjects, rows);
    });
  }
}
