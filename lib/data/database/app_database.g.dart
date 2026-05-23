// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $SubjectsTable extends Subjects
    with TableInfo<$SubjectsTable, SubjectRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teacherMeta = const VerificationMeta(
    'teacher',
  );
  @override
  late final GeneratedColumn<String> teacher = GeneratedColumn<String>(
    'teacher',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roomMeta = const VerificationMeta('room');
  @override
  late final GeneratedColumn<String> room = GeneratedColumn<String>(
    'room',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _creditsMeta = const VerificationMeta(
    'credits',
  );
  @override
  late final GeneratedColumn<int> credits = GeneratedColumn<int>(
    'credits',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _accentColorValueMeta = const VerificationMeta(
    'accentColorValue',
  );
  @override
  late final GeneratedColumn<int> accentColorValue = GeneratedColumn<int>(
    'accent_color_value',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    teacher,
    room,
    credits,
    accentColorValue,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subjects';
  @override
  VerificationContext validateIntegrity(
    Insertable<SubjectRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('teacher')) {
      context.handle(
        _teacherMeta,
        teacher.isAcceptableOrUnknown(data['teacher']!, _teacherMeta),
      );
    } else if (isInserting) {
      context.missing(_teacherMeta);
    }
    if (data.containsKey('room')) {
      context.handle(
        _roomMeta,
        room.isAcceptableOrUnknown(data['room']!, _roomMeta),
      );
    } else if (isInserting) {
      context.missing(_roomMeta);
    }
    if (data.containsKey('credits')) {
      context.handle(
        _creditsMeta,
        credits.isAcceptableOrUnknown(data['credits']!, _creditsMeta),
      );
    } else if (isInserting) {
      context.missing(_creditsMeta);
    }
    if (data.containsKey('accent_color_value')) {
      context.handle(
        _accentColorValueMeta,
        accentColorValue.isAcceptableOrUnknown(
          data['accent_color_value']!,
          _accentColorValueMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_accentColorValueMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubjectRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubjectRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      teacher: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teacher'],
      )!,
      room: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}room'],
      )!,
      credits: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}credits'],
      )!,
      accentColorValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}accent_color_value'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SubjectsTable createAlias(String alias) {
    return $SubjectsTable(attachedDatabase, alias);
  }
}

