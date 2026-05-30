part of '../database/app_database.dart';

@DriftAccessor(tables: [AcademicTasks, Subjects])
class TasksDao extends DatabaseAccessor<AppDatabase> with _$TasksDaoMixin {
  TasksDao(super.db);

  Stream<List<TaskRow>> watchAll() {
    return (select(academicTasks)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([
            (table) => OrderingTerm.asc(table.isCompleted),
            (table) => OrderingTerm.asc(table.dueDate),
            (table) => OrderingTerm.desc(table.priorityIndex),
            (table) => OrderingTerm.desc(table.createdAt),
          ]))
        .watch();
  }

  Stream<List<TaskRow>> watchDeleted() {
    return (select(academicTasks)
          ..where((table) => table.deletedAt.isNotNull())
          ..orderBy([(table) => OrderingTerm.desc(table.deletedAt)]))
        .watch();
  }

  Future<TaskRow?> getById(int id) {
    return (select(
      academicTasks,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertTask(AcademicTasksCompanion task) {
    return into(academicTasks).insert(task);
  }

  Future<bool> updateTask(AcademicTasksCompanion task) {
    final id = task.id.value;
    return (update(academicTasks)..where((table) => table.id.equals(id)))
        .write(task)
        .then((rows) => rows > 0);
  }

  Future<bool> updateCompleted({required int id, required bool isCompleted}) {
    return (update(academicTasks)..where((table) => table.id.equals(id)))
        .write(AcademicTasksCompanion(isCompleted: Value(isCompleted)))
        .then((rows) => rows > 0);
  }

  Future<bool> moveToTrash(int id) {
    return (update(academicTasks)..where((table) => table.id.equals(id)))
        .write(AcademicTasksCompanion(deletedAt: Value(DateTime.now())))
        .then((rows) => rows > 0);
  }

  Future<bool> restoreTask(int id) {
    return (update(academicTasks)..where((table) => table.id.equals(id)))
        .write(const AcademicTasksCompanion(deletedAt: Value(null)))
        .then((rows) => rows > 0);
  }
}
