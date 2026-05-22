part of '../database/app_database.dart';

@DriftAccessor(tables: [AcademicTasks, Subjects])
class TasksDao extends DatabaseAccessor<AppDatabase> with _$TasksDaoMixin {
  TasksDao(super.db);

  Stream<List<TaskRow>> watchAll() {
    return (select(academicTasks)..orderBy([
          (table) => OrderingTerm.asc(table.isCompleted),
          (table) => OrderingTerm.asc(table.dueDate),
          (table) => OrderingTerm.desc(table.priorityIndex),
          (table) => OrderingTerm.desc(table.createdAt),
        ]))
        .watch();
  }

  Future<int> insertTask(AcademicTasksCompanion task) {
    return into(academicTasks).insert(task);
  }

  Future<bool> updateCompleted({required int id, required bool isCompleted}) {
    return (update(academicTasks)..where((table) => table.id.equals(id)))
        .write(AcademicTasksCompanion(isCompleted: Value(isCompleted)))
        .then((rows) => rows > 0);
  }

  Future<int> deleteTask(int id) {
    return (delete(academicTasks)..where((table) => table.id.equals(id))).go();
  }
}
