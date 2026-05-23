import 'package:flutter/material.dart';

import '../../../core/widgets/destructive_confirmation_dialog.dart';
import '../../../data/database/app_database_provider.dart';
import '../../schedule/data/academic_seed_service.dart';
import '../../subjects/data/subject_repository.dart';
import '../../subjects/domain/subject.dart';
import '../data/schedule_repository.dart';
import '../domain/class_session.dart';

class AcademicPlannerScreen extends StatefulWidget {
  const AcademicPlannerScreen({super.key});

  @override
  State<AcademicPlannerScreen> createState() => _AcademicPlannerScreenState();
}

class _AcademicPlannerScreenState extends State<AcademicPlannerScreen> {
  late final SubjectRepository _subjectRepository;
  late final ScheduleRepository _scheduleRepository;
  late final Future<void> _seedFuture;

  @override
  void initState() {
    super.initState();
    final database = AppDatabaseProvider.instance;
    _subjectRepository = SubjectRepository(database);
    _scheduleRepository = ScheduleRepository(database);
    _seedFuture = AcademicSeedService(
      subjectRepository: _subjectRepository,
      scheduleRepository: _scheduleRepository,
    ).seedIfNeeded();
  }

  Future<void> _openSubjectForm() async {
    final subject = await showDialog<Subject>(
      context: context,
      builder: (_) => const _SubjectFormDialog(),
    );

    if (subject != null) {
      await _subjectRepository.saveSubject(subject);
    }
  }

  Future<void> _openSubjectEditor(Subject currentSubject) async {
    final subject = await showDialog<Subject>(
      context: context,
      builder: (_) => _SubjectFormDialog(initialSubject: currentSubject),
    );

    if (subject != null) {
      await _subjectRepository.saveSubject(subject);
    }
  }

  Future<void> _moveSubjectToTrash(Subject subject) async {
    final confirmed = await DestructiveConfirmationDialog.show(
      context: context,
      title: 'Mover materia a papelera',
      message:
          'La materia "${subject.name}" se ocultara de tus listas. Podras restaurarla desde Papelera.',
      confirmLabel: 'Mover',
    );

    if (confirmed) {
      await _subjectRepository.moveToTrash(subject.id);
    }
  }

  Future<void> _openSessionForm(List<Subject> subjects) async {
    final session = await showDialog<ClassSession>(
      context: context,
      builder: (_) => _SessionFormDialog(subjects: subjects),
    );

    if (session != null) {
      await _scheduleRepository.saveSession(session);
    }
  }

  Future<void> _openSessionEditor({
    required ClassSession currentSession,
    required List<Subject> subjects,
  }) async {
    final session = await showDialog<ClassSession>(
      context: context,
      builder: (_) => _SessionFormDialog(
        subjects: subjects,
        initialSession: currentSession,
      ),
    );

    if (session != null) {
      await _scheduleRepository.saveSession(session);
    }
  }

