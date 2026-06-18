import 'package:flutter/material.dart';

import '../../../core/formatters/app_date_formatter.dart';
import '../../../core/formatters/money_formatter.dart';
import '../../../data/database/app_database_provider.dart';
import '../../academic_record/data/academic_record_repository.dart';
import '../../expenses/data/expense_repository.dart';
import '../../expenses/domain/university_expense.dart';
import '../../notes/data/note_repository.dart';
import '../../notes/domain/academic_note.dart';
import '../../schedule/data/academic_seed_service.dart';
import '../../schedule/data/schedule_repository.dart';
import '../../schedule/domain/class_session.dart';
import '../../study/data/study_session_repository.dart';
import '../../study/domain/study_session.dart';
import '../../subjects/data/subject_repository.dart';
import '../../subjects/domain/subject.dart';
import '../../tasks/data/task_repository.dart';
import '../../tasks/domain/academic_task.dart';

class TrashScreen extends StatefulWidget {
  const TrashScreen({super.key});

  @override
  State<TrashScreen> createState() => _TrashScreenState();
}

class _TrashScreenState extends State<TrashScreen> {
  late final SubjectRepository _subjectRepository;
  late final ScheduleRepository _scheduleRepository;
  late final TaskRepository _taskRepository;
  late final StudySessionRepository _studyRepository;
  late final ExpenseRepository _expenseRepository;
  late final AcademicRecordRepository _recordRepository;
  late final NoteRepository _noteRepository;
  late final Future<void> _seedFuture;
  _TrashFilter _filter = _TrashFilter.all;
  String _query = '';

