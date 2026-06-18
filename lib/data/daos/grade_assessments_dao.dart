part of '../database/app_database.dart';

@DriftAccessor(tables: [AcademicAssessments, Subjects])
class GradeAssessmentsDao extends DatabaseAccessor<AppDatabase>
    with _$GradeAssessmentsDaoMixin {
  GradeAssessmentsDao(super.db);

  Stream<List<GradeAssessmentRow>> watchAll() {
    return (select(academicAssessments)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([
            (table) => OrderingTerm.asc(table.date),
            (table) => OrderingTerm.desc(table.updatedAt),
          ]))
        .watch();
  }

  Stream<List<GradeAssessmentRow>> watchDeleted() {
    return (select(academicAssessments)
          ..where((table) => table.deletedAt.isNotNull())
          ..orderBy([(table) => OrderingTerm.desc(table.deletedAt)]))
        .watch();
  }

  Future<GradeAssessmentRow?> getById(int id) {
    return (select(
      academicAssessments,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertAssessment(AcademicAssessmentsCompanion assessment) {
    return into(academicAssessments).insert(assessment);
  }

  Future<bool> updateAssessment(AcademicAssessmentsCompanion assessment) {
    final id = assessment.id.value;
    return (update(academicAssessments)..where((table) => table.id.equals(id)))
        .write(assessment)
        .then((rows) => rows > 0);
  }

  Future<bool> moveToTrash(int id) {
    return (update(academicAssessments)..where((table) => table.id.equals(id)))
        .write(AcademicAssessmentsCompanion(deletedAt: Value(DateTime.now())))
        .then((rows) => rows > 0);
  }

  Future<bool> restoreAssessment(int id) {
    return (update(academicAssessments)..where((table) => table.id.equals(id)))
        .write(const AcademicAssessmentsCompanion(deletedAt: Value(null)))
        .then((rows) => rows > 0);
  }
}
