import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part '../daos/schedule_dao.dart';
part '../daos/subjects_dao.dart';
part '../daos/tasks_dao.dart';
part 'app_database.g.dart';

@DataClassName('SubjectRow')
class Subjects extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get teacher => text()();
  TextColumn get room => text()();
  IntColumn get credits => integer()();
  IntColumn get accentColorValue => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ScheduleRow')
class ScheduleEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get subjectId => text().references(Subjects, #id)();
  IntColumn get weekdayIndex => integer()();
  IntColumn get startsAtMinute => integer()();
  IntColumn get endsAtMinute => integer()();
  TextColumn get location => text()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}

@DataClassName('TaskRow')
class AcademicTasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get subjectId => text().references(Subjects, #id)();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  IntColumn get priorityIndex => integer()();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

@DriftDatabase(
  tables: [Subjects, ScheduleEntries, AcademicTasks],
  daos: [SubjectsDao, ScheduleDao, TasksDao],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'ma_u.sqlite'));

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.createTable(academicTasks);
        }
        if (from < 3) {
          await migrator.addColumn(academicTasks, academicTasks.deletedAt);
        }
      },
    );
  }
}
