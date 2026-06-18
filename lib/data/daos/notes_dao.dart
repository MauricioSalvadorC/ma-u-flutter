part of '../database/app_database.dart';

@DriftAccessor(tables: [AcademicNotes, Subjects])
class NotesDao extends DatabaseAccessor<AppDatabase> with _$NotesDaoMixin {
  NotesDao(super.db);

  Stream<List<NoteRow>> watchAll() {
    return (select(academicNotes)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([
            (table) => OrderingTerm.desc(table.updatedAt),
            (table) => OrderingTerm.desc(table.createdAt),
          ]))
        .watch();
  }

  Stream<List<NoteRow>> watchDeleted() {
    return (select(academicNotes)
          ..where((table) => table.deletedAt.isNotNull())
          ..orderBy([(table) => OrderingTerm.desc(table.deletedAt)]))
        .watch();
  }

  Future<NoteRow?> getById(int id) {
    return (select(
      academicNotes,
    )..where((table) => table.id.equals(id))).getSingleOrNull();
  }

  Future<int> insertNote(AcademicNotesCompanion note) {
    return into(academicNotes).insert(note);
  }

  Future<bool> updateNote(AcademicNotesCompanion note) {
    final id = note.id.value;
    return (update(academicNotes)..where((table) => table.id.equals(id)))
        .write(note)
        .then((rows) => rows > 0);
  }

  Future<bool> moveToTrash(int id) {
    return (update(academicNotes)..where((table) => table.id.equals(id)))
        .write(AcademicNotesCompanion(deletedAt: Value(DateTime.now())))
        .then((rows) => rows > 0);
  }

  Future<bool> restoreNote(int id) {
    return (update(academicNotes)..where((table) => table.id.equals(id)))
        .write(const AcademicNotesCompanion(deletedAt: Value(null)))
        .then((rows) => rows > 0);
  }
}
