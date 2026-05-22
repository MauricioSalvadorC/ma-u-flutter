class Subject {
  const Subject({
    required this.id,
    required this.name,
    required this.teacher,
    required this.room,
    required this.credits,
    required this.accentColorValue,
  });

  final String id;
  final String name;
  final String teacher;
  final String room;
  final int credits;
  final int accentColorValue;

  Subject copyWith({
    String? id,
    String? name,
    String? teacher,
    String? room,
    int? credits,
    int? accentColorValue,
  }) {
    return Subject(
      id: id ?? this.id,
      name: name ?? this.name,
      teacher: teacher ?? this.teacher,
      room: room ?? this.room,
      credits: credits ?? this.credits,
      accentColorValue: accentColorValue ?? this.accentColorValue,
    );
  }
}
