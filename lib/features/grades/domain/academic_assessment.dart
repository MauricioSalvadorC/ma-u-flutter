import '../../../core/settings/app_settings_repository.dart';

class AcademicAssessment {
  const AcademicAssessment({
    this.id,
    required this.subjectId,
    required this.title,
    required this.grade,
    required this.weightPercent,
    required this.date,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
  });

  final int? id;
  final String subjectId;
  final String title;
  final double grade;
  final double weightPercent;
  final DateTime? date;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;

  AcademicAssessment copyWith({
    int? id,
    String? subjectId,
    String? title,
    double? grade,
    double? weightPercent,
    DateTime? date,
    bool clearDate = false,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return AcademicAssessment(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      grade: grade ?? this.grade,
      weightPercent: weightPercent ?? this.weightPercent,
      date: clearDate ? null : date ?? this.date,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: clearDeletedAt ? null : deletedAt ?? this.deletedAt,
    );
  }
}

class GradeProgress {
  const GradeProgress({
    required this.assessments,
    required this.scale,
    required this.passingGrade,
  });

  final List<AcademicAssessment> assessments;
  final GradeScale scale;
  final double passingGrade;

  double get evaluatedPercent {
    return assessments.fold<double>(
      0,
      (total, assessment) => total + assessment.weightPercent,
    );
  }

  double get remainingPercent {
    final remaining = 100 - evaluatedPercent;
    return remaining < 0 ? 0 : remaining;
  }

  double get accumulatedGrade {
    return assessments.fold<double>(
      0,
      (total, assessment) =>
          total + assessment.grade * (assessment.weightPercent / 100),
    );
  }

  double? get registeredAverage {
    if (evaluatedPercent <= 0) {
      return null;
    }

    return accumulatedGrade / (evaluatedPercent / 100);
  }

  double? get requiredGrade {
    if (remainingPercent <= 0) {
      return null;
    }

    return (passingGrade - accumulatedGrade) / (remainingPercent / 100);
  }

  GradeGoalStatus get status {
    final required = requiredGrade;
    if (remainingPercent <= 0) {
      return accumulatedGrade >= passingGrade
          ? GradeGoalStatus.passed
          : GradeGoalStatus.failed;
    }
    if (required == null) {
      return GradeGoalStatus.pending;
    }
    if (required <= 0) {
      return GradeGoalStatus.secured;
    }
    if (required > scale.maxValue) {
      return GradeGoalStatus.unreachable;
    }

    return GradeGoalStatus.pending;
  }
}

enum GradeGoalStatus { pending, secured, unreachable, passed, failed }
