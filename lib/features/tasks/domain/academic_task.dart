enum TaskPriority {
  low('Baja'),
  medium('Media'),
  high('Alta');

  const TaskPriority(this.label);

  final String label;
}

class AcademicTask {
  const AcademicTask({
    this.id,
    required this.subjectId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.isCompleted,
    required this.deletedAt,
  });

  final int? id;
  final String subjectId;
  final String title;
  final String description;
  final DateTime? dueDate;
  final TaskPriority priority;
  final bool isCompleted;
  final DateTime? deletedAt;

  AcademicTask copyWith({
    int? id,
    String? subjectId,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskPriority? priority,
    bool? isCompleted,
    DateTime? deletedAt,
  }) {
    return AcademicTask(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
