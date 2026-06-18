import 'package:flutter/material.dart';

import '../../../core/formatters/app_date_formatter.dart';
import '../../../core/formatters/money_formatter.dart';
import '../../../data/database/app_database_provider.dart';
import '../../academic_record/data/academic_record_repository.dart';
import '../../academic_record/domain/academic_record.dart';
import '../../academic_record/presentation/academic_record_screen.dart';
import '../../expenses/data/expense_repository.dart';
import '../../expenses/domain/university_expense.dart';
import '../../expenses/presentation/expenses_screen.dart';
import '../../notes/data/note_repository.dart';
import '../../notes/domain/academic_note.dart';
import '../../notes/presentation/notes_screen.dart';
import '../../schedule/data/academic_seed_service.dart';
import '../../schedule/data/schedule_repository.dart';
import '../../schedule/domain/class_session.dart';
import '../../schedule/presentation/academic_planner_screen.dart';
import '../../study/data/study_session_repository.dart';
import '../../study/domain/study_session.dart';
import '../../study/presentation/study_agenda_screen.dart';
import '../../subjects/data/subject_repository.dart';
import '../../subjects/domain/subject.dart';
import '../../tasks/data/task_repository.dart';
import '../../tasks/domain/academic_task.dart';
import '../../tasks/presentation/tasks_screen.dart';

class GlobalSearchScreen extends StatefulWidget {
  const GlobalSearchScreen({super.key});

  @override
  State<GlobalSearchScreen> createState() => _GlobalSearchScreenState();
}

