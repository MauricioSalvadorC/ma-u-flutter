import 'package:drift/drift.dart';

import '../../../data/database/app_database.dart';
import '../domain/academic_task.dart';

class TaskRepository {
  const TaskRepository(this._database);

  final AppDatabase _database;

  Stream<List<AcademicTask>> watchTasks() {
    return _database.tasksDao.watchAll().map(
      (rows) => rows.map(_toDomain).toList(),
    );
  }

  Future<int> saveTask(AcademicTask task) {
    return _database.tasksDao.insertTask(_toCompanion(task));
  }

  Future<bool> setCompleted({required int id, required bool isCompleted}) {
    return _database.tasksDao.updateCompleted(id: id, isCompleted: isCompleted);
  }

  Future<int> deleteTask(int id) {
    return _database.tasksDao.deleteTask(id);
  }

  AcademicTask _toDomain(TaskRow row) {
    return AcademicTask(
      id: row.id,
      subjectId: row.subjectId,
      title: row.title,
      description: row.description ?? '',
      dueDate: row.dueDate,
      priority: TaskPriority.values[row.priorityIndex],
      isCompleted: row.isCompleted,
    );
  }

  AcademicTasksCompanion _toCompanion(AcademicTask task) {
    return AcademicTasksCompanion(
      subjectId: Value(task.subjectId),
      title: Value(task.title),
      description: Value(task.description.isEmpty ? null : task.description),
      dueDate: Value(task.dueDate),
      priorityIndex: Value(task.priority.index),
      isCompleted: Value(task.isCompleted),
    );
  }
}
