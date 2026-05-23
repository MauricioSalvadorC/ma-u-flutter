import 'package:flutter/material.dart';

import '../../../core/formatters/app_date_formatter.dart';
import '../../../data/database/app_database_provider.dart';
import '../../schedule/data/academic_seed_service.dart';
import '../../schedule/data/schedule_repository.dart';
import '../../study/data/study_session_repository.dart';
import '../../study/domain/study_session.dart';
import '../../study/presentation/study_agenda_screen.dart';
import '../../subjects/data/subject_repository.dart';
import '../../subjects/domain/subject.dart';
import '../../tasks/data/task_repository.dart';
import '../../tasks/domain/academic_task.dart';
import '../../tasks/presentation/tasks_screen.dart';

class ExamWeekScreen extends StatefulWidget {
  const ExamWeekScreen({super.key});

  @override
  State<ExamWeekScreen> createState() => _ExamWeekScreenState();
}

class _ExamWeekScreenState extends State<ExamWeekScreen> {
  late final SubjectRepository _subjectRepository;
  late final ScheduleRepository _scheduleRepository;
  late final TaskRepository _taskRepository;
  late final StudySessionRepository _studyRepository;
  late final Future<void> _seedFuture;

  @override
  void initState() {
    super.initState();
    final database = AppDatabaseProvider.instance;
    _subjectRepository = SubjectRepository(database);
    _scheduleRepository = ScheduleRepository(database);
    _taskRepository = TaskRepository(database);
    _studyRepository = StudySessionRepository(database);
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
              stream: _taskRepository.watchTasks(),
              builder: (context, taskSnapshot) {
                final tasks = taskSnapshot.data ?? const <AcademicTask>[];
                return StreamBuilder<List<StudySession>>(
                  stream: _studyRepository.watchSessions(),
                  builder: (context, studySnapshot) {
                    final sessions =
                        studySnapshot.data ?? const <StudySession>[];
                    return _ExamWeekView(
                      subjects: subjects,
                      tasks: tasks,
                      studySessions: sessions,
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

class _ExamWeekView extends StatelessWidget {
  const _ExamWeekView({
    required this.subjects,
    required this.tasks,
    required this.studySessions,
  });

  final List<Subject> subjects;
  final List<AcademicTask> tasks;
  final List<StudySession> studySessions;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final limit = DateTime(now.year, now.month, now.day + 14, 23, 59);
    final activeSubjectIds = subjects.map((subject) => subject.id).toSet();
    final criticalTasks = tasks.where((task) {
      final dueDate = task.dueDate;
      final isUpcoming =
          dueDate == null ||
          !dueDate.isBefore(DateTime(now.year, now.month, now.day)) &&
              !dueDate.isAfter(limit);
      return !task.isCompleted &&
          activeSubjectIds.contains(task.subjectId) &&
          isUpcoming &&
          task.priority == TaskPriority.high;
    }).toList()..sort(_sortTaskByDate);
    final examStudy = studySessions.where((session) {
      final startsAt = session.startsAt;
      final isUpcoming =
          startsAt == null ||
          !startsAt.isBefore(DateTime(now.year, now.month, now.day)) &&
              !startsAt.isAfter(limit);
      return !session.isCompleted &&
          activeSubjectIds.contains(session.subjectId) &&
          isUpcoming &&
          session.focusLevel == FocusLevel.exam;
    }).toList()..sort(_sortStudyByDate);
    final totalStudyMinutes = examStudy.fold<int>(
      0,
      (total, session) => total + session.durationMinutes,
    );
    final subjectPlans = _buildSubjectPlans(
      subjects: subjects,
      tasks: criticalTasks,
      studySessions: examStudy,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Semana de parciales')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            _ExamWeekHeader(
              criticalTasks: criticalTasks.length,
              studySessions: examStudy.length,
              studyMinutes: totalStudyMinutes,
            ),
            const SizedBox(height: 16),
            _QuickActionsRow(
              onTasks: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => const TasksScreen()),
                );
              },
              onStudy: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const StudyAgendaScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            if (criticalTasks.isEmpty && examStudy.isEmpty)
              const _EmptyExamWeekCard()
            else ...[
              const _SectionHeading('Materias en foco'),
              const SizedBox(height: 10),
              for (final plan in subjectPlans) ...[
                _SubjectPressureCard(plan: plan),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 8),
              const _SectionHeading('Tareas criticas'),
              const SizedBox(height: 10),
              for (final task in criticalTasks.take(8)) ...[
                _ExamItemCard(
                  icon: Icons.assignment_late_outlined,
                  title: task.title,
                  subtitle: _taskSubtitle(task),
                  color: const Color(0xFFBE123C),
                ),
                const SizedBox(height: 10),
              ],
              const SizedBox(height: 8),
              const _SectionHeading('Bloques de estudio para parcial'),
              const SizedBox(height: 10),
              for (final session in examStudy.take(8)) ...[
                _ExamItemCard(
                  icon: Icons.psychology_alt_outlined,
                  title: session.title,
                  subtitle: _studySubtitle(session),
                  color: const Color(0xFF2563EB),
                ),
                const SizedBox(height: 10),
              ],
            ],
          ],
        ),
      ),
    );
  }

  List<_SubjectPlan> _buildSubjectPlans({
    required List<Subject> subjects,
    required List<AcademicTask> tasks,
    required List<StudySession> studySessions,
  }) {
    final plans = <_SubjectPlan>[];
    for (final subject in subjects) {
      final subjectTasks = tasks
          .where((task) => task.subjectId == subject.id)
          .toList();
      final subjectStudy = studySessions
          .where((session) => session.subjectId == subject.id)
          .toList();
      if (subjectTasks.isEmpty && subjectStudy.isEmpty) {
        continue;
      }

      plans.add(
        _SubjectPlan(
          subject: subject,
          taskCount: subjectTasks.length,
          studyMinutes: subjectStudy.fold<int>(
            0,
            (total, session) => total + session.durationMinutes,
          ),
        ),
      );
    }

    plans.sort((a, b) => b.pressure.compareTo(a.pressure));
    return plans;
  }

  static int _sortTaskByDate(AcademicTask a, AcademicTask b) {
    final aDate = a.dueDate ?? DateTime(9999);
    final bDate = b.dueDate ?? DateTime(9999);
    return aDate.compareTo(bDate);
  }

  static int _sortStudyByDate(StudySession a, StudySession b) {
    final aDate = a.startsAt ?? DateTime(9999);
    final bDate = b.startsAt ?? DateTime(9999);
    return aDate.compareTo(bDate);
  }

  String _taskSubtitle(AcademicTask task) {
    final subject = _subjectName(task.subjectId);
    final dueDate = task.dueDate;
    final date = dueDate == null
        ? 'Sin fecha'
        : AppDateFormatter.dateWithOptionalTime(dueDate);
    return '$subject - $date';
  }

  String _studySubtitle(StudySession session) {
    final subject = _subjectName(session.subjectId);
    final startsAt = session.startsAt;
    final date = startsAt == null
        ? 'Sin fecha'
        : AppDateFormatter.dateWithOptionalTime(startsAt);
    return '$subject - ${session.durationMinutes} min - $date';
  }

  String _subjectName(String subjectId) {
    return subjects
        .firstWhere(
          (subject) => subject.id == subjectId,
          orElse: () => const Subject(
            id: 'unknown',
            name: 'Materia',
            teacher: '',
            room: '',
            credits: 0,
            accentColorValue: 0xFF64748B,
          ),
        )
        .name;
  }
}