  @override
  void initState() {
    super.initState();
    final database = AppDatabaseProvider.instance;
    _subjectRepository = SubjectRepository(database);
    _scheduleRepository = ScheduleRepository(database);
    _taskRepository = TaskRepository(database);
    _studyRepository = StudySessionRepository(database);
    _expenseRepository = ExpenseRepository(database);
    _recordRepository = AcademicRecordRepository(database);
    _noteRepository = NoteRepository(database);
    _seedFuture = AcademicSeedService(
      subjectRepository: _subjectRepository,
      scheduleRepository: _scheduleRepository,
    ).seedIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _seedFuture,
      builder: (context, seedSnapshot) {
        if (seedSnapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return StreamBuilder<List<Subject>>(
          stream: _subjectRepository.watchSubjects(),
          builder: (context, subjectSnapshot) {
            final subjects = subjectSnapshot.data ?? const <Subject>[];
            return StreamBuilder<List<AcademicTask>>(
              stream: _taskRepository.watchDeletedTasks(),
              builder: (context, taskSnapshot) {
                final tasks = taskSnapshot.data ?? const <AcademicTask>[];
                return StreamBuilder<List<Subject>>(
                  stream: _subjectRepository.watchDeletedSubjects(),
                  builder: (context, deletedSubjectSnapshot) {
                    final deletedSubjects =
                        deletedSubjectSnapshot.data ?? const <Subject>[];
                    return StreamBuilder<List<ClassSession>>(
                      stream: _scheduleRepository.watchDeletedSessions(),
                      builder: (context, deletedSessionSnapshot) {
                        final deletedSessions =
                            deletedSessionSnapshot.data ??
                            const <ClassSession>[];
                        return StreamBuilder<List<StudySession>>(
                          stream: _studyRepository.watchDeletedSessions(),
                          builder: (context, deletedStudySnapshot) {
                            final deletedStudySessions =
                                deletedStudySnapshot.data ??
                                const <StudySession>[];
                            return StreamBuilder<List<UniversityExpense>>(
                              stream: _expenseRepository.watchDeletedExpenses(),
                              builder: (context, deletedExpenseSnapshot) {
                                final deletedExpenses =
                                    deletedExpenseSnapshot.data ??
                                    const <UniversityExpense>[];
                                return StreamBuilder<List<AcademicNote>>(
                                  stream: _noteRepository.watchDeletedNotes(),
                                  builder: (context, deletedNoteSnapshot) {
                                    final deletedNotes =
                                        deletedNoteSnapshot.data ??
                                        const <AcademicNote>[];
                                    return StreamBuilder(
                                      stream: _recordRepository
                                          .watchDeletedSemesters(),
                                      builder: (context, semesterSnapshot) {
                                        final deletedSemesters =
                                            semesterSnapshot.data ?? const [];
                                        return StreamBuilder(
                                          stream: _recordRepository
                                              .watchDeletedCourses(),
                                          builder: (context, courseSnapshot) {
                                            final deletedCourses =
                                                courseSnapshot.data ?? const [];
                                            final items = _buildItems(
                                              subjects: subjects,
                                              tasks: tasks,
                                              deletedSubjects: deletedSubjects,
                                              deletedSessions: deletedSessions,
                                              deletedStudySessions:
                                                  deletedStudySessions,
                                              deletedExpenses: deletedExpenses,
                                              deletedNotes: deletedNotes,
                                              deletedSemesters:
                                                  deletedSemesters,
                                              deletedCourses: deletedCourses,
                                            );

                                            return _TrashView(
                                              items: items,
                                              filter: _filter,
                                              query: _query,
                                              onFilterChanged: (filter) {
                                                setState(() {
                                                  _filter = filter;
                                                });
                                              },
                                              onQueryChanged: (query) {
                                                setState(() {
                                                  _query = query;
                                                });
                                              },
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  List<_TrashItemData> _buildItems({
    required List<Subject> subjects,
    required List<AcademicTask> tasks,
    required List<Subject> deletedSubjects,
    required List<ClassSession> deletedSessions,
    required List<StudySession> deletedStudySessions,
    required List<UniversityExpense> deletedExpenses,
    required List<AcademicNote> deletedNotes,
    required List<dynamic> deletedSemesters,
    required List<dynamic> deletedCourses,
  }) {
    final items = <_TrashItemData>[];

    for (final subject in deletedSubjects) {
      items.add(
        _TrashItemData(
          type: _TrashFilter.subjects,
          icon: Icons.menu_book_outlined,
          title: subject.name,
          subtitle: _deletedSubtitle('Materia', subject.deletedAt),
          searchText: subject.name,
          onRestore: () => _subjectRepository.restoreSubject(subject.id),
        ),
      );
    }

    for (final session in deletedSessions) {
      final subject = _subjectFor(subjects, session.subjectId);
      items.add(
        _TrashItemData(
          type: _TrashFilter.schedule,
          icon: Icons.calendar_month_outlined,
          title: subject.name,
          subtitle: _deletedSubtitle(
            'Clase ${session.timeRange}',
            session.deletedAt,
          ),
          searchText: '${subject.name} ${session.location}',
          onRestore: () {
            final id = session.id;
            return id == null
                ? Future<void>.value()
                : _scheduleRepository.restoreSession(id);
          },
        ),
      );
    }

    for (final studySession in deletedStudySessions) {
      final subject = _subjectFor(subjects, studySession.subjectId);
      items.add(
        _TrashItemData(
          type: _TrashFilter.study,
          icon: Icons.psychology_alt_outlined,
          title: studySession.title,
          subtitle: _deletedSubtitle(subject.name, studySession.deletedAt),
          searchText:
              '${studySession.title} ${studySession.notes} ${subject.name}',
          onRestore: () {
            final id = studySession.id;
            return id == null
                ? Future<void>.value()
                : _studyRepository.restoreSession(id);
          },
        ),
      );
    }

    for (final task in tasks) {
      final subject = _subjectFor(subjects, task.subjectId);
      items.add(
        _TrashItemData(
          type: _TrashFilter.tasks,
          icon: Icons.task_alt_outlined,
          title: task.title,
          subtitle: _deletedSubtitle(subject.name, task.deletedAt),
          searchText: '${task.title} ${task.description} ${subject.name}',
          onRestore: () {
            final id = task.id;
            return id == null
                ? Future<void>.value()
                : _taskRepository.restoreTask(id);
          },
        ),
      );
    }

    for (final expense in deletedExpenses) {
      items.add(
        _TrashItemData(
          type: _TrashFilter.expenses,
          icon: Icons.account_balance_wallet_outlined,
          title: expense.title,
          subtitle: _deletedSubtitle(
            MoneyFormatter.pesos(expense.amountCents),
            expense.deletedAt,
          ),
          searchText:
              '${expense.title} ${expense.note} ${expense.category.label}',
          onRestore: () {
            final id = expense.id;
            return id == null
                ? Future<void>.value()
                : _expenseRepository.restoreExpense(id);
          },
        ),
      );
    }

    for (final note in deletedNotes) {
      final subject = _subjectForOptional(subjects, note.subjectId);
      items.add(
        _TrashItemData(
          type: _TrashFilter.notes,
          icon: Icons.edit_note_outlined,
          title: note.title,
          subtitle: _deletedSubtitle(
            subject?.name ?? 'Nota global',
            note.deletedAt,
          ),
          searchText:
              '${note.title} ${note.content} ${note.tags.join(' ')} ${subject?.name ?? ''}',
          onRestore: () {
            final id = note.id;
            return id == null
                ? Future<void>.value()
                : _noteRepository.restoreNote(id);
          },
        ),
      );
    }

    for (final semester in deletedSemesters) {
      items.add(
        _TrashItemData(
          type: _TrashFilter.record,
          icon: Icons.school_outlined,
          title: semester.name as String,
          subtitle: _deletedSubtitle(
            'Semestre',
            semester.deletedAt as DateTime?,
          ),
          searchText: '${semester.name} ${semester.year}',
          onRestore: () =>
              _recordRepository.restoreSemester(semester.id as String),
        ),
      );
    }

    for (final course in deletedCourses) {
      items.add(
        _TrashItemData(
          type: _TrashFilter.record,
          icon: Icons.grade_outlined,
          title: course.name as String,
          subtitle: _deletedSubtitle(
            '${course.credits} cr - ${(course.finalGrade as double).toStringAsFixed(2)}',
            course.deletedAt as DateTime?,
          ),
          searchText: '${course.name} ${course.credits} ${course.finalGrade}',
          onRestore: () {
            final id = course.id as int?;
            return id == null
                ? Future<void>.value()
                : _recordRepository.restoreCourse(id);
          },
        ),
      );
    }

    return items;
  }

  Subject _subjectFor(List<Subject> subjects, String id) {
    return subjects.firstWhere(
      (subject) => subject.id == id,
      orElse: () => const Subject(
        id: 'unknown',
        name: 'Materia',
        teacher: '',
        room: '',
        credits: 0,
        accentColorValue: 0xFF64748B,
      ),
    );
  }

  Subject? _subjectForOptional(List<Subject> subjects, String? id) {
    if (id == null) {
      return null;
    }

    for (final subject in subjects) {
      if (subject.id == id) {
        return subject;
      }
    }

    return null;
  }

  String _deletedSubtitle(String base, DateTime? deletedAt) {
    if (deletedAt == null) {
      return base;
    }
    return '$base - ${AppDateFormatter.dateTime(deletedAt)}';
  }
}

class _TrashView extends StatelessWidget {
  const _TrashView({
    required this.items,
    required this.filter,
    required this.query,
    required this.onFilterChanged,
    required this.onQueryChanged,
  });

  final List<_TrashItemData> items;
  final _TrashFilter filter;
  final String query;
  final ValueChanged<_TrashFilter> onFilterChanged;
  final ValueChanged<String> onQueryChanged;

  @override
  Widget build(BuildContext context) {
    final filteredItems = items.where(_matches).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Papelera')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _TrashHeader(total: items.length),
            const SizedBox(height: 16),
            TextField(
              onChanged: onQueryChanged,
              decoration: const InputDecoration(
                hintText: 'Buscar en papelera',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 12),
            _TrashFilterBar(
              selected: filter,
              items: items,
              onSelected: onFilterChanged,
            ),
            const SizedBox(height: 16),
            if (filteredItems.isEmpty)
              const _EmptyTrashCard()
            else
              for (final item in filteredItems) ...[
                _TrashItemCard(item: item),
                const SizedBox(height: 10),
              ],
          ],
        ),
      ),
    );
  }

  bool _matches(_TrashItemData item) {
    final filterMatches = filter == _TrashFilter.all || item.type == filter;
    final queryText = query.trim().toLowerCase();
    final queryMatches =
        queryText.isEmpty ||
        '${item.title} ${item.subtitle} ${item.searchText}'
            .toLowerCase()
            .contains(queryText);
    return filterMatches && queryMatches;
  }
}

class _TrashHeader extends StatelessWidget {
  const _TrashHeader({required this.total});

  final int total;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.restore_from_trash_outlined,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Recupera informacion',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text('$total elementos disponibles para restaurar.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrashFilterBar extends StatelessWidget {
  const _TrashFilterBar({
    required this.selected,
    required this.items,
    required this.onSelected,
  });

  final _TrashFilter selected;
  final List<_TrashItemData> items;
  final ValueChanged<_TrashFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in _TrashFilter.values) ...[
            ChoiceChip(
              label: Text('${filter.label} (${_count(filter)})'),
              selected: selected == filter,
              onSelected: (_) => onSelected(filter),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  int _count(_TrashFilter filter) {
    if (filter == _TrashFilter.all) {
      return items.length;
    }
    return items.where((item) => item.type == filter).length;
  }
}

class _EmptyTrashCard extends StatelessWidget {
  const _EmptyTrashCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(
              Icons.delete_sweep_outlined,
              color: colorScheme.primary,
              size: 38,
            ),
            const SizedBox(height: 10),
            const Text(
              'Sin resultados',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              'No hay elementos para el filtro o busqueda actual.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _TrashItemCard extends StatelessWidget {
  const _TrashItemCard({required this.item});

  final _TrashItemData item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(item.icon, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            PopupMenuButton<_TrashAction>(
              tooltip: 'Opciones',
              onSelected: (_) => item.onRestore(),
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: _TrashAction.restore,
                  child: Text('Restaurar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TrashItemData {
  const _TrashItemData({
    required this.type,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.searchText,
    required this.onRestore,
  });

  final _TrashFilter type;
  final IconData icon;
  final String title;
  final String subtitle;
  final String searchText;
  final Future<void> Function() onRestore;
}

enum _TrashAction { restore }

enum _TrashFilter {
  all('Todo'),
  subjects('Materias'),
  schedule('Horario'),
  tasks('Tareas'),
  study('Estudio'),
  notes('Apuntes'),
  expenses('Gastos'),
  record('Historial');

  const _TrashFilter(this.label);

  final String label;
}