class SubjectRow extends DataClass implements Insertable<SubjectRow> {
  final String id;
  final String name;
  final String teacher;
  final String room;
  final int credits;
  final int accentColorValue;
  final DateTime createdAt;
  const SubjectRow({
    required this.id,
    required this.name,
    required this.teacher,
    required this.room,
    required this.credits,
    required this.accentColorValue,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['teacher'] = Variable<String>(teacher);
    map['room'] = Variable<String>(room);
    map['credits'] = Variable<int>(credits);
    map['accent_color_value'] = Variable<int>(accentColorValue);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SubjectsCompanion toCompanion(bool nullToAbsent) {
    return SubjectsCompanion(
      id: Value(id),
      name: Value(name),
      teacher: Value(teacher),
      room: Value(room),
      credits: Value(credits),
      accentColorValue: Value(accentColorValue),
      createdAt: Value(createdAt),
    );
  }

  factory SubjectRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubjectRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      teacher: serializer.fromJson<String>(json['teacher']),
      room: serializer.fromJson<String>(json['room']),
      credits: serializer.fromJson<int>(json['credits']),
      accentColorValue: serializer.fromJson<int>(json['accentColorValue']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'teacher': serializer.toJson<String>(teacher),
      'room': serializer.toJson<String>(room),
      'credits': serializer.toJson<int>(credits),
      'accentColorValue': serializer.toJson<int>(accentColorValue),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SubjectRow copyWith({
    String? id,
    String? name,
    String? teacher,
    String? room,
    int? credits,
    int? accentColorValue,
    DateTime? createdAt,
  }) => SubjectRow(
    id: id ?? this.id,
    name: name ?? this.name,
    teacher: teacher ?? this.teacher,
    room: room ?? this.room,
    credits: credits ?? this.credits,
    accentColorValue: accentColorValue ?? this.accentColorValue,
    createdAt: createdAt ?? this.createdAt,
  );
  SubjectRow copyWithCompanion(SubjectsCompanion data) {
    return SubjectRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      teacher: data.teacher.present ? data.teacher.value : this.teacher,
      room: data.room.present ? data.room.value : this.room,
      credits: data.credits.present ? data.credits.value : this.credits,
      accentColorValue: data.accentColorValue.present
          ? data.accentColorValue.value
          : this.accentColorValue,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubjectRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('teacher: $teacher, ')
          ..write('room: $room, ')
          ..write('credits: $credits, ')
          ..write('accentColorValue: $accentColorValue, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    teacher,
    room,
    credits,
    accentColorValue,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubjectRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.teacher == this.teacher &&
          other.room == this.room &&
          other.credits == this.credits &&
          other.accentColorValue == this.accentColorValue &&
          other.createdAt == this.createdAt);
}

class SubjectsCompanion extends UpdateCompanion<SubjectRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> teacher;
  final Value<String> room;
  final Value<int> credits;
  final Value<int> accentColorValue;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SubjectsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.teacher = const Value.absent(),
    this.room = const Value.absent(),
    this.credits = const Value.absent(),
    this.accentColorValue = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubjectsCompanion.insert({
    required String id,
    required String name,
    required String teacher,
    required String room,
    required int credits,
    required int accentColorValue,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       teacher = Value(teacher),
       room = Value(room),
       credits = Value(credits),
       accentColorValue = Value(accentColorValue);
  static Insertable<SubjectRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? teacher,
    Expression<String>? room,
    Expression<int>? credits,
    Expression<int>? accentColorValue,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (teacher != null) 'teacher': teacher,
      if (room != null) 'room': room,
      if (credits != null) 'credits': credits,
      if (accentColorValue != null) 'accent_color_value': accentColorValue,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubjectsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? teacher,
    Value<String>? room,
    Value<int>? credits,
    Value<int>? accentColorValue,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SubjectsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      teacher: teacher ?? this.teacher,
      room: room ?? this.room,
      credits: credits ?? this.credits,
      accentColorValue: accentColorValue ?? this.accentColorValue,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (teacher.present) {
      map['teacher'] = Variable<String>(teacher.value);
    }
    if (room.present) {
      map['room'] = Variable<String>(room.value);
    }
    if (credits.present) {
      map['credits'] = Variable<int>(credits.value);
    }
    if (accentColorValue.present) {
      map['accent_color_value'] = Variable<int>(accentColorValue.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubjectsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('teacher: $teacher, ')
          ..write('room: $room, ')
          ..write('credits: $credits, ')
          ..write('accentColorValue: $accentColorValue, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScheduleEntriesTable extends ScheduleEntries
    with TableInfo<$ScheduleEntriesTable, ScheduleRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScheduleEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES subjects (id)',
    ),
  );
  static const VerificationMeta _weekdayIndexMeta = const VerificationMeta(
    'weekdayIndex',
  );
  @override
  late final GeneratedColumn<int> weekdayIndex = GeneratedColumn<int>(
    'weekday_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startsAtMinuteMeta = const VerificationMeta(
    'startsAtMinute',
  );
  @override
  late final GeneratedColumn<int> startsAtMinute = GeneratedColumn<int>(
    'starts_at_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endsAtMinuteMeta = const VerificationMeta(
    'endsAtMinute',
  );
  @override
  late final GeneratedColumn<int> endsAtMinute = GeneratedColumn<int>(
    'ends_at_minute',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _locationMeta = const VerificationMeta(
    'location',
  );
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
    'location',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    subjectId,
    weekdayIndex,
    startsAtMinute,
    endsAtMinute,
    location,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedule_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScheduleRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('weekday_index')) {
      context.handle(
        _weekdayIndexMeta,
        weekdayIndex.isAcceptableOrUnknown(
          data['weekday_index']!,
          _weekdayIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_weekdayIndexMeta);
    }
    if (data.containsKey('starts_at_minute')) {
      context.handle(
        _startsAtMinuteMeta,
        startsAtMinute.isAcceptableOrUnknown(
          data['starts_at_minute']!,
          _startsAtMinuteMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_startsAtMinuteMeta);
    }
    if (data.containsKey('ends_at_minute')) {
      context.handle(
        _endsAtMinuteMeta,
        endsAtMinute.isAcceptableOrUnknown(
          data['ends_at_minute']!,
          _endsAtMinuteMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_endsAtMinuteMeta);
    }
    if (data.containsKey('location')) {
      context.handle(
        _locationMeta,
        location.isAcceptableOrUnknown(data['location']!, _locationMeta),
      );
    } else if (isInserting) {
      context.missing(_locationMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ScheduleRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScheduleRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      )!,
      weekdayIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}weekday_index'],
      )!,
      startsAtMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}starts_at_minute'],
      )!,
      endsAtMinute: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ends_at_minute'],
      )!,
      location: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}location'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ScheduleEntriesTable createAlias(String alias) {
    return $ScheduleEntriesTable(attachedDatabase, alias);
  }
}

class ScheduleRow extends DataClass implements Insertable<ScheduleRow> {
  final int id;
  final String subjectId;
  final int weekdayIndex;
  final int startsAtMinute;
  final int endsAtMinute;
  final String location;
  final DateTime createdAt;
  const ScheduleRow({
    required this.id,
    required this.subjectId,
    required this.weekdayIndex,
    required this.startsAtMinute,
    required this.endsAtMinute,
    required this.location,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['subject_id'] = Variable<String>(subjectId);
    map['weekday_index'] = Variable<int>(weekdayIndex);
    map['starts_at_minute'] = Variable<int>(startsAtMinute);
    map['ends_at_minute'] = Variable<int>(endsAtMinute);
    map['location'] = Variable<String>(location);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ScheduleEntriesCompanion toCompanion(bool nullToAbsent) {
    return ScheduleEntriesCompanion(
      id: Value(id),
      subjectId: Value(subjectId),
      weekdayIndex: Value(weekdayIndex),
      startsAtMinute: Value(startsAtMinute),
      endsAtMinute: Value(endsAtMinute),
      location: Value(location),
      createdAt: Value(createdAt),
    );
  }

  factory ScheduleRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScheduleRow(
      id: serializer.fromJson<int>(json['id']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      weekdayIndex: serializer.fromJson<int>(json['weekdayIndex']),
      startsAtMinute: serializer.fromJson<int>(json['startsAtMinute']),
      endsAtMinute: serializer.fromJson<int>(json['endsAtMinute']),
      location: serializer.fromJson<String>(json['location']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'subjectId': serializer.toJson<String>(subjectId),
      'weekdayIndex': serializer.toJson<int>(weekdayIndex),
      'startsAtMinute': serializer.toJson<int>(startsAtMinute),
      'endsAtMinute': serializer.toJson<int>(endsAtMinute),
      'location': serializer.toJson<String>(location),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ScheduleRow copyWith({
    int? id,
    String? subjectId,
    int? weekdayIndex,
    int? startsAtMinute,
    int? endsAtMinute,
    String? location,
    DateTime? createdAt,
  }) => ScheduleRow(
    id: id ?? this.id,
    subjectId: subjectId ?? this.subjectId,
    weekdayIndex: weekdayIndex ?? this.weekdayIndex,
    startsAtMinute: startsAtMinute ?? this.startsAtMinute,
    endsAtMinute: endsAtMinute ?? this.endsAtMinute,
    location: location ?? this.location,
    createdAt: createdAt ?? this.createdAt,
  );
  ScheduleRow copyWithCompanion(ScheduleEntriesCompanion data) {
    return ScheduleRow(
      id: data.id.present ? data.id.value : this.id,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      weekdayIndex: data.weekdayIndex.present
          ? data.weekdayIndex.value
          : this.weekdayIndex,
      startsAtMinute: data.startsAtMinute.present
          ? data.startsAtMinute.value
          : this.startsAtMinute,
      endsAtMinute: data.endsAtMinute.present
          ? data.endsAtMinute.value
          : this.endsAtMinute,
      location: data.location.present ? data.location.value : this.location,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleRow(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('weekdayIndex: $weekdayIndex, ')
          ..write('startsAtMinute: $startsAtMinute, ')
          ..write('endsAtMinute: $endsAtMinute, ')
          ..write('location: $location, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    subjectId,
    weekdayIndex,
    startsAtMinute,
    endsAtMinute,
    location,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScheduleRow &&
          other.id == this.id &&
          other.subjectId == this.subjectId &&
          other.weekdayIndex == this.weekdayIndex &&
          other.startsAtMinute == this.startsAtMinute &&
          other.endsAtMinute == this.endsAtMinute &&
          other.location == this.location &&
          other.createdAt == this.createdAt);
}

class ScheduleEntriesCompanion extends UpdateCompanion<ScheduleRow> {
  final Value<int> id;
  final Value<String> subjectId;
  final Value<int> weekdayIndex;
  final Value<int> startsAtMinute;
  final Value<int> endsAtMinute;
  final Value<String> location;
  final Value<DateTime> createdAt;
  const ScheduleEntriesCompanion({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.weekdayIndex = const Value.absent(),
    this.startsAtMinute = const Value.absent(),
    this.endsAtMinute = const Value.absent(),
    this.location = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ScheduleEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String subjectId,
    required int weekdayIndex,
    required int startsAtMinute,
    required int endsAtMinute,
    required String location,
    this.createdAt = const Value.absent(),
  }) : subjectId = Value(subjectId),
       weekdayIndex = Value(weekdayIndex),
       startsAtMinute = Value(startsAtMinute),
       endsAtMinute = Value(endsAtMinute),
       location = Value(location);
  static Insertable<ScheduleRow> custom({
    Expression<int>? id,
    Expression<String>? subjectId,
    Expression<int>? weekdayIndex,
    Expression<int>? startsAtMinute,
    Expression<int>? endsAtMinute,
    Expression<String>? location,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectId != null) 'subject_id': subjectId,
      if (weekdayIndex != null) 'weekday_index': weekdayIndex,
      if (startsAtMinute != null) 'starts_at_minute': startsAtMinute,
      if (endsAtMinute != null) 'ends_at_minute': endsAtMinute,
      if (location != null) 'location': location,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ScheduleEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? subjectId,
    Value<int>? weekdayIndex,
    Value<int>? startsAtMinute,
    Value<int>? endsAtMinute,
    Value<String>? location,
    Value<DateTime>? createdAt,
  }) {
    return ScheduleEntriesCompanion(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      weekdayIndex: weekdayIndex ?? this.weekdayIndex,
      startsAtMinute: startsAtMinute ?? this.startsAtMinute,
      endsAtMinute: endsAtMinute ?? this.endsAtMinute,
      location: location ?? this.location,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (weekdayIndex.present) {
      map['weekday_index'] = Variable<int>(weekdayIndex.value);
    }
    if (startsAtMinute.present) {
      map['starts_at_minute'] = Variable<int>(startsAtMinute.value);
    }
    if (endsAtMinute.present) {
      map['ends_at_minute'] = Variable<int>(endsAtMinute.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScheduleEntriesCompanion(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('weekdayIndex: $weekdayIndex, ')
          ..write('startsAtMinute: $startsAtMinute, ')
          ..write('endsAtMinute: $endsAtMinute, ')
          ..write('location: $location, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $AcademicTasksTable extends AcademicTasks
    with TableInfo<$AcademicTasksTable, TaskRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AcademicTasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES subjects (id)',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dueDateMeta = const VerificationMeta(
    'dueDate',
  );
  @override
  late final GeneratedColumn<DateTime> dueDate = GeneratedColumn<DateTime>(
    'due_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _priorityIndexMeta = const VerificationMeta(
    'priorityIndex',
  );
  @override
  late final GeneratedColumn<int> priorityIndex = GeneratedColumn<int>(
    'priority_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    subjectId,
    title,
    description,
    dueDate,
    priorityIndex,
    isCompleted,
    createdAt,
    deletedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'academic_tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<TaskRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('due_date')) {
      context.handle(
        _dueDateMeta,
        dueDate.isAcceptableOrUnknown(data['due_date']!, _dueDateMeta),
      );
    }
    if (data.containsKey('priority_index')) {
      context.handle(
        _priorityIndexMeta,
        priorityIndex.isAcceptableOrUnknown(
          data['priority_index']!,
          _priorityIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_priorityIndexMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TaskRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TaskRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      dueDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_date'],
      ),
      priorityIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}priority_index'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
    );
  }

  @override
  $AcademicTasksTable createAlias(String alias) {
    return $AcademicTasksTable(attachedDatabase, alias);
  }
}

class TaskRow extends DataClass implements Insertable<TaskRow> {
  final int id;
  final String subjectId;
  final String title;
  final String? description;
  final DateTime? dueDate;
  final int priorityIndex;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime? deletedAt;
  const TaskRow({
    required this.id,
    required this.subjectId,
    required this.title,
    this.description,
    this.dueDate,
    required this.priorityIndex,
    required this.isCompleted,
    required this.createdAt,
    this.deletedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['subject_id'] = Variable<String>(subjectId);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || dueDate != null) {
      map['due_date'] = Variable<DateTime>(dueDate);
    }
    map['priority_index'] = Variable<int>(priorityIndex);
    map['is_completed'] = Variable<bool>(isCompleted);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    return map;
  }

  AcademicTasksCompanion toCompanion(bool nullToAbsent) {
    return AcademicTasksCompanion(
      id: Value(id),
      subjectId: Value(subjectId),
      title: Value(title),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      dueDate: dueDate == null && nullToAbsent
          ? const Value.absent()
          : Value(dueDate),
      priorityIndex: Value(priorityIndex),
      isCompleted: Value(isCompleted),
      createdAt: Value(createdAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
    );
  }

  factory TaskRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TaskRow(
      id: serializer.fromJson<int>(json['id']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String?>(json['description']),
      dueDate: serializer.fromJson<DateTime?>(json['dueDate']),
      priorityIndex: serializer.fromJson<int>(json['priorityIndex']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'subjectId': serializer.toJson<String>(subjectId),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String?>(description),
      'dueDate': serializer.toJson<DateTime?>(dueDate),
      'priorityIndex': serializer.toJson<int>(priorityIndex),
      'isCompleted': serializer.toJson<bool>(isCompleted),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
    };
  }

  TaskRow copyWith({
    int? id,
    String? subjectId,
    String? title,
    Value<String?> description = const Value.absent(),
    Value<DateTime?> dueDate = const Value.absent(),
    int? priorityIndex,
    bool? isCompleted,
    DateTime? createdAt,
    Value<DateTime?> deletedAt = const Value.absent(),
  }) => TaskRow(
    id: id ?? this.id,
    subjectId: subjectId ?? this.subjectId,
    title: title ?? this.title,
    description: description.present ? description.value : this.description,
    dueDate: dueDate.present ? dueDate.value : this.dueDate,
    priorityIndex: priorityIndex ?? this.priorityIndex,
    isCompleted: isCompleted ?? this.isCompleted,
    createdAt: createdAt ?? this.createdAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
  );
  TaskRow copyWithCompanion(AcademicTasksCompanion data) {
    return TaskRow(
      id: data.id.present ? data.id.value : this.id,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      dueDate: data.dueDate.present ? data.dueDate.value : this.dueDate,
      priorityIndex: data.priorityIndex.present
          ? data.priorityIndex.value
          : this.priorityIndex,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TaskRow(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueDate: $dueDate, ')
          ..write('priorityIndex: $priorityIndex, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    subjectId,
    title,
    description,
    dueDate,
    priorityIndex,
    isCompleted,
    createdAt,
    deletedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TaskRow &&
          other.id == this.id &&
          other.subjectId == this.subjectId &&
          other.title == this.title &&
          other.description == this.description &&
          other.dueDate == this.dueDate &&
          other.priorityIndex == this.priorityIndex &&
          other.isCompleted == this.isCompleted &&
          other.createdAt == this.createdAt &&
          other.deletedAt == this.deletedAt);
}

class AcademicTasksCompanion extends UpdateCompanion<TaskRow> {
  final Value<int> id;
  final Value<String> subjectId;
  final Value<String> title;
  final Value<String?> description;
  final Value<DateTime?> dueDate;
  final Value<int> priorityIndex;
  final Value<bool> isCompleted;
  final Value<DateTime> createdAt;
  final Value<DateTime?> deletedAt;
  const AcademicTasksCompanion({
    this.id = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.dueDate = const Value.absent(),
    this.priorityIndex = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  });
  AcademicTasksCompanion.insert({
    this.id = const Value.absent(),
    required String subjectId,
    required String title,
    this.description = const Value.absent(),
    this.dueDate = const Value.absent(),
    required int priorityIndex,
    this.isCompleted = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
  }) : subjectId = Value(subjectId),
       title = Value(title),
       priorityIndex = Value(priorityIndex);
  static Insertable<TaskRow> custom({
    Expression<int>? id,
    Expression<String>? subjectId,
    Expression<String>? title,
    Expression<String>? description,
    Expression<DateTime>? dueDate,
    Expression<int>? priorityIndex,
    Expression<bool>? isCompleted,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? deletedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (subjectId != null) 'subject_id': subjectId,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (dueDate != null) 'due_date': dueDate,
      if (priorityIndex != null) 'priority_index': priorityIndex,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (createdAt != null) 'created_at': createdAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
    });
  }

  AcademicTasksCompanion copyWith({
    Value<int>? id,
    Value<String>? subjectId,
    Value<String>? title,
    Value<String?>? description,
    Value<DateTime?>? dueDate,
    Value<int>? priorityIndex,
    Value<bool>? isCompleted,
    Value<DateTime>? createdAt,
    Value<DateTime?>? deletedAt,
  }) {
    return AcademicTasksCompanion(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      priorityIndex: priorityIndex ?? this.priorityIndex,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: deletedAt ?? this.deletedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (dueDate.present) {
      map['due_date'] = Variable<DateTime>(dueDate.value);
    }
    if (priorityIndex.present) {
      map['priority_index'] = Variable<int>(priorityIndex.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AcademicTasksCompanion(')
          ..write('id: $id, ')
          ..write('subjectId: $subjectId, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('dueDate: $dueDate, ')
          ..write('priorityIndex: $priorityIndex, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('createdAt: $createdAt, ')
          ..write('deletedAt: $deletedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SubjectsTable subjects = $SubjectsTable(this);
  late final $ScheduleEntriesTable scheduleEntries = $ScheduleEntriesTable(
    this,
  );
  late final $AcademicTasksTable academicTasks = $AcademicTasksTable(this);
  late final SubjectsDao subjectsDao = SubjectsDao(this as AppDatabase);
  late final ScheduleDao scheduleDao = ScheduleDao(this as AppDatabase);
  late final TasksDao tasksDao = TasksDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    subjects,
    scheduleEntries,
    academicTasks,
  ];
}

typedef $$SubjectsTableCreateCompanionBuilder =
    SubjectsCompanion Function({
      required String id,
      required String name,
      required String teacher,
      required String room,
      required int credits,
      required int accentColorValue,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$SubjectsTableUpdateCompanionBuilder =
    SubjectsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> teacher,
      Value<String> room,
      Value<int> credits,
      Value<int> accentColorValue,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$SubjectsTableReferences
    extends BaseReferences<_$AppDatabase, $SubjectsTable, SubjectRow> {
  $$SubjectsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ScheduleEntriesTable, List<ScheduleRow>>
  _scheduleEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.scheduleEntries,
    aliasName: $_aliasNameGenerator(
      db.subjects.id,
      db.scheduleEntries.subjectId,
    ),
  );

  $$ScheduleEntriesTableProcessedTableManager get scheduleEntriesRefs {
    final manager = $$ScheduleEntriesTableTableManager(
      $_db,
      $_db.scheduleEntries,
    ).filter((f) => f.subjectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _scheduleEntriesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$AcademicTasksTable, List<TaskRow>>
  _academicTasksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.academicTasks,
    aliasName: $_aliasNameGenerator(db.subjects.id, db.academicTasks.subjectId),
  );

  $$AcademicTasksTableProcessedTableManager get academicTasksRefs {
    final manager = $$AcademicTasksTableTableManager(
      $_db,
      $_db.academicTasks,
    ).filter((f) => f.subjectId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_academicTasksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$SubjectsTableFilterComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teacher => $composableBuilder(
    column: $table.teacher,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get room => $composableBuilder(
    column: $table.room,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get credits => $composableBuilder(
    column: $table.credits,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get accentColorValue => $composableBuilder(
    column: $table.accentColorValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> scheduleEntriesRefs(
    Expression<bool> Function($$ScheduleEntriesTableFilterComposer f) f,
  ) {
    final $$ScheduleEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scheduleEntries,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScheduleEntriesTableFilterComposer(
            $db: $db,
            $table: $db.scheduleEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> academicTasksRefs(
    Expression<bool> Function($$AcademicTasksTableFilterComposer f) f,
  ) {
    final $$AcademicTasksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.academicTasks,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AcademicTasksTableFilterComposer(
            $db: $db,
            $table: $db.academicTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SubjectsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teacher => $composableBuilder(
    column: $table.teacher,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get room => $composableBuilder(
    column: $table.room,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get credits => $composableBuilder(
    column: $table.credits,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get accentColorValue => $composableBuilder(
    column: $table.accentColorValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubjectsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubjectsTable> {
  $$SubjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get teacher =>
      $composableBuilder(column: $table.teacher, builder: (column) => column);

  GeneratedColumn<String> get room =>
      $composableBuilder(column: $table.room, builder: (column) => column);

  GeneratedColumn<int> get credits =>
      $composableBuilder(column: $table.credits, builder: (column) => column);

  GeneratedColumn<int> get accentColorValue => $composableBuilder(
    column: $table.accentColorValue,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> scheduleEntriesRefs<T extends Object>(
    Expression<T> Function($$ScheduleEntriesTableAnnotationComposer a) f,
  ) {
    final $$ScheduleEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.scheduleEntries,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScheduleEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.scheduleEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> academicTasksRefs<T extends Object>(
    Expression<T> Function($$AcademicTasksTableAnnotationComposer a) f,
  ) {
    final $$AcademicTasksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.academicTasks,
      getReferencedColumn: (t) => t.subjectId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$AcademicTasksTableAnnotationComposer(
            $db: $db,
            $table: $db.academicTasks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$SubjectsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubjectsTable,
          SubjectRow,
          $$SubjectsTableFilterComposer,
          $$SubjectsTableOrderingComposer,
          $$SubjectsTableAnnotationComposer,
          $$SubjectsTableCreateCompanionBuilder,
          $$SubjectsTableUpdateCompanionBuilder,
          (SubjectRow, $$SubjectsTableReferences),
          SubjectRow,
          PrefetchHooks Function({
            bool scheduleEntriesRefs,
            bool academicTasksRefs,
          })
        > {
  $$SubjectsTableTableManager(_$AppDatabase db, $SubjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> teacher = const Value.absent(),
                Value<String> room = const Value.absent(),
                Value<int> credits = const Value.absent(),
                Value<int> accentColorValue = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubjectsCompanion(
                id: id,
                name: name,
                teacher: teacher,
                room: room,
                credits: credits,
                accentColorValue: accentColorValue,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String teacher,
                required String room,
                required int credits,
                required int accentColorValue,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubjectsCompanion.insert(
                id: id,
                name: name,
                teacher: teacher,
                room: room,
                credits: credits,
                accentColorValue: accentColorValue,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$SubjectsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({scheduleEntriesRefs = false, academicTasksRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (scheduleEntriesRefs) db.scheduleEntries,
                    if (academicTasksRefs) db.academicTasks,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (scheduleEntriesRefs)
                        await $_getPrefetchedData<
                          SubjectRow,
                          $SubjectsTable,
                          ScheduleRow
                        >(
                          currentTable: table,
                          referencedTable: $$SubjectsTableReferences
                              ._scheduleEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SubjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).scheduleEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.subjectId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (academicTasksRefs)
                        await $_getPrefetchedData<
                          SubjectRow,
                          $SubjectsTable,
                          TaskRow
                        >(
                          currentTable: table,
                          referencedTable: $$SubjectsTableReferences
                              ._academicTasksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$SubjectsTableReferences(
                                db,
                                table,
                                p0,
                              ).academicTasksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.subjectId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$SubjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SubjectsTable,
      SubjectRow,
      $$SubjectsTableFilterComposer,
      $$SubjectsTableOrderingComposer,
      $$SubjectsTableAnnotationComposer,
      $$SubjectsTableCreateCompanionBuilder,
      $$SubjectsTableUpdateCompanionBuilder,
      (SubjectRow, $$SubjectsTableReferences),
      SubjectRow,
      PrefetchHooks Function({bool scheduleEntriesRefs, bool academicTasksRefs})
    >;
typedef $$ScheduleEntriesTableCreateCompanionBuilder =
    ScheduleEntriesCompanion Function({
      Value<int> id,
      required String subjectId,
      required int weekdayIndex,
      required int startsAtMinute,
      required int endsAtMinute,
      required String location,
      Value<DateTime> createdAt,
    });
typedef $$ScheduleEntriesTableUpdateCompanionBuilder =
    ScheduleEntriesCompanion Function({
      Value<int> id,
      Value<String> subjectId,
      Value<int> weekdayIndex,
      Value<int> startsAtMinute,
      Value<int> endsAtMinute,
      Value<String> location,
      Value<DateTime> createdAt,
    });

final class $$ScheduleEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $ScheduleEntriesTable, ScheduleRow> {
  $$ScheduleEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SubjectsTable _subjectIdTable(_$AppDatabase db) =>
      db.subjects.createAlias(
        $_aliasNameGenerator(db.scheduleEntries.subjectId, db.subjects.id),
      );

  $$SubjectsTableProcessedTableManager get subjectId {
    final $_column = $_itemColumn<String>('subject_id')!;

    final manager = $$SubjectsTableTableManager(
      $_db,
      $_db.subjects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subjectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ScheduleEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $ScheduleEntriesTable> {
  $$ScheduleEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get weekdayIndex => $composableBuilder(
    column: $table.weekdayIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startsAtMinute => $composableBuilder(
    column: $table.startsAtMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endsAtMinute => $composableBuilder(
    column: $table.endsAtMinute,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SubjectsTableFilterComposer get subjectId {
    final $$SubjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableFilterComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduleEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $ScheduleEntriesTable> {
  $$ScheduleEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get weekdayIndex => $composableBuilder(
    column: $table.weekdayIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startsAtMinute => $composableBuilder(
    column: $table.startsAtMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endsAtMinute => $composableBuilder(
    column: $table.endsAtMinute,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get location => $composableBuilder(
    column: $table.location,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SubjectsTableOrderingComposer get subjectId {
    final $$SubjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableOrderingComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduleEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScheduleEntriesTable> {
  $$ScheduleEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get weekdayIndex => $composableBuilder(
    column: $table.weekdayIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get startsAtMinute => $composableBuilder(
    column: $table.startsAtMinute,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endsAtMinute => $composableBuilder(
    column: $table.endsAtMinute,
    builder: (column) => column,
  );

  GeneratedColumn<String> get location =>
      $composableBuilder(column: $table.location, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SubjectsTableAnnotationComposer get subjectId {
    final $$SubjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ScheduleEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScheduleEntriesTable,
          ScheduleRow,
          $$ScheduleEntriesTableFilterComposer,
          $$ScheduleEntriesTableOrderingComposer,
          $$ScheduleEntriesTableAnnotationComposer,
          $$ScheduleEntriesTableCreateCompanionBuilder,
          $$ScheduleEntriesTableUpdateCompanionBuilder,
          (ScheduleRow, $$ScheduleEntriesTableReferences),
          ScheduleRow,
          PrefetchHooks Function({bool subjectId})
        > {
  $$ScheduleEntriesTableTableManager(
    _$AppDatabase db,
    $ScheduleEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScheduleEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScheduleEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScheduleEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> subjectId = const Value.absent(),
                Value<int> weekdayIndex = const Value.absent(),
                Value<int> startsAtMinute = const Value.absent(),
                Value<int> endsAtMinute = const Value.absent(),
                Value<String> location = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ScheduleEntriesCompanion(
                id: id,
                subjectId: subjectId,
                weekdayIndex: weekdayIndex,
                startsAtMinute: startsAtMinute,
                endsAtMinute: endsAtMinute,
                location: location,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String subjectId,
                required int weekdayIndex,
                required int startsAtMinute,
                required int endsAtMinute,
                required String location,
                Value<DateTime> createdAt = const Value.absent(),
              }) => ScheduleEntriesCompanion.insert(
                id: id,
                subjectId: subjectId,
                weekdayIndex: weekdayIndex,
                startsAtMinute: startsAtMinute,
                endsAtMinute: endsAtMinute,
                location: location,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ScheduleEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({subjectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (subjectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.subjectId,
                                referencedTable:
                                    $$ScheduleEntriesTableReferences
                                        ._subjectIdTable(db),
                                referencedColumn:
                                    $$ScheduleEntriesTableReferences
                                        ._subjectIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ScheduleEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScheduleEntriesTable,
      ScheduleRow,
      $$ScheduleEntriesTableFilterComposer,
      $$ScheduleEntriesTableOrderingComposer,
      $$ScheduleEntriesTableAnnotationComposer,
      $$ScheduleEntriesTableCreateCompanionBuilder,
      $$ScheduleEntriesTableUpdateCompanionBuilder,
      (ScheduleRow, $$ScheduleEntriesTableReferences),
      ScheduleRow,
      PrefetchHooks Function({bool subjectId})
    >;
typedef $$AcademicTasksTableCreateCompanionBuilder =
    AcademicTasksCompanion Function({
      Value<int> id,
      required String subjectId,
      required String title,
      Value<String?> description,
      Value<DateTime?> dueDate,
      required int priorityIndex,
      Value<bool> isCompleted,
      Value<DateTime> createdAt,
      Value<DateTime?> deletedAt,
    });
typedef $$AcademicTasksTableUpdateCompanionBuilder =
    AcademicTasksCompanion Function({
      Value<int> id,
      Value<String> subjectId,
      Value<String> title,
      Value<String?> description,
      Value<DateTime?> dueDate,
      Value<int> priorityIndex,
      Value<bool> isCompleted,
      Value<DateTime> createdAt,
      Value<DateTime?> deletedAt,
    });

final class $$AcademicTasksTableReferences
    extends BaseReferences<_$AppDatabase, $AcademicTasksTable, TaskRow> {
  $$AcademicTasksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $SubjectsTable _subjectIdTable(_$AppDatabase db) =>
      db.subjects.createAlias(
        $_aliasNameGenerator(db.academicTasks.subjectId, db.subjects.id),
      );

  $$SubjectsTableProcessedTableManager get subjectId {
    final $_column = $_itemColumn<String>('subject_id')!;

    final manager = $$SubjectsTableTableManager(
      $_db,
      $_db.subjects,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_subjectIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$AcademicTasksTableFilterComposer
    extends Composer<_$AppDatabase, $AcademicTasksTable> {
  $$AcademicTasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get priorityIndex => $composableBuilder(
    column: $table.priorityIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$SubjectsTableFilterComposer get subjectId {
    final $$SubjectsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableFilterComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AcademicTasksTableOrderingComposer
    extends Composer<_$AppDatabase, $AcademicTasksTable> {
  $$AcademicTasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueDate => $composableBuilder(
    column: $table.dueDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get priorityIndex => $composableBuilder(
    column: $table.priorityIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$SubjectsTableOrderingComposer get subjectId {
    final $$SubjectsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableOrderingComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AcademicTasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $AcademicTasksTable> {
  $$AcademicTasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueDate =>
      $composableBuilder(column: $table.dueDate, builder: (column) => column);

  GeneratedColumn<int> get priorityIndex => $composableBuilder(
    column: $table.priorityIndex,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  $$SubjectsTableAnnotationComposer get subjectId {
    final $$SubjectsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.subjectId,
      referencedTable: $db.subjects,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$SubjectsTableAnnotationComposer(
            $db: $db,
            $table: $db.subjects,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$AcademicTasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AcademicTasksTable,
          TaskRow,
          $$AcademicTasksTableFilterComposer,
          $$AcademicTasksTableOrderingComposer,
          $$AcademicTasksTableAnnotationComposer,
          $$AcademicTasksTableCreateCompanionBuilder,
          $$AcademicTasksTableUpdateCompanionBuilder,
          (TaskRow, $$AcademicTasksTableReferences),
          TaskRow,
          PrefetchHooks Function({bool subjectId})
        > {
  $$AcademicTasksTableTableManager(_$AppDatabase db, $AcademicTasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AcademicTasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AcademicTasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AcademicTasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> subjectId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                Value<int> priorityIndex = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => AcademicTasksCompanion(
                id: id,
                subjectId: subjectId,
                title: title,
                description: description,
                dueDate: dueDate,
                priorityIndex: priorityIndex,
                isCompleted: isCompleted,
                createdAt: createdAt,
                deletedAt: deletedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String subjectId,
                required String title,
                Value<String?> description = const Value.absent(),
                Value<DateTime?> dueDate = const Value.absent(),
                required int priorityIndex,
                Value<bool> isCompleted = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
              }) => AcademicTasksCompanion.insert(
                id: id,
                subjectId: subjectId,
                title: title,
                description: description,
                dueDate: dueDate,
                priorityIndex: priorityIndex,
                isCompleted: isCompleted,
                createdAt: createdAt,
                deletedAt: deletedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$AcademicTasksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({subjectId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (subjectId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.subjectId,
                                referencedTable: $$AcademicTasksTableReferences
                                    ._subjectIdTable(db),
                                referencedColumn: $$AcademicTasksTableReferences
                                    ._subjectIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$AcademicTasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AcademicTasksTable,
      TaskRow,
      $$AcademicTasksTableFilterComposer,
      $$AcademicTasksTableOrderingComposer,
      $$AcademicTasksTableAnnotationComposer,
      $$AcademicTasksTableCreateCompanionBuilder,
      $$AcademicTasksTableUpdateCompanionBuilder,
      (TaskRow, $$AcademicTasksTableReferences),
      TaskRow,
      PrefetchHooks Function({bool subjectId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SubjectsTableTableManager get subjects =>
      $$SubjectsTableTableManager(_db, _db.subjects);
  $$ScheduleEntriesTableTableManager get scheduleEntries =>
      $$ScheduleEntriesTableTableManager(_db, _db.scheduleEntries);
  $$AcademicTasksTableTableManager get academicTasks =>
      $$AcademicTasksTableTableManager(_db, _db.academicTasks);
}

mixin _$SubjectsDaoMixin on DatabaseAccessor<AppDatabase> {
  $SubjectsTable get subjects => attachedDatabase.subjects;
  SubjectsDaoManager get managers => SubjectsDaoManager(this);
}

class SubjectsDaoManager {
  final _$SubjectsDaoMixin _db;
  SubjectsDaoManager(this._db);
  $$SubjectsTableTableManager get subjects =>
      $$SubjectsTableTableManager(_db.attachedDatabase, _db.subjects);
}

mixin _$ScheduleDaoMixin on DatabaseAccessor<AppDatabase> {
  $SubjectsTable get subjects => attachedDatabase.subjects;
  $ScheduleEntriesTable get scheduleEntries => attachedDatabase.scheduleEntries;
  ScheduleDaoManager get managers => ScheduleDaoManager(this);
}

class ScheduleDaoManager {
  final _$ScheduleDaoMixin _db;
  ScheduleDaoManager(this._db);
  $$SubjectsTableTableManager get subjects =>
      $$SubjectsTableTableManager(_db.attachedDatabase, _db.subjects);
  $$ScheduleEntriesTableTableManager get scheduleEntries =>
      $$ScheduleEntriesTableTableManager(
        _db.attachedDatabase,
        _db.scheduleEntries,
      );
}

mixin _$TasksDaoMixin on DatabaseAccessor<AppDatabase> {
  $SubjectsTable get subjects => attachedDatabase.subjects;
  $AcademicTasksTable get academicTasks => attachedDatabase.academicTasks;
  TasksDaoManager get managers => TasksDaoManager(this);
}

class TasksDaoManager {
  final _$TasksDaoMixin _db;
  TasksDaoManager(this._db);
  $$SubjectsTableTableManager get subjects =>
      $$SubjectsTableTableManager(_db.attachedDatabase, _db.subjects);
  $$AcademicTasksTableTableManager get academicTasks =>
      $$AcademicTasksTableTableManager(_db.attachedDatabase, _db.academicTasks);
}
