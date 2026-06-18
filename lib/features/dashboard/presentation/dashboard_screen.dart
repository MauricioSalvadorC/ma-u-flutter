import 'package:flutter/material.dart';

import '../../../core/formatters/app_date_formatter.dart';
import '../../../core/settings/app_settings_controller.dart';
import '../../../core/widgets/app_detail_bottom_sheet.dart';
import '../../../core/widgets/ma_u_brand.dart';
import '../../../data/database/app_database_provider.dart';
import '../../academic_goals/presentation/academic_goals_screen.dart';
import '../../academic_record/presentation/academic_record_screen.dart';
import '../../exam_week/presentation/exam_week_screen.dart';
import '../../expenses/presentation/expenses_screen.dart';
import '../../grades/presentation/grade_calculator_screen.dart';
import '../../notes/presentation/notes_screen.dart';
import '../../schedule/data/academic_seed_service.dart';
import '../../schedule/data/schedule_repository.dart';
import '../../schedule/domain/class_session.dart';
import '../../schedule/presentation/academic_planner_screen.dart';
import '../../search/presentation/global_search_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../study/data/study_session_repository.dart';
import '../../study/domain/study_session.dart';
import '../../study/presentation/study_agenda_screen.dart';
import '../../subjects/data/subject_repository.dart';
import '../../subjects/domain/subject.dart';
import '../../tasks/data/task_repository.dart';
import '../../tasks/domain/academic_task.dart';
import '../../tasks/presentation/tasks_screen.dart';
import '../../trash/presentation/trash_screen.dart';
import '../../weekly_calendar/presentation/weekly_calendar_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
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
    final settings = AppSettingsScope.of(context);
    final selectedColor = settings.selectedColor;
    final modules = [
      _DashboardModule(
        icon: Icons.calculate_outlined,
        title: 'Calcular notas',
        subtitle: 'Final, cortes y cuanto necesitas para pasar.',
        color: selectedColor.color,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const GradeCalculatorScreen(),
            ),
          );
        },
      ),
      _DashboardModule(
        icon: Icons.calendar_view_week_outlined,
        title: 'Calendario semanal',
        subtitle: 'Clases, tareas y estudio en una agenda unificada.',
        color: const Color(0xFF0284C7),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const WeeklyCalendarScreen(),
            ),
          );
        },
      ),
      _DashboardModule(
        icon: Icons.calendar_month_outlined,
        title: 'Horario',
        subtitle: 'Clases, salones, docentes y bloques de estudio.',
        color: const Color(0xFF2563EB),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const AcademicPlannerScreen(),
            ),
          );
        },
      ),
      _DashboardModule(
        icon: Icons.school_outlined,
        title: 'Promedio acumulado',
        subtitle: 'Semestres, creditos, notas finales e historial.',
        color: const Color(0xFF0F766E),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const AcademicRecordScreen(),
            ),
          );
        },
      ),
      _DashboardModule(
        icon: Icons.psychology_alt_outlined,
        title: 'Agenda de estudio',
        subtitle: 'Bloques de enfoque, repasos y preparacion de parciales.',
        color: const Color(0xFF0F766E),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const StudyAgendaScreen()),
          );
        },
      ),
      _DashboardModule(
        icon: Icons.edit_note_outlined,
        title: 'Apuntes',
        subtitle: 'Notas por materia, resumenes, ideas y dudas guardadas.',
        color: const Color(0xFF0891B2),
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const NotesScreen()));
        },
      ),
      _DashboardModule(
        icon: Icons.warning_amber_outlined,
        title: 'Semana de parciales',
        subtitle: 'Prioriza entregas criticas y bloques de estudio.',
        color: const Color(0xFFBE123C),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const ExamWeekScreen()),
          );
        },
      ),
      _DashboardModule(
        icon: Icons.task_alt_outlined,
        title: 'Tareas',
        subtitle: 'Recordatorios, entregas y avance por materia.',
        color: const Color(0xFF7C3AED),
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const TasksScreen()));
        },
      ),
      _DashboardModule(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Gastos',
        subtitle: 'Transporte, comida, copias y presupuesto mensual.',
        color: const Color(0xFFDC6B19),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const ExpensesScreen()),
          );
        },
      ),
      _DashboardModule(
        icon: Icons.track_changes_outlined,
        title: 'Metas academicas',
        subtitle: 'Objetivo de promedio y simulacion de avance.',
        color: const Color(0xFF4F46E5),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const AcademicGoalsScreen(),
            ),
          );
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const _AppTitle(),
        actions: [
          IconButton(
            tooltip: 'Buscar',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const GlobalSearchScreen(),
                ),
              );
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            tooltip: 'Papelera',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const TrashScreen()),
              );
            },
            icon: const Icon(Icons.restore_from_trash_outlined),
          ),
          IconButton(
            tooltip: 'Configuracion',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.tune_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            _StatusHeader(colorOption: selectedColor),
            const SizedBox(height: 14),
            FutureBuilder<void>(
              future: _seedFuture,
              builder: (context, seedSnapshot) {
                if (seedSnapshot.connectionState != ConnectionState.done) {
                  return const _DashboardPulseCard();
                }

                return StreamBuilder<List<Subject>>(
                  stream: _subjectRepository.watchSubjects(),
                  builder: (context, subjectSnapshot) {
                    final subjects = subjectSnapshot.data ?? const <Subject>[];
                    return StreamBuilder<List<ClassSession>>(
                      stream: _scheduleRepository.watchSessions(),
                      builder: (context, sessionSnapshot) {
                        final sessions =
                            sessionSnapshot.data ?? const <ClassSession>[];
                        return StreamBuilder<List<AcademicTask>>(
                          stream: _taskRepository.watchTasks(),
                          builder: (context, taskSnapshot) {
                            final tasks =
                                taskSnapshot.data ?? const <AcademicTask>[];
                            return StreamBuilder<List<StudySession>>(
                              stream: _studyRepository.watchSessions(),
                              builder: (context, studySnapshot) {
                                final studySessions =
                                    studySnapshot.data ??
                                    const <StudySession>[];
                                return _TodayFocusPanel(
                                  subjects: subjects,
                                  sessions: sessions,
                                  tasks: tasks,
                                  studySessions: studySessions,
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
            ),
            const SizedBox(height: 20),
            Text(
              'Modulos principales',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 620;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: modules.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isWide ? 2 : 1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 126,
                  ),
                  itemBuilder: (context, index) {
                    return _ModuleCard(module: modules[index]);
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            const _RoadmapPanel(),
          ],
        ),
      ),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.colorOption});

  final AppColorOption colorOption;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [
            colorOption.gradientStart,
            colorOption.color,
            colorOption.gradientEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(24),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(36),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withAlpha(72)),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Image(
                      image: AssetImage('assets/logo/ma_u_logo_5.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const Spacer(),
                const _StatusChip(label: 'Semana activa'),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Centro de control universitario',
              style: textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Notas, horario, tareas, gastos y metas en una sola app.',
              style: textTheme.bodyLarge?.copyWith(
                color: Colors.white.withAlpha(224),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppTitle extends StatelessWidget {
  const _AppTitle();

  @override
  Widget build(BuildContext context) {
    return const MaUBrand();
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(36),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withAlpha(72)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DashboardPulseCard extends StatelessWidget {
  const _DashboardPulseCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              height: 28,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Sincronizando tu centro academico...',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TodayFocusPanel extends StatelessWidget {
  const _TodayFocusPanel({
    required this.subjects,
    required this.sessions,
    required this.tasks,
    required this.studySessions,
  });

  final List<Subject> subjects;
  final List<ClassSession> sessions;
  final List<AcademicTask> tasks;
  final List<StudySession> studySessions;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final activeSubjectIds = subjects.map((subject) => subject.id).toSet();
    final pendingTasks = tasks
        .where(
          (task) =>
              !task.isCompleted && activeSubjectIds.contains(task.subjectId),
        )
        .toList();
    final pendingStudy = studySessions
        .where(
          (session) =>
              !session.isCompleted &&
              activeSubjectIds.contains(session.subjectId),
        )
        .toList();
    pendingTasks.sort((a, b) {
      final aDate = a.dueDate ?? DateTime(9999);
      final bDate = b.dueDate ?? DateTime(9999);
      return aDate.compareTo(bDate);
    });
    pendingStudy.sort((a, b) {
      final aDate = a.startsAt ?? DateTime(9999);
      final bDate = b.startsAt ?? DateTime(9999);
      return aDate.compareTo(bDate);
    });

    final nextSession = _nextClassForToday();
    final nextTask = pendingTasks.isEmpty ? null : pendingTasks.first;
    final nextStudy = pendingStudy.isEmpty ? null : pendingStudy.first;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showDetails(
          context: context,
          nextSession: nextSession,
          nextTask: nextTask,
          nextStudy: nextStudy,
          pendingTasks: pendingTasks,
          pendingStudy: pendingStudy,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.bolt_outlined, color: colorScheme.primary),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Enfoque de hoy',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  _CompactCounter(
                    label: '${pendingTasks.length + pendingStudy.length}',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _FocusLine(
                icon: Icons.calendar_today_outlined,
                title: nextSession == null
                    ? 'Sin clases pendientes hoy'
                    : _subjectName(nextSession.subjectId),
                subtitle: nextSession == null
                    ? 'Buen momento para adelantar trabajo.'
                    : '${nextSession.timeRange} - ${nextSession.location}',
              ),
              const SizedBox(height: 10),
              _FocusLine(
                icon: Icons.task_alt_outlined,
                title: nextTask == null
                    ? 'Sin tareas pendientes'
                    : nextTask.title,
                subtitle: nextTask?.dueDate == null
                    ? 'No hay una entrega urgente registrada.'
                    : AppDateFormatter.dateWithOptionalTime(nextTask!.dueDate!),
              ),
              const SizedBox(height: 10),
              _FocusLine(
                icon: Icons.psychology_alt_outlined,
                title: nextStudy == null
                    ? 'Agenda tu proxima sesion'
                    : nextStudy.title,
                subtitle: nextStudy == null
                    ? 'Crea bloques cortos por materia.'
                    : '${nextStudy.durationMinutes} min - ${_subjectName(nextStudy.subjectId)}',
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetails({
    required BuildContext context,
    required ClassSession? nextSession,
    required AcademicTask? nextTask,
    required StudySession? nextStudy,
    required List<AcademicTask> pendingTasks,
    required List<StudySession> pendingStudy,
  }) {
    AppDetailBottomSheet.show(
      context: context,
      children: [
        Text(
          'Enfoque de hoy',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 14),
        _DashboardDetailRow(
          label: 'Proxima clase',
          value: nextSession == null
              ? 'Sin clases pendientes hoy'
              : '${_subjectName(nextSession.subjectId)} - ${nextSession.timeRange} - ${nextSession.location}',
        ),
        _DashboardDetailRow(
          label: 'Tarea mas cercana',
          value: nextTask == null
              ? 'Sin tareas pendientes'
              : _taskDetailText(nextTask),
        ),
        _DashboardDetailRow(
          label: 'Proximo bloque de estudio',
          value: nextStudy == null
              ? 'Sin sesiones pendientes'
              : _studyDetailText(nextStudy),
        ),
        _DashboardDetailRow(
          label: 'Pendientes',
          value:
              '${pendingTasks.length} tareas - ${pendingStudy.length} sesiones de estudio',
        ),
        if (pendingTasks.isNotEmpty) ...[
          const SizedBox(height: 8),
          const _DashboardSectionTitle('Tareas pendientes'),
          for (final task in pendingTasks.take(6))
            _DashboardDetailRow(
              label: _subjectName(task.subjectId),
              value: _taskDetailText(task),
            ),
        ],
        if (pendingStudy.isNotEmpty) ...[
          const SizedBox(height: 8),
          const _DashboardSectionTitle('Estudio pendiente'),
          for (final session in pendingStudy.take(6))
            _DashboardDetailRow(
              label: _subjectName(session.subjectId),
              value: _studyDetailText(session),
            ),
        ],
      ],
    );
  }

  ClassSession? _nextClassForToday() {
    final weekday = _weekdayFromDate(DateTime.now());
    if (weekday == null) {
      return null;
    }

    final now = DateTime.now();
    final currentMinute = now.hour * 60 + now.minute;
    final todaySessions =
        sessions
            .where(
              (session) =>
                  session.weekday == weekday &&
                  session.startsAtMinute >= currentMinute,
            )
            .toList()
          ..sort((a, b) => a.startsAtMinute.compareTo(b.startsAtMinute));

    return todaySessions.isEmpty ? null : todaySessions.first;
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

  String _taskDetailText(AcademicTask task) {
    final dueDate = task.dueDate;
    final dateText = dueDate == null
        ? 'sin fecha'
        : AppDateFormatter.dateWithOptionalTime(dueDate);
    return '${task.title} - ${task.priority.label} - $dateText';
  }

  String _studyDetailText(StudySession session) {
    final startsAt = session.startsAt;
    final dateText = startsAt == null
        ? 'sin fecha'
        : AppDateFormatter.dateWithOptionalTime(startsAt);
    return '${session.title} - ${session.durationMinutes} min - $dateText';
  }
}

class _DashboardSectionTitle extends StatelessWidget {
  const _DashboardSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _DashboardDetailRow extends StatelessWidget {
  const _DashboardDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
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
  }
}

class _FocusLine extends StatelessWidget {
  const _FocusLine({
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

    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer.withAlpha(128),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 19, color: colorScheme.onSecondaryContainer),
        ),
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
              const SizedBox(height: 2),
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CompactCounter extends StatelessWidget {
  const _CompactCounter({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colorScheme.onPrimaryContainer,
          fontSize: 12,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _DashboardModule {
  const _DashboardModule({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module});

  final _DashboardModule module;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withAlpha(isDark ? 34 : 22),
              module.color.withAlpha(isDark ? 24 : 14),
              Colors.transparent,
            ],
            stops: const [0, 0.58, 1],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: module.onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: module.color.withAlpha(isDark ? 56 : 46),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: module.color.withAlpha(isDark ? 96 : 72),
                    ),
                  ),
                  child: Icon(module.icon, color: module.color),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        module.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        module.subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  module.onTap == null ? Icons.lock_clock_outlined : Icons.east,
                  color: module.onTap == null
                      ? colorScheme.outline
                      : colorScheme.primary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoadmapPanel extends StatelessWidget {
  const _RoadmapPanel();

  static const items = [
    'Control de parciales',
    'Lista de materias',
    'Notas por semestre',
    'Gastos universitarios',
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.auto_awesome_outlined, color: colorScheme.primary),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Ideas buenas para construir despues',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final item in items) _RoadmapChip(label: item)],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoadmapChip extends StatelessWidget {
  const _RoadmapChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withAlpha(128),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
