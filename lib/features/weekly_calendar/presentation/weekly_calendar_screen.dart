import 'package:flutter/material.dart';

import '../../../core/formatters/app_date_formatter.dart';
import '../../../core/widgets/app_detail_bottom_sheet.dart';
import '../../../data/database/app_database_provider.dart';
import '../../schedule/data/academic_seed_service.dart';
import '../../schedule/data/schedule_repository.dart';
import '../../schedule/domain/class_session.dart';
import '../../study/data/study_session_repository.dart';
import '../../study/domain/study_session.dart';
import '../../subjects/data/subject_repository.dart';
import '../../subjects/domain/subject.dart';
import '../../tasks/data/task_repository.dart';
import '../../tasks/domain/academic_task.dart';

class WeeklyCalendarScreen extends StatefulWidget {
  const WeeklyCalendarScreen({super.key});

  @override
  State<WeeklyCalendarScreen> createState() => _WeeklyCalendarScreenState();
}

class _WeeklyCalendarScreenState extends State<WeeklyCalendarScreen> {
  late final SubjectRepository _subjectRepository;
  late final ScheduleRepository _scheduleRepository;
  late final TaskRepository _taskRepository;
  late final StudySessionRepository _studyRepository;
  late final Future<void> _seedFuture;
  final Set<_CalendarItemType> _visibleTypes = {..._CalendarItemType.values};

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
                        return _WeeklyCalendarView(
                          subjects: subjects,
                          sessions: sessions,
                          tasks: tasks,
                          studySessions: studySessions,
                          visibleTypes: _visibleTypes,
                          onToggleType: (type) {
                            setState(() {
                              if (_visibleTypes.contains(type)) {
                                if (_visibleTypes.length > 1) {
                                  _visibleTypes.remove(type);
                                }
                              } else {
                                _visibleTypes.add(type);
                              }
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
  }
}

class _WeeklyCalendarView extends StatelessWidget {
  const _WeeklyCalendarView({
    required this.subjects,
    required this.sessions,
    required this.tasks,
    required this.studySessions,
    required this.visibleTypes,
    required this.onToggleType,
  });

  final List<Subject> subjects;
  final List<ClassSession> sessions;
  final List<AcademicTask> tasks;
  final List<StudySession> studySessions;
  final Set<_CalendarItemType> visibleTypes;
  final ValueChanged<_CalendarItemType> onToggleType;

  @override
  Widget build(BuildContext context) {
    final itemsByDay = _buildItemsByDay();
    final today = _weekdayFromDate(DateTime.now());

    return Scaffold(
      appBar: AppBar(title: const Text('Calendario semanal')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            _CalendarHeader(itemsByDay: itemsByDay),
            const SizedBox(height: 16),
            _CalendarFilterBar(
              visibleTypes: visibleTypes,
              onToggleType: onToggleType,
            ),
            const SizedBox(height: 16),
            for (final day in Weekday.values) ...[
              _DayAgendaSection(
                day: day,
                isToday: today == day,
                items: itemsByDay[day] ?? const <_CalendarItem>[],
              ),
              const SizedBox(height: 12),
            ],
          ],
        ),
      ),
    );
  }

  Map<Weekday, List<_CalendarItem>> _buildItemsByDay() {
    final subjectMap = {for (final subject in subjects) subject.id: subject};
    final itemsByDay = {
      for (final day in Weekday.values) day: <_CalendarItem>[],
    };

    if (visibleTypes.contains(_CalendarItemType.classSession)) {
      for (final session in sessions) {
        final subject = subjectMap[session.subjectId];
        if (subject == null) {
          continue;
        }
        itemsByDay[session.weekday]!.add(
          _CalendarItem(
            type: _CalendarItemType.classSession,
            title: subject.name,
            subtitle: '${session.timeRange} - ${session.location}',
            detailRows: [
              _DetailRowData(label: 'Materia', value: subject.name),
              _DetailRowData(label: 'Horario', value: session.timeRange),
              _DetailRowData(label: 'Salon', value: session.location),
              _DetailRowData(label: 'Docente', value: subject.teacher),
            ],
            minuteOfDay: session.startsAtMinute,
            color: Color(subject.accentColorValue),
          ),
        );
      }
    }

    if (visibleTypes.contains(_CalendarItemType.task)) {
      for (final task in tasks.where((task) => !task.isCompleted)) {
        final dueDate = task.dueDate;
        if (dueDate == null) {
          continue;
        }
        final day = _weekdayFromDate(dueDate);
        if (day == null || !itemsByDay.containsKey(day)) {
          continue;
        }
        final subject = subjectMap[task.subjectId];
        itemsByDay[day]!.add(
          _CalendarItem(
            type: _CalendarItemType.task,
            title: task.title,
            subtitle:
                '${subject?.name ?? 'Materia'} - ${AppDateFormatter.dateWithOptionalTime(dueDate)}',
            detailRows: [
              _DetailRowData(
                label: 'Materia',
                value: subject?.name ?? 'Materia',
              ),
              _DetailRowData(label: 'Prioridad', value: task.priority.label),
              _DetailRowData(
                label: 'Fecha',
                value: AppDateFormatter.dateWithOptionalTime(dueDate),
              ),
              if (task.description.isNotEmpty)
                _DetailRowData(label: 'Descripcion', value: task.description),
            ],
            minuteOfDay: dueDate.hour * 60 + dueDate.minute,
            color: _priorityColor(task.priority),
          ),
        );
      }
    }

    if (visibleTypes.contains(_CalendarItemType.study)) {
      for (final session in studySessions.where(
        (session) => !session.isCompleted,
      )) {
        final startsAt = session.startsAt;
        if (startsAt == null) {
          continue;
        }
        final day = _weekdayFromDate(startsAt);
        if (day == null || !itemsByDay.containsKey(day)) {
          continue;
        }
        final subject = subjectMap[session.subjectId];
        itemsByDay[day]!.add(
          _CalendarItem(
            type: _CalendarItemType.study,
            title: session.title,
            subtitle:
                '${subject?.name ?? 'Materia'} - ${session.durationMinutes} min',
            detailRows: [
              _DetailRowData(
                label: 'Materia',
                value: subject?.name ?? 'Materia',
              ),
              _DetailRowData(label: 'Enfoque', value: session.focusLevel.label),
              _DetailRowData(
                label: 'Duracion',
                value: '${session.durationMinutes} minutos',
              ),
              _DetailRowData(
                label: 'Fecha',
                value: AppDateFormatter.dateWithOptionalTime(startsAt),
              ),
              if (session.notes.isNotEmpty)
                _DetailRowData(label: 'Notas', value: session.notes),
            ],
            minuteOfDay: startsAt.hour * 60 + startsAt.minute,
            color: _focusColor(session.focusLevel),
          ),
        );
      }
    }

    for (final items in itemsByDay.values) {
      items.sort((a, b) => a.minuteOfDay.compareTo(b.minuteOfDay));
    }

    return itemsByDay;
  }

  Weekday? _weekdayFromDate(DateTime date) {
    return switch (date.weekday) {
      DateTime.monday => Weekday.monday,
      DateTime.tuesday => Weekday.tuesday,
      DateTime.wednesday => Weekday.wednesday,
      DateTime.thursday => Weekday.thursday,
      DateTime.friday => Weekday.friday,
      DateTime.saturday => Weekday.saturday,
      _ => null,
    };
  }

  Color _priorityColor(TaskPriority priority) {
    return switch (priority) {
      TaskPriority.low => const Color(0xFF16A34A),
      TaskPriority.medium => const Color(0xFFD97706),
      TaskPriority.high => const Color(0xFFBE123C),
    };
  }

  Color _focusColor(FocusLevel focusLevel) {
    return switch (focusLevel) {
      FocusLevel.light => const Color(0xFF16A34A),
      FocusLevel.deep => const Color(0xFF2563EB),
      FocusLevel.exam => const Color(0xFFBE123C),
    };
  }
}

class _CalendarHeader extends StatelessWidget {
  const _CalendarHeader({required this.itemsByDay});

