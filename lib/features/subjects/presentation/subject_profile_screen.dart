import 'package:flutter/material.dart';

import '../../../core/formatters/app_date_formatter.dart';
import '../../../data/database/app_database_provider.dart';
import '../../grades/presentation/grade_calculator_screen.dart';
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
import '../../tasks/data/task_repository.dart';
import '../../tasks/domain/academic_task.dart';
import '../../tasks/presentation/tasks_screen.dart';
import '../data/subject_repository.dart';
import '../domain/subject.dart';

class SubjectProfileScreen extends StatefulWidget {
  const SubjectProfileScreen({super.key, required this.subject});

  final Subject subject;

  @override
  State<SubjectProfileScreen> createState() => _SubjectProfileScreenState();
}

class _SubjectProfileScreenState extends State<SubjectProfileScreen> {
  late final SubjectRepository _subjectRepository;
  late final ScheduleRepository _scheduleRepository;
  late final TaskRepository _taskRepository;
  late final StudySessionRepository _studyRepository;
  late final NoteRepository _noteRepository;
  late final Future<void> _seedFuture;

  @override
  void initState() {
    super.initState();
    final database = AppDatabaseProvider.instance;
    _subjectRepository = SubjectRepository(database);
    _scheduleRepository = ScheduleRepository(database);
    _taskRepository = TaskRepository(database);
    _studyRepository = StudySessionRepository(database);
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

        return StreamBuilder<List<ClassSession>>(
          stream: _scheduleRepository.watchSessions(),
          builder: (context, sessionSnapshot) {
            final sessions = (sessionSnapshot.data ?? const <ClassSession>[])
                .where((session) => session.subjectId == widget.subject.id)
                .toList();
            return StreamBuilder<List<AcademicTask>>(
              stream: _taskRepository.watchTasks(),
              builder: (context, taskSnapshot) {
                final tasks = (taskSnapshot.data ?? const <AcademicTask>[])
                    .where((task) => task.subjectId == widget.subject.id)
                    .toList();
                return StreamBuilder<List<StudySession>>(
                  stream: _studyRepository.watchSessions(),
                  builder: (context, studySnapshot) {
                    final studySessions =
                        (studySnapshot.data ?? const <StudySession>[])
                            .where(
                              (session) =>
                                  session.subjectId == widget.subject.id,
                            )
                            .toList();
                    return StreamBuilder<List<AcademicNote>>(
                      stream: _noteRepository.watchNotes(),
                      builder: (context, noteSnapshot) {
                        final notes =
                            (noteSnapshot.data ?? const <AcademicNote>[])
                                .where(
                                  (note) => note.subjectId == widget.subject.id,
                                )
                                .toList();
                        return _SubjectProfileView(
                          subject: widget.subject,
                          sessions: sessions,
                          tasks: tasks,
                          studySessions: studySessions,
                          notes: notes,
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

class _SubjectProfileView extends StatelessWidget {
  const _SubjectProfileView({
    required this.subject,
    required this.sessions,
    required this.tasks,
    required this.studySessions,
    required this.notes,
  });

  final Subject subject;
  final List<ClassSession> sessions;
  final List<AcademicTask> tasks;
  final List<StudySession> studySessions;
  final List<AcademicNote> notes;

  @override
  Widget build(BuildContext context) {
    final pendingTasks = tasks.where((task) => !task.isCompleted).toList();
    final criticalTasks = pendingTasks
        .where((task) => task.priority == TaskPriority.high)
        .length;
    final pendingStudy = studySessions
        .where((session) => !session.isCompleted)
        .toList();
    final studyMinutes = pendingStudy.fold<int>(
      0,
      (total, session) => total + session.durationMinutes,
    );
    final sortedSessions = [...sessions]..sort(_compareClassSessions);
    final nextClass = _nextClass(sessions);
    final nextTask = _nextTask(pendingTasks);
    final nextStudy = _nextStudy(pendingStudy);
    final accent = Color(subject.accentColorValue);

    return Scaffold(
      appBar: AppBar(title: Text(subject.name)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            _SubjectHero(subject: subject, accent: accent),
            const SizedBox(height: 14),
            _MetricGrid(
              items: [
                _MetricItem(
                  icon: Icons.task_alt_outlined,
                  value: pendingTasks.length.toString(),
                  label: 'Tareas',
                ),
                _MetricItem(
                  icon: Icons.warning_amber_outlined,
                  value: criticalTasks.toString(),
                  label: 'Criticas',
                ),
                _MetricItem(
                  icon: Icons.psychology_alt_outlined,
                  value: '${studyMinutes}m',
                  label: 'Estudio',
                ),
                _MetricItem(
                  icon: Icons.edit_note_outlined,
                  value: notes.length.toString(),
                  label: 'Apuntes',
                ),
              ],
            ),
            const SizedBox(height: 14),
            _NextFocusCard(
              nextClass: nextClass,
              nextTask: nextTask,
              nextStudy: nextStudy,
            ),
            const SizedBox(height: 18),
            _ProfileSection(
              title: 'Horario',
              actionLabel: 'Ver horario',
              onAction: () => _open(context, const AcademicPlannerScreen()),
              emptyIcon: Icons.calendar_month_outlined,
              emptyText: 'No hay clases registradas para esta materia.',
              children: [
                for (final session in sortedSessions.take(3))
                  _InfoTile(
                    icon: Icons.calendar_month_outlined,
                    title: '${session.weekday.label} - ${session.timeRange}',
                    subtitle: session.location,
                  ),
              ],
            ),
            _ProfileSection(
              title: 'Tareas',
              actionLabel: 'Ver tareas',
              onAction: () =>
                  _open(context, TasksScreen(initialSubjectId: subject.id)),
              emptyIcon: Icons.task_alt_outlined,
              emptyText: 'No hay tareas activas para esta materia.',
              children: [
                for (final task in _sortedTasks(pendingTasks).take(3))
                  _InfoTile(
                    icon: Icons.task_alt_outlined,
                    title: task.title,
                    subtitle: task.dueDate == null
                        ? '${task.priority.label} - sin fecha'
                        : '${task.priority.label} - ${AppDateFormatter.dateWithOptionalTime(task.dueDate!)}',
                  ),
              ],
            ),
            _ProfileSection(
              title: 'Estudio',
              actionLabel: 'Ver estudio',
              onAction: () => _open(
                context,
                StudyAgendaScreen(initialSubjectId: subject.id),
              ),
              emptyIcon: Icons.psychology_alt_outlined,
              emptyText: 'No hay bloques de estudio pendientes.',
              children: [
                for (final session in _sortedStudy(pendingStudy).take(3))
                  _InfoTile(
                    icon: Icons.psychology_alt_outlined,
                    title: session.title,
                    subtitle:
                        '${session.durationMinutes} min - ${session.focusLevel.label}',
                  ),
              ],
            ),
            _ProfileSection(
              title: 'Apuntes',
              actionLabel: 'Ver apuntes',
              onAction: () =>
                  _open(context, NotesScreen(initialSubjectId: subject.id)),
              emptyIcon: Icons.edit_note_outlined,
              emptyText: 'No hay apuntes guardados para esta materia.',
              children: [
                for (final note in _sortedNotes(notes).take(3))
                  _InfoTile(
                    icon: Icons.edit_note_outlined,
                    title: note.title,
                    subtitle:
                        'Actualizado ${AppDateFormatter.date(note.updatedAt)}',
                  ),
              ],
            ),
            _GradesPreviewCard(
              onOpen: () => _open(context, const GradeCalculatorScreen()),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => screen));
  }
}

class _SubjectHero extends StatelessWidget {
  const _SubjectHero({required this.subject, required this.accent});

  final Subject subject;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: accent.withAlpha(42),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.menu_book_outlined, color: accent, size: 30),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    subject.name,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${subject.teacher} - ${subject.room}',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(height: 10),
                  _SoftPill(
                    icon: Icons.school_outlined,
                    label: '${subject.credits} creditos',
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

class _MetricGrid extends StatelessWidget {
  const _MetricGrid({required this.items});

  final List<_MetricItem> items;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.35,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [for (final item in items) _MetricTile(item: item)],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.item});

  final _MetricItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            Icon(item.icon, color: colorScheme.primary),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 12,
                    ),
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

class _NextFocusCard extends StatelessWidget {
  const _NextFocusCard({
    required this.nextClass,
    required this.nextTask,
    required this.nextStudy,
  });

  final ClassSession? nextClass;
  final AcademicTask? nextTask;
  final StudySession? nextStudy;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enfoque de materia',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            _FocusLine(
              icon: Icons.calendar_month_outlined,
              label: 'Clase',
              value: nextClass == null
                  ? 'Sin clases proximas'
                  : '${nextClass!.weekday.shortLabel} ${nextClass!.timeRange}',
            ),
            _FocusLine(
              icon: Icons.task_alt_outlined,
              label: 'Tarea',
              value: nextTask == null
                  ? 'Sin pendientes'
                  : nextTask!.dueDate == null
                  ? nextTask!.title
                  : '${nextTask!.title} - ${AppDateFormatter.dateWithOptionalTime(nextTask!.dueDate!)}',
            ),
            _FocusLine(
              icon: Icons.psychology_alt_outlined,
              label: 'Estudio',
              value: nextStudy == null
                  ? 'Sin bloques'
                  : '${nextStudy!.title} - ${nextStudy!.durationMinutes} min',
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  const _ProfileSection({
    required this.title,
    required this.actionLabel,
    required this.onAction,
    required this.emptyIcon,
    required this.emptyText,
    required this.children,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;
  final IconData emptyIcon;
  final String emptyText;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              TextButton(onPressed: onAction, child: Text(actionLabel)),
            ],
          ),
          const SizedBox(height: 8),
          if (children.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(emptyIcon, color: colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        emptyText,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            for (final child in children) ...[child, const SizedBox(height: 8)],
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

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
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
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

class _GradesPreviewCard extends StatelessWidget {
  const _GradesPreviewCard({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(Icons.calculate_outlined, color: colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Calificaciones',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Por ahora abre la calculadora. El sistema por materia sera la siguiente evolucion.',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Abrir calculadora',
              onPressed: onOpen,
              icon: const Icon(Icons.east),
            ),
          ],
        ),
      ),
    );
  }
}

class _SoftPill extends StatelessWidget {
  const _SoftPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _FocusLine extends StatelessWidget {
  const _FocusLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colorScheme.primary),
          const SizedBox(width: 10),
          SizedBox(
            width: 62,
            child: Text(
              label,
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricItem {
  const _MetricItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;
}

int _compareClassSessions(ClassSession a, ClassSession b) {
  final day = a.weekday.index.compareTo(b.weekday.index);
  if (day != 0) {
    return day;
  }

  return a.startsAtMinute.compareTo(b.startsAtMinute);
}

ClassSession? _nextClass(List<ClassSession> sessions) {
  if (sessions.isEmpty) {
    return null;
  }

  final now = DateTime.now();
  final nowMinute = now.hour * 60 + now.minute;
  final sorted = [...sessions]
    ..sort(
      (a, b) => _classDistance(
        a,
        now,
        nowMinute,
      ).compareTo(_classDistance(b, now, nowMinute)),
    );
  return sorted.first;
}

int _classDistance(ClassSession session, DateTime now, int nowMinute) {
  var days = (session.weekday.index + 1 - now.weekday) % 7;
  if (days == 0 && session.startsAtMinute < nowMinute) {
    days = 7;
  }

  return days * 1440 + session.startsAtMinute;
}

AcademicTask? _nextTask(List<AcademicTask> tasks) {
  final sorted = _sortedTasks(tasks);
  return sorted.isEmpty ? null : sorted.first;
}

StudySession? _nextStudy(List<StudySession> sessions) {
  final sorted = _sortedStudy(sessions);
  return sorted.isEmpty ? null : sorted.first;
}

List<AcademicTask> _sortedTasks(List<AcademicTask> tasks) {
  return [...tasks]..sort((a, b) {
    final aDate = a.dueDate;
    final bDate = b.dueDate;
    if (aDate == null && bDate == null) {
      return b.priority.index.compareTo(a.priority.index);
    }
    if (aDate == null) {
      return 1;
    }
    if (bDate == null) {
      return -1;
    }
    return aDate.compareTo(bDate);
  });
}

List<StudySession> _sortedStudy(List<StudySession> sessions) {
  return [...sessions]..sort((a, b) {
    final aDate = a.startsAt;
    final bDate = b.startsAt;
    if (aDate == null && bDate == null) {
      return b.durationMinutes.compareTo(a.durationMinutes);
    }
    if (aDate == null) {
      return 1;
    }
    if (bDate == null) {
      return -1;
    }
    return aDate.compareTo(bDate);
  });
}

List<AcademicNote> _sortedNotes(List<AcademicNote> notes) {
  return [...notes]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
}
