import 'package:drift/drift.dart';

import '../../../data/database/app_database.dart';
import '../domain/subject.dart' as domain;

class SubjectRepository {
  const SubjectRepository(this._database);

  final AppDatabase _database;

  Stream<List<domain.Subject>> watchSubjects() {
    return _database.subjectsDao.watchAll().map(
      (rows) => rows.map(_toDomain).toList(),
    );
  }

  Future<List<domain.Subject>> getSubjects() async {
    final rows = await _database.subjectsDao.getAll();
    return rows.map(_toDomain).toList();
  }

  Future<void> saveSubject(domain.Subject subject) {
    return _database.subjectsDao.upsertSubject(_toCompanion(subject));
  }

  Future<void> seedIfEmpty() async {
    final existingSubjects = await _database.subjectsDao.getAll();
    if (existingSubjects.isNotEmpty) {
      return;
    }

    await _database.subjectsDao.insertAll(
      demoSubjects.map(_toCompanion).toList(),
    );
  }

  static const demoSubjects = [
    domain.Subject(
      id: 'calculus',
      name: 'Calculo diferencial',
      teacher: 'Dra. Valentina Rios',
      room: 'B-204',
      credits: 3,
      accentColorValue: 0xFF2563EB,
    ),
    domain.Subject(
      id: 'programming',
      name: 'Programacion movil',
      teacher: 'Ing. Andres Perez',
      room: 'Lab 3',
      credits: 4,
      accentColorValue: 0xFF0F766E,
    ),
    domain.Subject(
      id: 'physics',
      name: 'Fisica mecanica',
      teacher: 'Dr. Camilo Torres',
      room: 'C-101',
      credits: 3,
      accentColorValue: 0xFFDC6B19,
    ),
    domain.Subject(
      id: 'english',
      name: 'Ingles academico',
      teacher: 'Laura Gomez',
      room: 'A-302',
      credits: 2,
      accentColorValue: 0xFF7C3AED,
    ),
  ];

  domain.Subject _toDomain(SubjectRow row) {
    return domain.Subject(
      id: row.id,
      name: row.name,
      teacher: row.teacher,
      room: row.room,
      credits: row.credits,
      accentColorValue: row.accentColorValue,
    );
  }

  SubjectsCompanion _toCompanion(domain.Subject subject) {
    return SubjectsCompanion(
      id: Value(subject.id),
      name: Value(subject.name),
      teacher: Value(subject.teacher),
      room: Value(subject.room),
      credits: Value(subject.credits),
      accentColorValue: Value(subject.accentColorValue),
    );
  }
}
