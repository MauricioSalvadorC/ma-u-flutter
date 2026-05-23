part of '../database/app_database.dart';

@DriftAccessor(tables: [Semesters, SemesterCourses])
class SemestersDao extends DatabaseAccessor<AppDatabase>
    with _$SemestersDaoMixin {
  SemestersDao(super.db);

  Stream<List<SemesterRow>> watchSemesters() {
    return (select(semesters)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([
            (table) => OrderingTerm.desc(table.year),
            (table) => OrderingTerm.desc(table.termIndex),
            (table) => OrderingTerm.desc(table.createdAt),
          ]))
        .watch();
  }

  Stream<List<SemesterCourseRow>> watchCourses() {
    return (select(semesterCourses)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([(table) => OrderingTerm.desc(table.createdAt)]))
        .watch();
  }

  Stream<List<SemesterRow>> watchDeletedSemesters() {
    return (select(semesters)
          ..where((table) => table.deletedAt.isNotNull())
          ..orderBy([(table) => OrderingTerm.desc(table.deletedAt)]))
        .watch();
  }

  Stream<List<SemesterCourseRow>> watchDeletedCourses() {
    return (select(semesterCourses)
          ..where((table) => table.deletedAt.isNotNull())
          ..orderBy([(table) => OrderingTerm.desc(table.deletedAt)]))
        .watch();
  }

  Future<void> upsertSemester(SemestersCompanion semester) {
    return into(semesters).insertOnConflictUpdate(semester);
  }

  Future<int> insertCourse(SemesterCoursesCompanion course) {
    return into(semesterCourses).insert(course);
  }

  Future<bool> updateCourse(SemesterCoursesCompanion course) {
    final id = course.id.value;
    return (update(semesterCourses)..where((table) => table.id.equals(id)))
        .write(course)
        .then((rows) => rows > 0);
  }

  Future<bool> moveSemesterToTrash(String id) async {
    final now = DateTime.now();
    await (update(semesterCourses)
          ..where((table) => table.semesterId.equals(id)))
        .write(SemesterCoursesCompanion(deletedAt: Value(now)));
    return (update(semesters)..where((table) => table.id.equals(id)))
        .write(SemestersCompanion(deletedAt: Value(now)))
        .then((rows) => rows > 0);
  }

  Future<bool> moveCourseToTrash(int id) {
    return (update(semesterCourses)..where((table) => table.id.equals(id)))
        .write(SemesterCoursesCompanion(deletedAt: Value(DateTime.now())))
        .then((rows) => rows > 0);
  }

  Future<bool> restoreSemester(String id) async {
    await (update(semesterCourses)
          ..where((table) => table.semesterId.equals(id)))
        .write(const SemesterCoursesCompanion(deletedAt: Value(null)));
    return (update(semesters)..where((table) => table.id.equals(id)))
        .write(const SemestersCompanion(deletedAt: Value(null)))
        .then((rows) => rows > 0);
  }

  Future<bool> restoreCourse(int id) {
    return (update(semesterCourses)..where((table) => table.id.equals(id)))
        .write(const SemesterCoursesCompanion(deletedAt: Value(null)))
        .then((rows) => rows > 0);
  }
}