class _ExamWeekHeader extends StatelessWidget {
  const _ExamWeekHeader({
    required this.criticalTasks,
    required this.studySessions,
    required this.studyMinutes,
  });

  final int criticalTasks;
  final int studySessions;
  final int studyMinutes;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hours = studyMinutes ~/ 60;
    final minutes = studyMinutes % 60;
    final timeLabel = hours == 0 ? '${minutes}m' : '${hours}h ${minutes}m';
    final statusColor = criticalTasks >= 4
        ? const Color(0xFFBE123C)
        : criticalTasks >= 2
        ? const Color(0xFFD97706)
        : const Color(0xFF16A34A);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(36),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.warning_amber_outlined, color: statusColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Modo alto enfoque',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Proximos 14 dias',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _MetricTile(
                    value: criticalTasks.toString(),
                    label: 'Criticas',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricTile(
                    value: studySessions.toString(),
                    label: 'Sesiones',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricTile(value: timeLabel, label: 'Estudio'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.onTasks, required this.onStudy});

  final VoidCallback onTasks;
  final VoidCallback onStudy;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: onTasks,
            icon: const Icon(Icons.add_task_outlined),
            label: const Text('Tarea'),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onStudy,
            icon: const Icon(Icons.psychology_alt_outlined),
            label: const Text('Estudio'),
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withAlpha(128),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

class _SubjectPressureCard extends StatelessWidget {
  const _SubjectPressureCard({required this.plan});

  final _SubjectPlan plan;

  @override
  Widget build(BuildContext context) {
    final subjectColor = Color(plan.subject.accentColorValue);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: subjectColor.withAlpha(42),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.menu_book_outlined, color: subjectColor),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plan.subject.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${plan.taskCount} criticas - ${plan.studyMinutes} min planeados',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _PressureBadge(value: plan.pressure),
          ],
        ),
      ),
    );
  }
}

class _PressureBadge extends StatelessWidget {
  const _PressureBadge({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    final color = value >= 4
        ? const Color(0xFFBE123C)
        : value >= 2
        ? const Color(0xFFD97706)
        : const Color(0xFF16A34A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(36),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        value.toString(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ExamItemCard extends StatelessWidget {
  const _ExamItemCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
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

class _EmptyExamWeekCard extends StatelessWidget {
  const _EmptyExamWeekCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(Icons.verified_outlined, color: colorScheme.primary, size: 38),
            const SizedBox(height: 10),
            const Text(
              'Semana tranquila',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              'Marca tareas como prioridad alta o sesiones con enfoque Parcial para activar este modo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
    );
  }
}

class _SubjectPlan {
  const _SubjectPlan({
    required this.subject,
    required this.taskCount,
    required this.studyMinutes,
  });

  final Subject subject;
  final int taskCount;
  final int studyMinutes;

  int get pressure => taskCount * 2 + (studyMinutes / 60).ceil();
}
