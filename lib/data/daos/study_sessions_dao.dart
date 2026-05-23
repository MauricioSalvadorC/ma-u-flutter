part of '../database/app_database.dart';

@DriftAccessor(tables: [StudySessions, Subjects])
class StudySessionsDao extends DatabaseAccessor<AppDatabase>
    with _$StudySessionsDaoMixin {
  StudySessionsDao(super.db);

  Stream<List<StudySessionRow>> watchAll() {
    return (select(studySessions)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([
            (table) => OrderingTerm.asc(table.isCompleted),
            (table) => OrderingTerm.asc(table.startsAt),
            (table) => OrderingTerm.desc(table.focusLevelIndex),
            (table) => OrderingTerm.desc(table.createdAt),
          ]))
        .watch();
  }

  Stream<List<StudySessionRow>> watchDeleted() {
    return (select(studySessions)
          ..where((table) => table.deletedAt.isNotNull())
          ..orderBy([(table) => OrderingTerm.desc(table.deletedAt)]))
        .watch();
  }

  Future<int> insertSession(StudySessionsCompanion session) {
    return into(studySessions).insert(session);
  }

  Future<bool> updateSession(StudySessionsCompanion session) {
    final id = session.id.value;
    return (update(studySessions)..where((table) => table.id.equals(id)))
        .write(session)
        .then((rows) => rows > 0);
  }

  Future<bool> updateCompleted({required int id, required bool isCompleted}) {
    return (update(studySessions)..where((table) => table.id.equals(id)))
        .write(StudySessionsCompanion(isCompleted: Value(isCompleted)))
        .then((rows) => rows > 0);
  }

  Future<bool> moveToTrash(int id) {
    return (update(studySessions)..where((table) => table.id.equals(id)))
        .write(StudySessionsCompanion(deletedAt: Value(DateTime.now())))
        .then((rows) => rows > 0);
  }

  Future<bool> restoreSession(int id) {
    return (update(studySessions)..where((table) => table.id.equals(id)))
        .write(const StudySessionsCompanion(deletedAt: Value(null)))
        .then((rows) => rows > 0);
  }
}
