class AcademicSemester {
  const AcademicSemester({
    required this.id,
    required this.name,
    required this.year,
    required this.termIndex,
    this.deletedAt,
  });

  final String id;
  final String name;
  final int year;
  final int termIndex;
  final DateTime? deletedAt;
}

class SemesterCourse {
  const SemesterCourse({
    this.id,
    required this.semesterId,
    required this.name,
    required this.credits,
    required this.finalGrade,
    this.deletedAt,
  });

  final int? id;
  final String semesterId;
  final String name;
  final int credits;
  final double finalGrade;
  final DateTime? deletedAt;
}

class SemesterSummary {
  const SemesterSummary({required this.semester, required this.courses});

  final AcademicSemester semester;
  final List<SemesterCourse> courses;

  int get credits => courses.fold(0, (total, course) => total + course.credits);

  double? get average {
    if (credits == 0) {
      return null;
    }

    final weighted = courses.fold<double>(
      0,
      (total, course) => total + course.finalGrade * course.credits,
    );
    return weighted / credits;
  }
}
