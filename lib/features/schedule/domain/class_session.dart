enum Weekday {
  monday('Lunes', 'Lun'),
  tuesday('Martes', 'Mar'),
  wednesday('Miercoles', 'Mie'),
  thursday('Jueves', 'Jue'),
  friday('Viernes', 'Vie'),
  saturday('Sabado', 'Sab');

  const Weekday(this.label, this.shortLabel);

  final String label;
  final String shortLabel;
}

class ClassSession {
  const ClassSession({
    this.id,
    required this.subjectId,
    required this.weekday,
    required this.startsAtMinute,
    required this.endsAtMinute,
    required this.location,
    this.deletedAt,
  });

  final int? id;
  final String subjectId;
  final Weekday weekday;
  final int startsAtMinute;
  final int endsAtMinute;
  final String location;
  final DateTime? deletedAt;

  ClassSession copyWith({
    int? id,
    String? subjectId,
    Weekday? weekday,
    int? startsAtMinute,
    int? endsAtMinute,
    String? location,
    DateTime? deletedAt,
  }) {
    return ClassSession(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      weekday: weekday ?? this.weekday,
      startsAtMinute: startsAtMinute ?? this.startsAtMinute,
      endsAtMinute: endsAtMinute ?? this.endsAtMinute,
      location: location ?? this.location,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  String get timeRange {
    return '${_formatMinute(startsAtMinute)} - ${_formatMinute(endsAtMinute)}';
  }

  static String _formatMinute(int minuteOfDay) {
    final hour = minuteOfDay ~/ 60;
    final minute = minuteOfDay % 60;
    final hourText = hour.toString().padLeft(2, '0');
    final minuteText = minute.toString().padLeft(2, '0');
    return '$hourText:$minuteText';
  }
}
