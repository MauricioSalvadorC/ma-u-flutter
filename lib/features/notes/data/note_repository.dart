import 'package:drift/drift.dart';

import '../../../data/database/app_database.dart';
import '../domain/academic_note.dart';

class NoteRepository {
  const NoteRepository(this._database);

  final AppDatabase _database;

  Stream<List<AcademicNote>> watchNotes() {
    return _database.notesDao.watchAll().map(
      (rows) => rows.map(_toDomain).toList(),
    );
  }

  Stream<List<AcademicNote>> watchDeletedNotes() {
    return _database.notesDao.watchDeleted().map(
      (rows) => rows.map(_toDomain).toList(),
    );
  }

  Future<int> saveNote(AcademicNote note) async {
    final now = DateTime.now();
    final normalized = note.copyWith(
      createdAt: note.id == null ? now : note.createdAt,
      updatedAt: now,
    );

    if (normalized.id != null) {
      await _database.notesDao.updateNote(_toCompanion(normalized));
      return normalized.id!;
    }

    return _database.notesDao.insertNote(_toCompanion(normalized));
  }

  Future<bool> moveToTrash(int id) {
    return _database.notesDao.moveToTrash(id);
  }

  Future<bool> restoreNote(int id) {
    return _database.notesDao.restoreNote(id);
  }

  AcademicNote _toDomain(NoteRow row) {
    return AcademicNote(
      id: row.id,
      subjectId: row.subjectId,
      title: row.title,
      content: row.content,
      tags: _decodeTags(row.tags),
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
      deletedAt: row.deletedAt,
    );
  }

  AcademicNotesCompanion _toCompanion(AcademicNote note) {
    return AcademicNotesCompanion(
      id: note.id == null ? const Value.absent() : Value(note.id!),
      subjectId: Value(note.subjectId),
      title: Value(note.title),
      content: Value(note.content),
      tags: Value(_encodeTags(note.tags)),
      createdAt: Value(note.createdAt),
      updatedAt: Value(note.updatedAt),
      deletedAt: Value(note.deletedAt),
    );
  }

  List<String> _decodeTags(String? value) {
    if (value == null || value.trim().isEmpty) {
      return const [];
    }

    return value
        .split('|')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();
  }

  String? _encodeTags(List<String> tags) {
    final normalized = tags
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();
    if (normalized.isEmpty) {
      return null;
    }

    return normalized.join('|');
  }
}
