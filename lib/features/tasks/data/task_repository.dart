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

  Stream<List<AcademicTask>> watchDeletedTasks() {
    return _database.tasksDao.watchDeleted().map(
      (rows) => rows.map(_toDomain).toList(),
    );
  }

  Future<int> saveTask(AcademicTask task) {
    if (task.id != null) {
      return _database.tasksDao
          .updateTask(_toCompanion(task))
          .then((_) => task.id!);
    }

    return _database.tasksDao.insertTask(_toCompanion(task));
  }

  Future<bool> setCompleted({required int id, required bool isCompleted}) {
    return _database.tasksDao.updateCompleted(id: id, isCompleted: isCompleted);
  }

  Future<bool> moveToTrash(int id) {
    return _database.tasksDao.moveToTrash(id);
  }

  Future<bool> restoreTask(int id) {
    return _database.tasksDao.restoreTask(id);
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
      deletedAt: row.deletedAt,
    );
  }

  AcademicTasksCompanion _toCompanion(AcademicTask task) {
    return AcademicTasksCompanion(
      id: task.id == null ? const Value.absent() : Value(task.id!),
      subjectId: Value(task.subjectId),
      title: Value(task.title),
      description: Value(task.description.isEmpty ? null : task.description),
      dueDate: Value(task.dueDate),
      priorityIndex: Value(task.priority.index),
      isCompleted: Value(task.isCompleted),
      deletedAt: Value(task.deletedAt),
    );
  }
}
