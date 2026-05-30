import 'package:drift/drift.dart';

import '../../../core/notifications/notification_service.dart';
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

  Future<int> saveTask(AcademicTask task) async {
    late final int id;
    if (task.id != null) {
      await _database.tasksDao.updateTask(_toCompanion(task));
      id = task.id!;
    } else {
      id = await _database.tasksDao.insertTask(_toCompanion(task));
    }

    await _syncReminder(task.copyWith(id: id));
    return id;
  }

  Future<bool> setCompleted({
    required int id,
    required bool isCompleted,
  }) async {
    final updated = await _database.tasksDao.updateCompleted(
      id: id,
      isCompleted: isCompleted,
    );
    if (updated) {
      final row = await _database.tasksDao.getById(id);
      if (row != null) {
        await _syncReminder(_toDomain(row));
      }
    }
    return updated;
  }

  Future<bool> moveToTrash(int id) async {
    final updated = await _database.tasksDao.moveToTrash(id);
    if (updated) {
      await MaUNotifications.instance.cancelTaskReminder(id);
    }
    return updated;
  }

  Future<bool> restoreTask(int id) async {
    final updated = await _database.tasksDao.restoreTask(id);
    if (updated) {
      final row = await _database.tasksDao.getById(id);
      if (row != null) {
        await _syncReminder(_toDomain(row));
      }
    }
    return updated;
  }

  AcademicTask _toDomain(TaskRow row) {
    return AcademicTask(
      id: row.id,
      subjectId: row.subjectId,
      title: row.title,
      description: row.description ?? '',
      dueDate: row.dueDate,
      priority: TaskPriority.values[row.priorityIndex],
      reminderEnabled: row.reminderEnabled,
      reminderMinutesBefore: row.reminderMinutesBefore,
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
      reminderEnabled: Value(task.reminderEnabled),
      reminderMinutesBefore: Value(task.reminderMinutesBefore),
      isCompleted: Value(task.isCompleted),
      deletedAt: Value(task.deletedAt),
    );
  }

  Future<void> _syncReminder(AcademicTask task) async {
    final id = task.id;
    final dueDate = task.dueDate;
    if (id == null) {
      return;
    }

    if (!task.reminderEnabled ||
        task.isCompleted ||
        task.deletedAt != null ||
        dueDate == null) {
      await MaUNotifications.instance.cancelTaskReminder(id);
      return;
    }

    final subject = await _database.subjectsDao.getById(task.subjectId);
    await MaUNotifications.instance.scheduleTaskReminder(
      taskId: id,
      title: task.title,
      subjectName: subject?.name ?? 'Materia',
      dueDate: dueDate,
      minutesBefore: task.reminderMinutesBefore,
    );
  }
}
