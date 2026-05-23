enum FocusLevel {
  light('Ligero'),
  deep('Profundo'),
  exam('Parcial');

  const FocusLevel(this.label);

  final String label;
}

class StudySession {
  const StudySession({
    this.id,
    required this.subjectId,
    required this.title,
    required this.notes,
    required this.startsAt,
    required this.durationMinutes,
    required this.focusLevel,
    required this.isCompleted,
    required this.deletedAt,
  });

  final int? id;
  final String subjectId;
  final String title;
  final String notes;
  final DateTime? startsAt;
  final int durationMinutes;
  final FocusLevel focusLevel;
  final bool isCompleted;
  final DateTime? deletedAt;

  StudySession copyWith({
    int? id,
    String? subjectId,
    String? title,
    String? notes,
    DateTime? startsAt,
    int? durationMinutes,
    FocusLevel? focusLevel,
    bool? isCompleted,
    DateTime? deletedAt,
  }) {
    return StudySession(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      notes: notes ?? this.notes,
      startsAt: startsAt ?? this.startsAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      focusLevel: focusLevel ?? this.focusLevel,
      isCompleted: isCompleted ?? this.isCompleted,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }
}
