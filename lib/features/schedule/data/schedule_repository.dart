import 'package:drift/drift.dart';

import '../../../data/database/app_database.dart';
import '../domain/class_session.dart';

class ScheduleRepository {
  const ScheduleRepository(this._database);

  final AppDatabase _database;

  Stream<List<ClassSession>> watchSessions() {
    return _database.scheduleDao.watchAll().map(
      (rows) => rows.map(_toDomain).toList(),
    );
  }

  Future<List<ClassSession>> getSessions() async {
    final rows = await _database.scheduleDao.getAll();
    return rows.map(_toDomain).toList();
  }

  Future<int> saveSession(ClassSession session) {
    return _database.scheduleDao.insertScheduleEntry(_toCompanion(session));
  }

  Future<void> seedIfEmpty() async {
    final existingSessions = await _database.scheduleDao.getAll();
    if (existingSessions.isNotEmpty) {
      return;
    }

    await _database.scheduleDao.insertAll(
      demoSessions.map(_toCompanion).toList(),
    );
  }

  static const demoSessions = [
    ClassSession(
      subjectId: 'calculus',
      weekday: Weekday.monday,
      startsAtMinute: 7 * 60,
      endsAtMinute: 9 * 60,
      location: 'B-204',
    ),
    ClassSession(
      subjectId: 'programming',
      weekday: Weekday.monday,
      startsAtMinute: 10 * 60,
      endsAtMinute: 12 * 60,
      location: 'Lab 3',
    ),
    ClassSession(
      subjectId: 'physics',
      weekday: Weekday.tuesday,
      startsAtMinute: 8 * 60,
      endsAtMinute: 10 * 60,
      location: 'C-101',
    ),
    ClassSession(
      subjectId: 'english',
      weekday: Weekday.wednesday,
      startsAtMinute: 14 * 60,
      endsAtMinute: 16 * 60,
      location: 'A-302',
    ),
    ClassSession(
      subjectId: 'programming',
      weekday: Weekday.thursday,
      startsAtMinute: 9 * 60,
      endsAtMinute: 11 * 60,
      location: 'Lab 3',
    ),
    ClassSession(
      subjectId: 'calculus',
      weekday: Weekday.friday,
      startsAtMinute: 7 * 60,
      endsAtMinute: 9 * 60,
      location: 'B-204',
    ),
  ];

  ClassSession _toDomain(ScheduleRow row) {
    return ClassSession(
      id: row.id,
      subjectId: row.subjectId,
      weekday: Weekday.values[row.weekdayIndex],
      startsAtMinute: row.startsAtMinute,
      endsAtMinute: row.endsAtMinute,
      location: row.location,
    );
  }

  ScheduleEntriesCompanion _toCompanion(ClassSession session) {
    return ScheduleEntriesCompanion(
      subjectId: Value(session.subjectId),
      weekdayIndex: Value(session.weekday.index),
      startsAtMinute: Value(session.startsAtMinute),
      endsAtMinute: Value(session.endsAtMinute),
      location: Value(session.location),
    );
  }
}
