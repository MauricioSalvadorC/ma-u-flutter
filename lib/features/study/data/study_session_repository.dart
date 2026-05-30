import 'package:drift/drift.dart';

import '../../../core/notifications/notification_service.dart';
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

  Future<int> saveSession(StudySession session) async {
    late final int id;
    if (session.id != null) {
      await _database.studySessionsDao.updateSession(_toCompanion(session));
      id = session.id!;
    } else {
      id = await _database.studySessionsDao.insertSession(
        _toCompanion(session),
      );
    }

    await _syncReminder(session.copyWith(id: id));
    return id;
  }

  Future<bool> setCompleted({
    required int id,
    required bool isCompleted,
  }) async {
    final updated = await _database.studySessionsDao.updateCompleted(
      id: id,
      isCompleted: isCompleted,
    );
    if (updated) {
      final row = await _database.studySessionsDao.getById(id);
      if (row != null) {
        await _syncReminder(_toDomain(row));
      }
    }
    return updated;
  }

  Future<bool> moveToTrash(int id) async {
    final updated = await _database.studySessionsDao.moveToTrash(id);
    if (updated) {
      await MaUNotifications.instance.cancelStudyReminder(id);
    }
    return updated;
  }

  Future<bool> restoreSession(int id) async {
    final updated = await _database.studySessionsDao.restoreSession(id);
    if (updated) {
      final row = await _database.studySessionsDao.getById(id);
      if (row != null) {
        await _syncReminder(_toDomain(row));
      }
    }
    return updated;
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
      reminderEnabled: row.reminderEnabled,
      reminderMinutesBefore: row.reminderMinutesBefore,
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
      reminderEnabled: Value(session.reminderEnabled),
      reminderMinutesBefore: Value(session.reminderMinutesBefore),
      isCompleted: Value(session.isCompleted),
      deletedAt: Value(session.deletedAt),
    );
  }

  Future<void> _syncReminder(StudySession session) async {
    final id = session.id;
    final startsAt = session.startsAt;
    if (id == null) {
      return;
    }

    if (!session.reminderEnabled ||
        session.isCompleted ||
        session.deletedAt != null ||
        startsAt == null) {
      await MaUNotifications.instance.cancelStudyReminder(id);
      return;
    }

    final subject = await _database.subjectsDao.getById(session.subjectId);
    await MaUNotifications.instance.scheduleStudyReminder(
      sessionId: id,
      title: session.title,
      subjectName: subject?.name ?? 'Materia',
      startsAt: startsAt,
      minutesBefore: session.reminderMinutesBefore,
    );
  }
}