class _GlobalSearchScreenState extends State<GlobalSearchScreen> {
  final _queryController = TextEditingController();
  late final SubjectRepository _subjectRepository;
  late final ScheduleRepository _scheduleRepository;
  late final TaskRepository _taskRepository;
  late final StudySessionRepository _studyRepository;
  late final ExpenseRepository _expenseRepository;
  late final AcademicRecordRepository _recordRepository;
  late final NoteRepository _noteRepository;
  late final Future<void> _seedFuture;
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
  void dispose() {
    _queryController.dispose();
    super.dispose();
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
            return StreamBuilder<List<ClassSession>>(
              stream: _scheduleRepository.watchSessions(),
              builder: (context, sessionSnapshot) {
                final sessions = sessionSnapshot.data ?? const <ClassSession>[];
                return StreamBuilder<List<AcademicTask>>(
                  stream: _taskRepository.watchTasks(),
                  builder: (context, taskSnapshot) {
                    final tasks = taskSnapshot.data ?? const <AcademicTask>[];
                    return StreamBuilder<List<StudySession>>(
                      stream: _studyRepository.watchSessions(),
                      builder: (context, studySnapshot) {
                        final studySessions =
                            studySnapshot.data ?? const <StudySession>[];
                        return StreamBuilder<List<UniversityExpense>>(
                          stream: _expenseRepository.watchExpenses(),
                          builder: (context, expenseSnapshot) {
                            final expenses =
                                expenseSnapshot.data ??
                                const <UniversityExpense>[];
                            return StreamBuilder<List<AcademicNote>>(
                              stream: _noteRepository.watchNotes(),
                              builder: (context, noteSnapshot) {
                                final notes =
                                    noteSnapshot.data ?? const <AcademicNote>[];
                                return StreamBuilder<List<SemesterSummary>>(
                                  stream: _recordRepository.watchSummaries(),
                                  builder: (context, recordSnapshot) {
                                    final summaries =
                                        recordSnapshot.data ??
                                        const <SemesterSummary>[];
                                    return _SearchView(
                                      queryController: _queryController,
                                      query: _query,
                                      onQueryChanged: (value) {
                                        setState(() {
                                          _query = value;
                                        });
                                      },
                                      subjects: subjects,
                                      sessions: sessions,
                                      tasks: tasks,
                                      studySessions: studySessions,
                                      expenses: expenses,
                                      notes: notes,
                                      summaries: summaries,
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
}

class _SearchView extends StatelessWidget {
  const _SearchView({
    required this.queryController,
    required this.query,
    required this.onQueryChanged,
    required this.subjects,
    required this.sessions,
    required this.tasks,
    required this.studySessions,
    required this.expenses,
    required this.notes,
    required this.summaries,
  });

  final TextEditingController queryController;
  final String query;
  final ValueChanged<String> onQueryChanged;
  final List<Subject> subjects;
  final List<ClassSession> sessions;
  final List<AcademicTask> tasks;
  final List<StudySession> studySessions;
  final List<UniversityExpense> expenses;
  final List<AcademicNote> notes;
  final List<SemesterSummary> summaries;

  @override
  Widget build(BuildContext context) {
    final normalizedQuery = _normalize(query);
    final results = normalizedQuery.isEmpty
        ? const <_SearchResult>[]
        : _buildResults(context, normalizedQuery);

    return Scaffold(
      appBar: AppBar(title: const Text('Buscar')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            TextField(
              controller: queryController,
              autofocus: true,
              onChanged: onQueryChanged,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Buscar tareas, materias, gastos...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Limpiar',
                        onPressed: () {
                          queryController.clear();
                          onQueryChanged('');
                        },
                        icon: const Icon(Icons.close),
                      ),
              ),
            ),
            const SizedBox(height: 16),
            if (normalizedQuery.isEmpty)
              const _SearchHintCard()
            else if (results.isEmpty)
              const _EmptySearchCard()
            else
              for (final group in _groupResults(results)) ...[
                _SearchGroupTitle(
                  title: group.title,
                  count: group.items.length,
                ),
                const SizedBox(height: 8),
                for (final result in group.items) ...[
                  _SearchResultCard(result: result),
                  const SizedBox(height: 10),
                ],
                const SizedBox(height: 8),
              ],
          ],
        ),
      ),
    );
  }

  List<_SearchResult> _buildResults(BuildContext context, String query) {
    final results = <_SearchResult>[];
    final subjectMap = {for (final subject in subjects) subject.id: subject};

    for (final subject in subjects) {
      final text = '${subject.name} ${subject.teacher} ${subject.room}';
      if (_matches(text, query)) {
        results.add(
          _SearchResult(
            group: 'Materias',
            icon: Icons.menu_book_outlined,
            title: subject.name,
            subtitle: '${subject.teacher} - ${subject.room}',
            color: Color(subject.accentColorValue),
            onTap: () => _open(context, const AcademicPlannerScreen()),
          ),
        );
      }
    }

    for (final session in sessions) {
      final subject = subjectMap[session.subjectId];
      final text =
          '${subject?.name ?? ''} ${session.weekday.label} ${session.location} ${session.timeRange}';
      if (_matches(text, query)) {
        results.add(
          _SearchResult(
            group: 'Horario',
            icon: Icons.calendar_month_outlined,
            title: subject?.name ?? 'Clase',
            subtitle:
                '${session.weekday.label} - ${session.timeRange} - ${session.location}',
            color: const Color(0xFF2563EB),
            onTap: () => _open(context, const AcademicPlannerScreen()),
          ),
        );
      }
    }

    for (final task in tasks) {
      final subject = subjectMap[task.subjectId];
      final text =
          '${task.title} ${task.description} ${task.priority.label} ${subject?.name ?? ''}';
      if (_matches(text, query)) {
        results.add(
          _SearchResult(
            group: 'Tareas',
            icon: Icons.task_alt_outlined,
            title: task.title,
            subtitle:
                '${subject?.name ?? 'Materia'} - ${task.dueDate == null ? 'Sin fecha' : AppDateFormatter.dateWithOptionalTime(task.dueDate!)}',
            color: const Color(0xFF7C3AED),
            onTap: () => _open(context, const TasksScreen()),
          ),
        );
      }
    }

    for (final session in studySessions) {
      final subject = subjectMap[session.subjectId];
      final text =
          '${session.title} ${session.notes} ${session.focusLevel.label} ${subject?.name ?? ''}';
      if (_matches(text, query)) {
        results.add(
          _SearchResult(
            group: 'Estudio',
            icon: Icons.psychology_alt_outlined,
            title: session.title,
            subtitle:
                '${subject?.name ?? 'Materia'} - ${session.durationMinutes} min',
            color: const Color(0xFF0F766E),
            onTap: () => _open(context, const StudyAgendaScreen()),
          ),
        );
      }
    }

    for (final expense in expenses) {
      final text = '${expense.title} ${expense.note} ${expense.category.label}';
      if (_matches(text, query)) {
        results.add(
          _SearchResult(
            group: 'Gastos',
            icon: Icons.account_balance_wallet_outlined,
            title: expense.title,
            subtitle:
                '${expense.category.label} - ${MoneyFormatter.pesos(expense.amountCents)}',
            color: const Color(0xFFDC6B19),
            onTap: () => _open(context, const ExpensesScreen()),
          ),
        );
      }
    }

    for (final note in notes) {
      final subject = subjectMap[note.subjectId];
      final text =
          '${note.title} ${note.content} ${note.tags.join(' ')} ${subject?.name ?? ''}';
      if (_matches(text, query)) {
        results.add(
          _SearchResult(
            group: 'Apuntes',
            icon: Icons.edit_note_outlined,
            title: note.title,
            subtitle:
                '${subject?.name ?? 'Nota global'} - ${AppDateFormatter.date(note.updatedAt)}',
            color: const Color(0xFF0891B2),
            onTap: () => _open(context, const NotesScreen()),
          ),
        );
      }
    }

    for (final summary in summaries) {
      final semesterText =
          '${summary.semester.name} ${summary.semester.year} ${summary.semester.termIndex}';
      if (_matches(semesterText, query)) {
        results.add(
          _SearchResult(
            group: 'Historial',
            icon: Icons.school_outlined,
            title: summary.semester.name,
            subtitle:
                '${summary.credits} creditos - promedio ${summary.average == null ? '--' : summary.average!.toStringAsFixed(2)}',
            color: const Color(0xFF0F766E),
            onTap: () => _open(context, const AcademicRecordScreen()),
          ),
        );
      }

      for (final course in summary.courses) {
        final courseText =
            '${course.name} ${summary.semester.name} ${course.credits} ${course.finalGrade}';
        if (_matches(courseText, query)) {
          results.add(
            _SearchResult(
              group: 'Historial',
              icon: Icons.grade_outlined,
              title: course.name,
              subtitle:
                  '${summary.semester.name} - ${course.credits} cr - ${course.finalGrade.toStringAsFixed(2)}',
              color: const Color(0xFF4F46E5),
              onTap: () => _open(context, const AcademicRecordScreen()),
            ),
          );
        }
      }
    }

    return results.take(30).toList();
  }

  List<_SearchGroup> _groupResults(List<_SearchResult> results) {
    final groups = <_SearchGroup>[];
    for (final result in results) {
      final index = groups.indexWhere((group) => group.title == result.group);
      if (index == -1) {
        groups.add(_SearchGroup(title: result.group, items: [result]));
      } else {
        groups[index].items.add(result);
      }
    }
    return groups;
  }

  bool _matches(String text, String query) {
    return _normalize(text).contains(query);
  }

  String _normalize(String value) {
    return value.toLowerCase().trim();
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }
}

class _SearchResultCard extends StatelessWidget {
  const _SearchResultCard({required this.result});

  final _SearchResult result;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: result.onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: result.color.withAlpha(36),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(result.icon, color: result.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      result.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      result.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.east, color: colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchGroupTitle extends StatelessWidget {
  const _SearchGroupTitle({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        Text('$count'),
      ],
    );
  }
}

class _SearchHintCard extends StatelessWidget {
  const _SearchHintCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(
              Icons.manage_search_outlined,
              color: colorScheme.primary,
              size: 38,
            ),
            const SizedBox(height: 10),
            const Text(
              'Busca en Ma-U',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              'Encuentra tareas, materias, clases, gastos, estudio y notas guardadas.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySearchCard extends StatelessWidget {
  const _EmptySearchCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(
              Icons.search_off_outlined,
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
              'Prueba con otra palabra o revisa que el dato exista.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchResult {
  const _SearchResult({
    required this.group,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final String group;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;
}

class _SearchGroup {
  const _SearchGroup({required this.title, required this.items});

  final String title;
  final List<_SearchResult> items;
}
