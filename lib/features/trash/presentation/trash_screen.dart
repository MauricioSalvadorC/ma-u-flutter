import 'package:flutter/material.dart';

import '../../../core/formatters/app_date_formatter.dart';
import '../../../core/formatters/money_formatter.dart';
import '../../../data/database/app_database_provider.dart';
import '../../expenses/data/expense_repository.dart';
import '../../expenses/domain/university_expense.dart';
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
  late final Future<void> _seedFuture;

  @override
  void initState() {
    super.initState();
    final database = AppDatabaseProvider.instance;
    _subjectRepository = SubjectRepository(database);
    _scheduleRepository = ScheduleRepository(database);
    _taskRepository = TaskRepository(database);
    _studyRepository = StudySessionRepository(database);
    _expenseRepository = ExpenseRepository(database);
    _seedFuture = AcademicSeedService(
      subjectRepository: _subjectRepository,
      scheduleRepository: _scheduleRepository,
    ).seedIfNeeded();
  }

  Future<void> _restoreTask(AcademicTask task) async {
    final id = task.id;
    if (id == null) {
      return;
    }

    await _taskRepository.restoreTask(id);
  }

  Future<void> _restoreSubject(Subject subject) async {
    await _subjectRepository.restoreSubject(subject.id);
  }

  Future<void> _restoreSession(ClassSession session) async {
    final id = session.id;
    if (id == null) {
      return;
    }

    await _scheduleRepository.restoreSession(id);
  }

  Future<void> _restoreStudySession(StudySession session) async {
    final id = session.id;
    if (id == null) {
      return;
    }

    await _studyRepository.restoreSession(id);
  }

  Future<void> _restoreExpense(UniversityExpense expense) async {
    final id = expense.id;
    if (id == null) {
      return;
    }

    await _expenseRepository.restoreExpense(id);
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
                                return _TrashView(
                                  subjects: subjects,
                                  tasks: tasks,
                                  deletedSubjects: deletedSubjects,
                                  deletedSessions: deletedSessions,
                                  deletedStudySessions: deletedStudySessions,
                                  deletedExpenses: deletedExpenses,
                                  onRestoreTask: _restoreTask,
                                  onRestoreSubject: _restoreSubject,
                                  onRestoreSession: _restoreSession,
                                  onRestoreStudySession: _restoreStudySession,
                                  onRestoreExpense: _restoreExpense,
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

class _TrashView extends StatelessWidget {
  const _TrashView({
    required this.subjects,
    required this.tasks,
    required this.deletedSubjects,
    required this.deletedSessions,
    required this.deletedStudySessions,
    required this.deletedExpenses,
    required this.onRestoreTask,
    required this.onRestoreSubject,
    required this.onRestoreSession,
    required this.onRestoreStudySession,
    required this.onRestoreExpense,
  });

  final List<Subject> subjects;
  final List<AcademicTask> tasks;
  final List<Subject> deletedSubjects;
  final List<ClassSession> deletedSessions;
  final List<StudySession> deletedStudySessions;
  final List<UniversityExpense> deletedExpenses;
  final ValueChanged<AcademicTask> onRestoreTask;
  final ValueChanged<Subject> onRestoreSubject;
  final ValueChanged<ClassSession> onRestoreSession;
  final ValueChanged<StudySession> onRestoreStudySession;
  final ValueChanged<UniversityExpense> onRestoreExpense;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Papelera')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const _TrashHeader(),
            const SizedBox(height: 16),
            if (tasks.isEmpty &&
                deletedSubjects.isEmpty &&
                deletedSessions.isEmpty &&
                deletedStudySessions.isEmpty &&
                deletedExpenses.isEmpty)
              const _EmptyTrashCard()
            else ...[
              for (final subject in deletedSubjects) ...[
                _DeletedSubjectCard(
                  subject: subject,
                  onRestore: () => onRestoreSubject(subject),
                ),
                const SizedBox(height: 10),
              ],
              for (final session in deletedSessions) ...[
                _DeletedSessionCard(
                  session: session,
                  subject: subjects.firstWhere(
                    (subject) => subject.id == session.subjectId,
                    orElse: () => const Subject(
                      id: 'unknown',
                      name: 'Materia',
                      teacher: '',
                      room: '',
                      credits: 0,
                      accentColorValue: 0xFF64748B,
                    ),
                  ),
                  onRestore: () => onRestoreSession(session),
                ),
                const SizedBox(height: 10),
              ],
              for (final studySession in deletedStudySessions) ...[
                _DeletedStudySessionCard(
                  session: studySession,
                  subject: subjects.firstWhere(
                    (subject) => subject.id == studySession.subjectId,
                    orElse: () => const Subject(
                      id: 'unknown',
                      name: 'Materia',
                      teacher: '',
                      room: '',
                      credits: 0,
                      accentColorValue: 0xFF64748B,
                    ),
                  ),
                  onRestore: () => onRestoreStudySession(studySession),
                ),
                const SizedBox(height: 10),
              ],
              for (final task in tasks) ...[
                _DeletedTaskCard(
                  task: task,
                  subject: subjects.firstWhere(
                    (subject) => subject.id == task.subjectId,
                    orElse: () => const Subject(
                      id: 'unknown',
                      name: 'Materia',
                      teacher: '',
                      room: '',
                      credits: 0,
                      accentColorValue: 0xFF64748B,
                    ),
                  ),
                  onRestore: () => onRestoreTask(task),
                ),
                const SizedBox(height: 10),
              ],
              for (final expense in deletedExpenses) ...[
                _DeletedExpenseCard(
                  expense: expense,
                  onRestore: () => onRestoreExpense(expense),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _TrashHeader extends StatelessWidget {
  const _TrashHeader();

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
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recupera informacion',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Lo que borres queda aqui antes de desaparecer del todo.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
              'Papelera vacia',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              'Cuando borres elementos importantes, apareceran aqui para restaurarlos.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeletedTaskCard extends StatelessWidget {
  const _DeletedTaskCard({
    required this.task,
    required this.subject,
    required this.onRestore,
  });

  final AcademicTask task;
  final Subject subject;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final deletedAt = task.deletedAt;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(Icons.task_alt_outlined, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    deletedAt == null
                        ? subject.name
                        : '${subject.name} - ${AppDateFormatter.dateTime(deletedAt)}',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: onRestore,
              icon: const Icon(Icons.restore_outlined),
              label: const Text('Restaurar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeletedSubjectCard extends StatelessWidget {
  const _DeletedSubjectCard({required this.subject, required this.onRestore});

  final Subject subject;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    return _TrashItemCard(
      icon: Icons.menu_book_outlined,
      title: subject.name,
      subtitle: subject.deletedAt == null
          ? 'Materia'
          : 'Materia - ${AppDateFormatter.dateTime(subject.deletedAt!)}',
      onRestore: onRestore,
    );
  }
}

class _DeletedSessionCard extends StatelessWidget {
  const _DeletedSessionCard({
    required this.session,
    required this.subject,
    required this.onRestore,
  });

  final ClassSession session;
  final Subject subject;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    return _TrashItemCard(
      icon: Icons.calendar_month_outlined,
      title: subject.name,
      subtitle: session.deletedAt == null
          ? 'Clase'
          : 'Clase - ${AppDateFormatter.dateTime(session.deletedAt!)}',
      onRestore: onRestore,
    );
  }
}

class _DeletedStudySessionCard extends StatelessWidget {
  const _DeletedStudySessionCard({
    required this.session,
    required this.subject,
    required this.onRestore,
  });

  final StudySession session;
  final Subject subject;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    return _TrashItemCard(
      icon: Icons.psychology_alt_outlined,
      title: session.title,
      subtitle: session.deletedAt == null
          ? subject.name
          : '${subject.name} - ${AppDateFormatter.dateTime(session.deletedAt!)}',
      onRestore: onRestore,
    );
  }
}

class _DeletedExpenseCard extends StatelessWidget {
  const _DeletedExpenseCard({required this.expense, required this.onRestore});

  final UniversityExpense expense;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    return _TrashItemCard(
      icon: Icons.account_balance_wallet_outlined,
      title: expense.title,
      subtitle: expense.deletedAt == null
          ? MoneyFormatter.pesos(expense.amountCents)
          : '${MoneyFormatter.pesos(expense.amountCents)} - ${AppDateFormatter.dateTime(expense.deletedAt!)}',
      onRestore: onRestore,
    );
  }
}

class _TrashItemCard extends StatelessWidget {
  const _TrashItemCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onRestore,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              onPressed: onRestore,
              icon: const Icon(Icons.restore_outlined),
              label: const Text('Restaurar'),
            ),
          ],
        ),
      ),
    );
  }
}
