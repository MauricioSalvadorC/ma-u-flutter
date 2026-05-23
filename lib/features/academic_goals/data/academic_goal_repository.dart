import 'package:drift/drift.dart';

import '../../../data/database/app_database.dart';
import '../domain/academic_goal.dart';

class AcademicGoalRepository {
  const AcademicGoalRepository(this._database);

  final AppDatabase _database;

  Stream<AcademicGoal?> watchGoal() {
    return _database.academicGoalsDao.watchGoal().map((row) {
      if (row == null) {
        return null;
      }
      return AcademicGoal(
        targetAverage: row.targetAverage,
        plannedCredits: row.plannedCredits,
        expectedAverage: row.expectedAverage,
      );
    });
  }

  Future<void> saveGoal(AcademicGoal goal) {
    return _database.academicGoalsDao.saveGoal(
      AcademicGoalsCompanion(
        id: const Value('main'),
        targetAverage: Value(goal.targetAverage),
        plannedCredits: Value(goal.plannedCredits),
        expectedAverage: Value(goal.expectedAverage),
      ),
    );
  }
}
