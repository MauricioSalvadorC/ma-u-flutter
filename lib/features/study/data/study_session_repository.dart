import 'package:drift/drift.dart';

import '../../../data/database/app_database.dart';
import '../domain/study_session.dart';

class StudySessionRepository {
  const StudySessionRepository(this._database);

  final AppDatabase _database;

  Stream<List<StudySession>> watchSessions() {
    return _database.studySessionsDao.watchAll().map(
      (rows) => rows.map(_toDomain).toList(),
    );
  }

  Stream<List<StudySession>> watchDeletedSessions() {
    return _database.studySessionsDao.watchDeleted().map(
      (rows) => rows.map(_toDomain).toList(),
    );
  }

  Future<int> saveSession(StudySession session) {
    if (session.id != null) {
      return _database.studySessionsDao
          .updateSession(_toCompanion(session))
          .then((_) => session.id!);
    }

    return _database.studySessionsDao.insertSession(_toCompanion(session));
  }

  Future<bool> setCompleted({required int id, required bool isCompleted}) {
    return _database.studySessionsDao.updateCompleted(
      id: id,
      isCompleted: isCompleted,
    );
  }

  Future<bool> moveToTrash(int id) {
    return _database.studySessionsDao.moveToTrash(id);
  }

  Future<bool> restoreSession(int id) {
    return _database.studySessionsDao.restoreSession(id);
  }

  StudySession _toDomain(StudySessionRow row) {
    return StudySession(
      id: row.id,
      subjectId: row.subjectId,
      title: row.title,
      notes: row.notes ?? '',
      startsAt: row.startsAt,
      durationMinutes: row.durationMinutes,
      focusLevel: FocusLevel.values[row.focusLevelIndex],
      isCompleted: row.isCompleted,
      deletedAt: row.deletedAt,
    );
  }

  StudySessionsCompanion _toCompanion(StudySession session) {
    return StudySessionsCompanion(
      id: session.id == null ? const Value.absent() : Value(session.id!),
      subjectId: Value(session.subjectId),
      title: Value(session.title),
      notes: Value(session.notes.isEmpty ? null : session.notes),
      startsAt: Value(session.startsAt),
      durationMinutes: Value(session.durationMinutes),
      focusLevelIndex: Value(session.focusLevel.index),
      isCompleted: Value(session.isCompleted),
      deletedAt: Value(session.deletedAt),
    );
  }
}