  Future<void> _moveSessionToTrash(ClassSession session) async {
    final id = session.id;
    if (id == null) {
      return;
    }

    final confirmed = await DestructiveConfirmationDialog.show(
      context: context,
      title: 'Mover clase a papelera',
      message:
          'Esta clase se ocultara del horario. Podras restaurarla despues.',
      confirmLabel: 'Mover',
    );

    if (confirmed) {
      await _scheduleRepository.moveToTrash(id);
    }
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

        if (seedSnapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Centro academico')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('No se pudo cargar la base local.'),
              ),
            ),
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
                return _AcademicPlannerView(
                  subjects: subjects,
                  sessions: sessions,
                  onAddSubject: _openSubjectForm,
                  onAddSession: () => _openSessionForm(subjects),
                  onEditSubject: _openSubjectEditor,
                  onDeleteSubject: _moveSubjectToTrash,
                  onEditSession: (session) => _openSessionEditor(
                    currentSession: session,
                    subjects: subjects,
                  ),
                  onDeleteSession: _moveSessionToTrash,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _AcademicPlannerView extends StatelessWidget {
  const _AcademicPlannerView({
    required this.subjects,
    required this.sessions,
    required this.onAddSubject,
    required this.onAddSession,
    required this.onEditSubject,
    required this.onDeleteSubject,
    required this.onEditSession,
    required this.onDeleteSession,
  });

  final List<Subject> subjects;
  final List<ClassSession> sessions;
  final VoidCallback onAddSubject;
  final VoidCallback onAddSession;
  final ValueChanged<Subject> onEditSubject;
  final ValueChanged<Subject> onDeleteSubject;
  final ValueChanged<ClassSession> onEditSession;
  final ValueChanged<ClassSession> onDeleteSession;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Builder(
        builder: (context) {
          final tabController = DefaultTabController.of(context);

          return AnimatedBuilder(
            animation: tabController,
            builder: (context, _) {
              final isScheduleTab = tabController.index == 0;

              return Scaffold(
                appBar: AppBar(
                  title: const Text('Centro academico'),
                  bottom: const TabBar(
                    tabs: [
                      Tab(
                        icon: Icon(Icons.calendar_month_outlined),
                        text: 'Horario',
                      ),
                      Tab(
                        icon: Icon(Icons.menu_book_outlined),
                        text: 'Materias',
                      ),
                    ],
                  ),
                ),
                floatingActionButton: FloatingActionButton.extended(
                  onPressed: isScheduleTab ? onAddSession : onAddSubject,
                  icon: Icon(
                    isScheduleTab
                        ? Icons.event_available_outlined
                        : Icons.add_outlined,
                  ),
                  label: Text(isScheduleTab ? 'Clase' : 'Materia'),
                ),
                body: SafeArea(
                  child: TabBarView(
                    children: [
                      _ScheduleTab(
                        subjects: subjects,
                        sessions: sessions,
                        onEditSession: onEditSession,
                        onDeleteSession: onDeleteSession,
                      ),
                      _SubjectsTab(
                        subjects: subjects,
                        onEditSubject: onEditSubject,
                        onDeleteSubject: onDeleteSubject,
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ScheduleTab extends StatelessWidget {
  const _ScheduleTab({
    required this.subjects,
    required this.sessions,
    required this.onEditSession,
    required this.onDeleteSession,
  });

  final List<Subject> subjects;
  final List<ClassSession> sessions;
  final ValueChanged<ClassSession> onEditSession;
  final ValueChanged<ClassSession> onDeleteSession;

  @override
  Widget build(BuildContext context) {
    final activeSubjectIds = subjects.map((subject) => subject.id).toSet();
    final sessionsByDay = {
      for (final day in Weekday.values)
        day:
            sessions
                .where(
                  (session) =>
                      session.weekday == day &&
                      activeSubjectIds.contains(session.subjectId),
                )
                .toList()
              ..sort((a, b) => a.startsAtMinute.compareTo(b.startsAtMinute)),
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
      children: [
        const _PlannerHeader(),
        const SizedBox(height: 16),
        for (final day in Weekday.values) ...[
          _DaySection(
            day: day,
            sessions: sessionsByDay[day] ?? const [],
            subjects: subjects,
            onEditSession: onEditSession,
            onDeleteSession: onDeleteSession,
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _PlannerHeader extends StatelessWidget {
  const _PlannerHeader();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.view_week_outlined,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Semana organizada',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                  SizedBox(height: 4),
                  Text('Revisa clases, salones y materias en un solo lugar.'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DaySection extends StatelessWidget {
  const _DaySection({
    required this.day,
    required this.sessions,
    required this.subjects,
    required this.onEditSession,
    required this.onDeleteSession,
  });

  final Weekday day;
  final List<ClassSession> sessions;
  final List<Subject> subjects;
  final ValueChanged<ClassSession> onEditSession;
  final ValueChanged<ClassSession> onDeleteSession;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          day.label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 8),
        if (sessions.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Text(
              'Sin clases programadas',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          )
        else
          for (final session in sessions) ...[
            _SessionCard(
              session: session,
              subject: subjects.firstWhere(
                (subject) => subject.id == session.subjectId,
              ),
              onEdit: () => onEditSession(session),
              onDelete: () => onDeleteSession(session),
            ),
            const SizedBox(height: 8),
          ],
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  const _SessionCard({
    required this.session,
    required this.subject,
    required this.onEdit,
    required this.onDelete,
  });

  final ClassSession session;
  final Subject subject;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final subjectColor = Color(subject.accentColorValue);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showSessionDetails(context),
        onLongPress: () => _showSessionActions(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 5,
                height: 58,
                decoration: BoxDecoration(
                  color: subjectColor,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${session.timeRange} - ${session.location}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _MiniBadge(label: subject.credits.toString()),
              PopupMenuButton<_ItemAction>(
                tooltip: 'Opciones de clase',
                onSelected: (action) {
                  switch (action) {
                    case _ItemAction.view:
                      _showSessionDetails(context);
                    case _ItemAction.edit:
                      onEdit();
                    case _ItemAction.delete:
                      onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _ItemAction.view,
                    child: Text('Ver detalle'),
                  ),
                  PopupMenuItem(value: _ItemAction.edit, child: Text('Editar')),
                  PopupMenuItem(
                    value: _ItemAction.delete,
                    child: Text('Mover a papelera'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSessionDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 14),
                _AcademicDetailRow(label: 'Dia', value: session.weekday.label),
                _AcademicDetailRow(label: 'Horario', value: session.timeRange),
                _AcademicDetailRow(label: 'Salon', value: session.location),
                _AcademicDetailRow(label: 'Docente', value: subject.teacher),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onEdit();
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Editar'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onDelete();
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Papelera'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSessionActions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => _ActionSheet(
        onView: () {
          Navigator.of(context).pop();
          _showSessionDetails(context);
        },
        onEdit: () {
          Navigator.of(context).pop();
          onEdit();
        },
        onDelete: () {
          Navigator.of(context).pop();
          onDelete();
        },
      ),
    );
  }
}

class _SubjectsTab extends StatelessWidget {
  const _SubjectsTab({
    required this.subjects,
    required this.onEditSubject,
    required this.onDeleteSubject,
  });

  final List<Subject> subjects;
  final ValueChanged<Subject> onEditSubject;
  final ValueChanged<Subject> onDeleteSubject;

  @override
  Widget build(BuildContext context) {
    final totalCredits = subjects.fold<int>(
      0,
      (total, subject) => total + subject.credits,
    );

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 96),
      children: [
        _SubjectSummary(subjectCount: subjects.length, credits: totalCredits),
        const SizedBox(height: 16),
        for (final subject in subjects) ...[
          _SubjectCard(
            subject: subject,
            onEdit: () => onEditSubject(subject),
            onDelete: () => onDeleteSubject(subject),
          ),
          const SizedBox(height: 10),
        ],
      ],
    );
  }
}

class _SubjectSummary extends StatelessWidget {
  const _SubjectSummary({required this.subjectCount, required this.credits});

  final int subjectCount;
  final int credits;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryTile(
            icon: Icons.menu_book_outlined,
            value: subjectCount.toString(),
            label: 'Materias',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryTile(
            icon: Icons.school_outlined,
            value: credits.toString(),
            label: 'Creditos',
          ),
        ),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: colorScheme.primary),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
            Text(label, style: TextStyle(color: colorScheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({
    required this.subject,
    required this.onEdit,
    required this.onDelete,
  });

  final Subject subject;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final subjectColor = Color(subject.accentColorValue);
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showSubjectDetails(context),
        onLongPress: () => _showSubjectActions(context),
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
                child: Icon(Icons.book_outlined, color: subjectColor),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${subject.teacher} - ${subject.room}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _MiniBadge(label: '${subject.credits} cr'),
              PopupMenuButton<_ItemAction>(
                tooltip: 'Opciones de materia',
                onSelected: (action) {
                  switch (action) {
                    case _ItemAction.view:
                      _showSubjectDetails(context);
                    case _ItemAction.edit:
                      onEdit();
                    case _ItemAction.delete:
                      onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _ItemAction.view,
                    child: Text('Ver detalle'),
                  ),
                  PopupMenuItem(value: _ItemAction.edit, child: Text('Editar')),
                  PopupMenuItem(
                    value: _ItemAction.delete,
                    child: Text('Mover a papelera'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSubjectDetails(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  subject.name,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 14),
                _AcademicDetailRow(label: 'Docente', value: subject.teacher),
                _AcademicDetailRow(label: 'Salon', value: subject.room),
                _AcademicDetailRow(
                  label: 'Creditos',
                  value: subject.credits.toString(),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onEdit();
                        },
                        icon: const Icon(Icons.edit_outlined),
                        label: const Text('Editar'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () {
                          Navigator.of(context).pop();
                          onDelete();
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Papelera'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSubjectActions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) => _ActionSheet(
        onView: () {
          Navigator.of(context).pop();
          _showSubjectDetails(context);
        },
        onEdit: () {
          Navigator.of(context).pop();
          onEdit();
        },
        onDelete: () {
          Navigator.of(context).pop();
          onDelete();
        },
      ),
    );
  }
}

enum _ItemAction { view, edit, delete }

class _ActionSheet extends StatelessWidget {
  const _ActionSheet({
    required this.onView,
    required this.onEdit,
    required this.onDelete,
  });

  final VoidCallback onView;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility_outlined),
              title: const Text('Ver detalle'),
              onTap: onView,
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text('Editar'),
              onTap: onEdit,
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: const Text('Mover a papelera'),
              onTap: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

class _AcademicDetailRow extends StatelessWidget {
  const _AcademicDetailRow({required this.label, required this.value});

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

class _SubjectFormDialog extends StatefulWidget {
  const _SubjectFormDialog({this.initialSubject});

  final Subject? initialSubject;

  @override
  State<_SubjectFormDialog> createState() => _SubjectFormDialogState();
}

class _SubjectFormDialogState extends State<_SubjectFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _teacherController = TextEditingController();
  final _roomController = TextEditingController();
  final _creditsController = TextEditingController(text: '3');
  int _accentColorValue = _subjectColors.first;

  static const _subjectColors = [
    0xFF2563EB,
    0xFF0F766E,
    0xFF7C3AED,
    0xFFDC6B19,
    0xFFBE123C,
    0xFF16A34A,
  ];

  @override
  void initState() {
    super.initState();
    final subject = widget.initialSubject;
    if (subject != null) {
      _nameController.text = subject.name;
      _teacherController.text = subject.teacher;
      _roomController.text = subject.room;
      _creditsController.text = subject.credits.toString();
      _accentColorValue = subject.accentColorValue;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _teacherController.dispose();
    _roomController.dispose();
    _creditsController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      Subject(
        id:
            widget.initialSubject?.id ??
            DateTime.now().microsecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        teacher: _teacherController.text.trim(),
        room: _roomController.text.trim(),
        credits: int.parse(_creditsController.text.trim()),
        accentColorValue: _accentColorValue,
        deletedAt: widget.initialSubject?.deletedAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialSubject == null ? 'Nueva materia' : 'Editar materia',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _DialogTextField(label: 'Materia', controller: _nameController),
              const SizedBox(height: 10),
              _DialogTextField(
                label: 'Docente',
                controller: _teacherController,
              ),
              const SizedBox(height: 10),
              _DialogTextField(label: 'Salon', controller: _roomController),
              const SizedBox(height: 10),
              _DialogTextField(
                label: 'Creditos',
                controller: _creditsController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  final credits = int.tryParse(value ?? '');
                  if (credits == null || credits <= 0 || credits > 10) {
                    return 'Usa un numero entre 1 y 10.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 8,
                children: [
                  for (final colorValue in _subjectColors)
                    _ColorDot(
                      color: Color(colorValue),
                      isSelected: _accentColorValue == colorValue,
                      onTap: () {
                        setState(() {
                          _accentColorValue = colorValue;
                        });
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _save, child: const Text('Guardar')),
      ],
    );
  }
}

class _SessionFormDialog extends StatefulWidget {
  const _SessionFormDialog({required this.subjects, this.initialSession});

  final List<Subject> subjects;
  final ClassSession? initialSession;

  @override
  State<_SessionFormDialog> createState() => _SessionFormDialogState();
}

class _SessionFormDialogState extends State<_SessionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _startController = TextEditingController(text: '07:00');
  final _endController = TextEditingController(text: '09:00');
  final _locationController = TextEditingController();
  late String _subjectId;
  Weekday _weekday = Weekday.monday;

  @override
  void initState() {
    super.initState();
    final session = widget.initialSession;
    _subjectId =
        session?.subjectId ??
        (widget.subjects.isEmpty ? '' : widget.subjects.first.id);
    if (session != null) {
      _weekday = session.weekday;
      _startController.text = _formatMinute(session.startsAtMinute);
      _endController.text = _formatMinute(session.endsAtMinute);
      _locationController.text = session.location;
    }
  }

  @override
  void dispose() {
    _startController.dispose();
    _endController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  int? _parseTime(String value) {
    final parts = value.trim().split(':');
    if (parts.length != 2) {
      return null;
    }

    final hour = int.tryParse(parts[0]);
    final minute = int.tryParse(parts[1]);
    if (hour == null || minute == null) {
      return null;
    }

    if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
      return null;
    }

    return hour * 60 + minute;
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final startsAt = _parseTime(_startController.text)!;
    final endsAt = _parseTime(_endController.text)!;

    if (endsAt <= startsAt) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La hora final debe ser mayor.')),
      );
      return;
    }

    Navigator.of(context).pop(
      ClassSession(
        id: widget.initialSession?.id,
        subjectId: _subjectId,
        weekday: _weekday,
        startsAtMinute: startsAt,
        endsAtMinute: endsAt,
        location: _locationController.text.trim(),
        deletedAt: widget.initialSession?.deletedAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.subjects.isEmpty) {
      return AlertDialog(
        title: const Text('Nueva clase'),
        content: const Text('Primero crea una materia.'),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Entendido'),
          ),
        ],
      );
    }

    return AlertDialog(
      title: Text(
        widget.initialSession == null ? 'Nueva clase' : 'Editar clase',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: _subjectId,
                decoration: const InputDecoration(labelText: 'Materia'),
                items: [
                  for (final subject in widget.subjects)
                    DropdownMenuItem(
                      value: subject.id,
                      child: Text(subject.name),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _subjectId = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<Weekday>(
                initialValue: _weekday,
                decoration: const InputDecoration(labelText: 'Dia'),
                items: [
                  for (final day in Weekday.values)
                    DropdownMenuItem(value: day, child: Text(day.label)),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _weekday = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _DialogTextField(
                      label: 'Inicio',
                      controller: _startController,
                      hintText: '07:00',
                      validator: _timeValidator,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _DialogTextField(
                      label: 'Fin',
                      controller: _endController,
                      hintText: '09:00',
                      validator: _timeValidator,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _DialogTextField(label: 'Salon', controller: _locationController),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _save, child: const Text('Guardar')),
      ],
    );
  }

  String? _timeValidator(String? value) {
    if (_parseTime(value ?? '') == null) {
      return 'HH:mm';
    }
    return null;
  }

  String _formatMinute(int minuteOfDay) {
    final hour = minuteOfDay ~/ 60;
    final minute = minuteOfDay % 60;
    return '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
  }
}

class _DialogTextField extends StatelessWidget {
  const _DialogTextField({
    required this.label,
    required this.controller,
    this.keyboardType,
    this.hintText,
    this.validator,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? hintText;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(labelText: label, hintText: hintText),
      validator:
          validator ??
          (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Campo requerido.';
            }
            return null;
          },
    );
  }
}

class _ColorDot extends StatelessWidget {
  const _ColorDot({
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.onSurface
                : Colors.transparent,
            width: 3,
          ),
        ),
        child: isSelected
            ? const Icon(Icons.check, color: Colors.white, size: 18)
            : const SizedBox.shrink(),
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge({required this.label});

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
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
