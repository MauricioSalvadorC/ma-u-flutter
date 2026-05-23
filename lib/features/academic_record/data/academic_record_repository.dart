import 'package:drift/drift.dart';

import '../../../data/database/app_database.dart';
import '../domain/academic_record.dart';

class AcademicRecordRepository {
  const AcademicRecordRepository(this._database);

  final AppDatabase _database;

  Stream<List<SemesterSummary>> watchSummaries() {
    return Stream.multi((controller) {
      List<SemesterRow>? semesters;
      List<SemesterCourseRow>? courses;

      void emit() {
        final semesterRows = semesters;
        final courseRows = courses;
        if (semesterRows == null || courseRows == null) {
          return;
        }

        controller.add([
          for (final semester in semesterRows)
            SemesterSummary(
              semester: _toSemester(semester),
              courses: courseRows
                  .where((course) => course.semesterId == semester.id)
                  .map(_toCourse)
                  .toList(),
            ),
        ]);
      }

      final semesterSubscription = _database.semestersDao
          .watchSemesters()
          .listen((rows) {
            semesters = rows;
            emit();
          }, onError: controller.addError);
      final courseSubscription = _database.semestersDao.watchCourses().listen((
        rows,
      ) {
        courses = rows;
        emit();
      }, onError: controller.addError);

      controller.onCancel = () async {
        await semesterSubscription.cancel();
        await courseSubscription.cancel();
      };
    });
  }

  Future<void> saveSemester(AcademicSemester semester) {
    return _database.semestersDao.upsertSemester(
      SemestersCompanion(
        id: Value(semester.id),
        name: Value(semester.name),
        year: Value(semester.year),
        termIndex: Value(semester.termIndex),
      ),
    );
  }

  Future<int> saveCourse(SemesterCourse course) {
    final companion = SemesterCoursesCompanion(
      id: course.id == null ? const Value.absent() : Value(course.id!),
      semesterId: Value(course.semesterId),
      name: Value(course.name),
      credits: Value(course.credits),
      finalGrade: Value(course.finalGrade),
    );

    if (course.id != null) {
      return _database.semestersDao
          .updateCourse(companion)
          .then((_) => course.id!);
    }
    return _database.semestersDao.insertCourse(companion);
  }

  Future<bool> moveSemesterToTrash(String id) {
    return _database.semestersDao.moveSemesterToTrash(id);
  }

  Future<bool> moveCourseToTrash(int id) {
    return _database.semestersDao.moveCourseToTrash(id);
  }

  AcademicSemester _toSemester(SemesterRow row) {
    return AcademicSemester(
      id: row.id,
      name: row.name,
      year: row.year,
      termIndex: row.termIndex,
    );
  }

  SemesterCourse _toCourse(SemesterCourseRow row) {
    return SemesterCourse(
      id: row.id,
      semesterId: row.semesterId,
      name: row.name,
      credits: row.credits,
      finalGrade: row.finalGrade,
    );
  }
}