  final Map<Weekday, List<_CalendarItem>> itemsByDay;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final totalItems = itemsByDay.values.fold<int>(
      0,
      (total, items) => total + items.length,
    );
    final busiestDay = Weekday.values.fold<Weekday?>(null, (current, day) {
      if (current == null) {
        return day;
      }
      return (itemsByDay[day]?.length ?? 0) > (itemsByDay[current]?.length ?? 0)
          ? day
          : current;
    });

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
                Icons.calendar_view_week_outlined,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vista semanal',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalItems eventos - dia mas cargado: ${busiestDay?.shortLabel ?? '--'}',
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

class _CalendarFilterBar extends StatelessWidget {
  const _CalendarFilterBar({
    required this.visibleTypes,
    required this.onToggleType,
  });

  final Set<_CalendarItemType> visibleTypes;
  final ValueChanged<_CalendarItemType> onToggleType;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final type in _CalendarItemType.values) ...[
            FilterChip(
              label: Text(type.label),
              avatar: Icon(type.icon, size: 18),
              selected: visibleTypes.contains(type),
              onSelected: (_) => onToggleType(type),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _DayAgendaSection extends StatelessWidget {
  const _DayAgendaSection({
    required this.day,
    required this.isToday,
    required this.items,
  });

  final Weekday day;
  final bool isToday;
  final List<_CalendarItem> items;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              day.label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(width: 8),
            if (isToday)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Hoy',
                  style: TextStyle(
                    color: colorScheme.onPrimaryContainer,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            const Spacer(),
            Text('${items.length}'),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Text(
              'Sin eventos',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          )
        else
          for (final item in items) ...[
            _CalendarItemCard(item: item),
            const SizedBox(height: 8),
          ],
      ],
    );
  }
}

class _CalendarItemCard extends StatelessWidget {
  const _CalendarItemCard({required this.item});

  final _CalendarItem item;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showDetails(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 5,
                height: 52,
                decoration: BoxDecoration(
                  color: item.color,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Icon(item.type.icon, color: item.color),
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
            ],
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    AppDetailBottomSheet.show(
      context: context,
      children: [
        Text(
          item.title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 14),
        _DetailRowData(label: 'Tipo', value: item.type.label).toWidget(),
        for (final row in item.detailRows) row.toWidget(),
      ],
    );
  }
}

class _CalendarItem {
  const _CalendarItem({
    required this.type,
    required this.title,
    required this.subtitle,
    required this.detailRows,
    required this.minuteOfDay,
    required this.color,
  });

  final _CalendarItemType type;
  final String title;
  final String subtitle;
  final List<_DetailRowData> detailRows;
  final int minuteOfDay;
  final Color color;
}

class _DetailRowData {
  const _DetailRowData({required this.label, required this.value});

  final String label;
  final String value;

  Widget toWidget() {
    return Builder(
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
            ],
          ),
        );
      },
    );
  }
}

enum _CalendarItemType {
  classSession('Clases', Icons.calendar_month_outlined),
  task('Tareas', Icons.task_alt_outlined),
  study('Estudio', Icons.psychology_alt_outlined);

  const _CalendarItemType(this.label, this.icon);

  final String label;
  final IconData icon;
}
