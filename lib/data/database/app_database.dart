import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part '../daos/academic_goals_dao.dart';
part '../daos/expenses_dao.dart';
part '../daos/schedule_dao.dart';
part '../daos/semesters_dao.dart';
part '../daos/settings_dao.dart';
part '../daos/study_sessions_dao.dart';
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
  DateTimeColumn get deletedAt => dateTime().nullable()();

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
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

@DataClassName('TaskRow')
class AcademicTasks extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get subjectId => text().references(Subjects, #id)();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  IntColumn get priorityIndex => integer()();
  BoolColumn get reminderEnabled =>
      boolean().withDefault(const Constant(false))();
  IntColumn get reminderMinutesBefore =>
      integer().withDefault(const Constant(30))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

@DataClassName('StudySessionRow')
class StudySessions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get subjectId => text().references(Subjects, #id)();
  TextColumn get title => text()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get startsAt => dateTime().nullable()();
  IntColumn get durationMinutes => integer()();
  IntColumn get focusLevelIndex => integer()();
  BoolColumn get reminderEnabled =>
      boolean().withDefault(const Constant(false))();
  IntColumn get reminderMinutesBefore =>
      integer().withDefault(const Constant(30))();
  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

@DataClassName('SemesterRow')
class Semesters extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  IntColumn get year => integer()();
  IntColumn get termIndex => integer()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('SemesterCourseRow')
class SemesterCourses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get semesterId => text().references(Semesters, #id)();
  TextColumn get name => text()();
  IntColumn get credits => integer()();
  RealColumn get finalGrade => real()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

@DataClassName('AppSettingRow')
class AppSettingsEntries extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column<Object>> get primaryKey => {key};
}

@DataClassName('AcademicGoalRow')
class AcademicGoals extends Table {
  TextColumn get id => text()();
  RealColumn get targetAverage => real()();
  IntColumn get plannedCredits => integer()();
  RealColumn get expectedAverage => real()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DataClassName('ExpenseRow')
class Expenses extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  IntColumn get amountCents => integer()();
  IntColumn get categoryIndex => integer()();
  DateTimeColumn get spentAt => dateTime()();
  TextColumn get note => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get deletedAt => dateTime().nullable()();
}

@DriftDatabase(
  tables: [
    Subjects,
    ScheduleEntries,
    AcademicTasks,
    StudySessions,
    Semesters,
    SemesterCourses,
    AppSettingsEntries,
    AcademicGoals,
    Expenses,
  ],
  daos: [
    SubjectsDao,
    ScheduleDao,
    TasksDao,
    StudySessionsDao,
    SemestersDao,
    SettingsDao,
    AcademicGoalsDao,
    ExpensesDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? driftDatabase(name: 'ma_u.sqlite'));

  @override
  int get schemaVersion => 9;

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
        if (from < 4) {
          await migrator.addColumn(subjects, subjects.deletedAt);
          await migrator.addColumn(scheduleEntries, scheduleEntries.deletedAt);
        }
        if (from < 5) {
          await migrator.createTable(studySessions);
        }
        if (from < 6) {
          await migrator.createTable(semesters);
          await migrator.createTable(semesterCourses);
        }
        if (from < 7) {
          await migrator.createTable(appSettingsEntries);
          await migrator.createTable(academicGoals);
        }
        if (from < 8) {
          await migrator.createTable(expenses);
        }
        if (from < 9) {
          await migrator.addColumn(
            academicTasks,
            academicTasks.reminderEnabled,
          );
          await migrator.addColumn(
            academicTasks,
            academicTasks.reminderMinutesBefore,
          );
          await migrator.addColumn(
            studySessions,
            studySessions.reminderEnabled,
          );
          await migrator.addColumn(
            studySessions,
            studySessions.reminderMinutesBefore,
          );
        }
      },
    );
  }
}
