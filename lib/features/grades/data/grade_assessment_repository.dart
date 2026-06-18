import 'package:drift/drift.dart';

import '../../../data/database/app_database.dart';
import '../domain/academic_assessment.dart';

class GradeAssessmentRepository {
  const GradeAssessmentRepository(this._database);

  final AppDatabase _database;

  Stream<List<AcademicAssessment>> watchAssessments() {
    return _database.gradeAssessmentsDao.watchAll().map(
      (rows) => rows.map(_toDomain).toList(),
    );
  }

  Stream<List<AcademicAssessment>> watchDeletedAssessments() {
    return _database.gradeAssessmentsDao.watchDeleted().map(
      (rows) => rows.map(_toDomain).toList(),
    );
  }

  Future<int> saveAssessment(AcademicAssessment assessment) async {
    final now = DateTime.now();
    final normalized = assessment.copyWith(
      createdAt: assessment.id == null ? now : assessment.createdAt,
      updatedAt: now,
    );

    if (normalized.id != null) {
      await _database.gradeAssessmentsDao.updateAssessment(
        _toCompanion(normalized),
      );
      return normalized.id!;
    }

    return _database.gradeAssessmentsDao.insertAssessment(
      _toCompanion(normalized),
    );
  }

  Future<bool> moveToTrash(int id) {
    return _database.gradeAssessmentsDao.moveToTrash(id);
  }

  Future<bool> restoreAssessment(int id) {
    return _database.gradeAssessmentsDao.restoreAssessment(id);
  }

  AcademicAssessment _toDomain(GradeAssessmentRow row) {
    return AcademicAssessment(
      id: row.id,
      subjectId: row.subjectId,
      title: row.title,
      grade: row.grade,
      weightPercent: row.weightPercent,
      date: row.date,
      notes: row.notes ?? '',
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  AcademicAssessmentsCompanion _toCompanion(AcademicAssessment assessment) {
    return AcademicAssessmentsCompanion(
      id: assessment.id == null ? const Value.absent() : Value(assessment.id!),
      subjectId: Value(assessment.subjectId),
      title: Value(assessment.title),
      grade: Value(assessment.grade),
      weightPercent: Value(assessment.weightPercent),
      date: Value(assessment.date),
      notes: Value(assessment.notes.isEmpty ? null : assessment.notes),
      createdAt: Value(assessment.createdAt),
      updatedAt: Value(assessment.updatedAt),
      deletedAt: Value(assessment.deletedAt),
    );
  }
}
