part of '../database/app_database.dart';

@DriftAccessor(tables: [AcademicGoals])
class AcademicGoalsDao extends DatabaseAccessor<AppDatabase>
    with _$AcademicGoalsDaoMixin {
  AcademicGoalsDao(super.db);

  Stream<AcademicGoalRow?> watchGoal() {
    return (select(
      academicGoals,
    )..where((table) => table.id.equals('main'))).watchSingleOrNull();
  }

  Future<void> saveGoal(AcademicGoalsCompanion goal) {
    return into(academicGoals).insertOnConflictUpdate(goal);
  }
}
