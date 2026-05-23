import 'package:flutter/material.dart';

import '../../../core/formatters/app_date_formatter.dart';
import '../../../core/widgets/app_detail_bottom_sheet.dart';
import '../../../core/widgets/destructive_confirmation_dialog.dart';
import '../../../data/database/app_database_provider.dart';
import '../../schedule/data/academic_seed_service.dart';
import '../../schedule/data/schedule_repository.dart';
import '../../subjects/data/subject_repository.dart';
import '../../subjects/domain/subject.dart';
import '../data/study_session_repository.dart';
import '../domain/study_session.dart';

class StudyAgendaScreen extends StatefulWidget {
  const StudyAgendaScreen({super.key});

  @override
  State<StudyAgendaScreen> createState() => _StudyAgendaScreenState();
}

class _StudyAgendaScreenState extends State<StudyAgendaScreen> {
  late final SubjectRepository _subjectRepository;
  late final ScheduleRepository _scheduleRepository;
  late final StudySessionRepository _studyRepository;
  late final Future<void> _seedFuture;

  @override
  void initState() {
    super.initState();
    final database = AppDatabaseProvider.instance;
    _subjectRepository = SubjectRepository(database);
    _scheduleRepository = ScheduleRepository(database);
    _studyRepository = StudySessionRepository(database);
    _seedFuture = AcademicSeedService(
      subjectRepository: _subjectRepository,
      scheduleRepository: _scheduleRepository,
    ).seedIfNeeded();
  }

  Future<void> _openForm(
    List<Subject> subjects, {
    StudySession? initialSession,
  }) async {
    final session = await showDialog<StudySession>(
      context: context,
      builder: (_) => _StudySessionFormDialog(
        subjects: subjects,
        initialSession: initialSession,
      ),
    );

    if (session != null) {
      await _studyRepository.saveSession(session);
    }
  }

  Future<void> _toggleSession(StudySession session) async {
    final id = session.id;
    if (id == null) {
      return;
    }

    await _studyRepository.setCompleted(
      id: id,
      isCompleted: !session.isCompleted,
    );
  }

  Future<void> _moveToTrash(StudySession session) async {
    final id = session.id;
    if (id == null) {
      return;
    }

    final confirmed = await DestructiveConfirmationDialog.show(
      context: context,
      title: 'Mover sesion a papelera',
      message:
          'La sesion "${session.title}" se ocultara de tu agenda. Podras restaurarla despues.',
      confirmLabel: 'Mover',
    );

    if (confirmed) {
      await _studyRepository.moveToTrash(id);
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

        return StreamBuilder<List<Subject>>(
          stream: _subjectRepository.watchSubjects(),
          builder: (context, subjectSnapshot) {
            final subjects = subjectSnapshot.data ?? const <Subject>[];

            return StreamBuilder<List<StudySession>>(
              stream: _studyRepository.watchSessions(),
              builder: (context, studySnapshot) {
                final sessions = studySnapshot.data ?? const <StudySession>[];
                return _StudyAgendaView(
                  subjects: subjects,
                  sessions: sessions,
                  onAdd: () => _openForm(subjects),
                  onEdit: (session) =>
                      _openForm(subjects, initialSession: session),
                  onToggle: _toggleSession,
                  onDelete: _moveToTrash,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _StudyAgendaView extends StatefulWidget {
  const _StudyAgendaView({
    required this.subjects,
    required this.sessions,
    required this.onAdd,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final List<Subject> subjects;
  final List<StudySession> sessions;
  final VoidCallback onAdd;
  final ValueChanged<StudySession> onEdit;
  final ValueChanged<StudySession> onToggle;
  final ValueChanged<StudySession> onDelete;

  @override
  State<_StudyAgendaView> createState() => _StudyAgendaViewState();
}

class _StudyAgendaViewState extends State<_StudyAgendaView> {
  _StudyFilter _filter = _StudyFilter.pending;

  @override
  Widget build(BuildContext context) {
    final activeSubjectIds = widget.subjects
        .map((subject) => subject.id)
        .toSet();
    final visibleSessions = widget.sessions
        .where((session) => activeSubjectIds.contains(session.subjectId))
        .where(_matchesFilter)
        .toList();
    final pendingCount = widget.sessions
        .where((session) => activeSubjectIds.contains(session.subjectId))
        .where((session) => !session.isCompleted)
        .length;
    final totalMinutes = widget.sessions
        .where((session) => activeSubjectIds.contains(session.subjectId))
        .where((session) => !session.isCompleted)
        .fold<int>(0, (total, session) => total + session.durationMinutes);

    return Scaffold(
      appBar: AppBar(title: const Text('Agenda de estudio')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.onAdd,
        icon: const Icon(Icons.add_outlined),
        label: const Text('Estudio'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
          children: [
            _StudySummary(
              pendingCount: pendingCount,
              totalMinutes: totalMinutes,
            ),
            const SizedBox(height: 16),
            _StudyFilterBar(
              selected: _filter,
              onSelected: (filter) {
                setState(() {
                  _filter = filter;
                });
              },
            ),
            const SizedBox(height: 16),
            if (visibleSessions.isEmpty)
              const _EmptyStudyCard()
            else
              for (final session in visibleSessions) ...[
                _StudySessionCard(
                  session: session,
                  subject: widget.subjects.firstWhere(
                    (subject) => subject.id == session.subjectId,
                  ),
                  onEdit: () => widget.onEdit(session),
                  onToggle: () => widget.onToggle(session),
                  onDelete: () => widget.onDelete(session),
                ),
                const SizedBox(height: 10),
              ],
          ],
        ),
      ),
    );
  }

  bool _matchesFilter(StudySession session) {
    return switch (_filter) {
      _StudyFilter.all => true,
      _StudyFilter.pending => !session.isCompleted,
      _StudyFilter.exam =>
        !session.isCompleted && session.focusLevel == FocusLevel.exam,
      _StudyFilter.completed => session.isCompleted,
    };
  }
}

enum _StudyFilter {
  all('Todas'),
  pending('Pendientes'),
  exam('Parciales'),
  completed('Completadas');

  const _StudyFilter(this.label);

  final String label;
}

class _StudyFilterBar extends StatelessWidget {
  const _StudyFilterBar({required this.selected, required this.onSelected});

  final _StudyFilter selected;
  final ValueChanged<_StudyFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in _StudyFilter.values) ...[
            ChoiceChip(
              label: Text(filter.label),
              selected: selected == filter,
              onSelected: (_) => onSelected(filter),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _StudySummary extends StatelessWidget {
  const _StudySummary({required this.pendingCount, required this.totalMinutes});

  final int pendingCount;
  final int totalMinutes;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    final timeLabel = hours == 0 ? '${minutes}m' : '${hours}h ${minutes}m';

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
                Icons.psychology_alt_outlined,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Plan de enfoque',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text('$pendingCount pendientes - $timeLabel por estudiar'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyStudyCard extends StatelessWidget {
  const _EmptyStudyCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(
              Icons.self_improvement_outlined,
              color: colorScheme.primary,
              size: 38,
            ),
            const SizedBox(height: 10),
            const Text(
              'Sin sesiones todavia',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              'Planea repasos, lectura, talleres o preparacion de parciales.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudySessionCard extends StatelessWidget {
  const _StudySessionCard({
    required this.session,
    required this.subject,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final StudySession session;
  final Subject subject;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final subjectColor = Color(subject.accentColorValue);
    final colorScheme = Theme.of(context).colorScheme;
    final startsAt = session.startsAt;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showDetails(context),
        onLongPress: () => _showActions(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: session.isCompleted,
                onChanged: (_) => onToggle(),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        decoration: session.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subject.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StudyChip(label: subject.name, color: subjectColor),
                        _StudyChip(
                          label: session.focusLevel.label,
                          color: _focusColor(session.focusLevel),
                        ),
                        _StudyChip(
                          label: '${session.durationMinutes} min',
                          color: colorScheme.primary,
                        ),
                        if (startsAt != null)
                          _StudyChip(
                            label: AppDateFormatter.dateWithOptionalTime(
                              startsAt,
                            ),
                            color: const Color(0xFF0F766E),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_StudyAction>(
                tooltip: 'Opciones de estudio',
                onSelected: (action) {
                  switch (action) {
                    case _StudyAction.view:
                      _showDetails(context);
                    case _StudyAction.edit:
                      onEdit();
                    case _StudyAction.delete:
                      onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _StudyAction.view,
                    child: Text('Ver detalle'),
                  ),
                  PopupMenuItem(
                    value: _StudyAction.edit,
                    child: Text('Editar'),
                  ),
                  PopupMenuItem(
                    value: _StudyAction.delete,
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

  void _showDetails(BuildContext context) {
    final startsAt = session.startsAt;
    final deletedAt = session.deletedAt;

    AppDetailBottomSheet.show(
      context: context,
      children: [
        Text(
          session.title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 14),
        _StudyDetailRow(label: 'Materia', value: subject.name),
        _StudyDetailRow(label: 'Enfoque', value: session.focusLevel.label),
        _StudyDetailRow(
          label: 'Duracion',
          value: '${session.durationMinutes} minutos',
        ),
        _StudyDetailRow(
          label: 'Estado',
          value: session.isCompleted ? 'Completada' : 'Pendiente',
        ),
        if (startsAt != null)
          _StudyDetailRow(
            label: 'Fecha',
            value: AppDateFormatter.dateWithOptionalTime(startsAt),
          ),
        if (session.notes.isNotEmpty)
          _StudyDetailRow(label: 'Notas', value: session.notes),
        if (deletedAt != null)
          _StudyDetailRow(
            label: 'Movida a papelera',
            value: AppDateFormatter.dateTime(deletedAt),
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
    );
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.visibility_outlined),
                  title: const Text('Ver detalle'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showDetails(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Editar'),
                  onTap: () {
                    Navigator.of(context).pop();
                    onEdit();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Mover a papelera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    onDelete();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Color _focusColor(FocusLevel focusLevel) {
    return switch (focusLevel) {
      FocusLevel.light => const Color(0xFF16A34A),
      FocusLevel.deep => const Color(0xFF2563EB),
      FocusLevel.exam => const Color(0xFFBE123C),
    };
  }
}

enum _StudyAction { view, edit, delete }

class _StudyDetailRow extends StatelessWidget {
  const _StudyDetailRow({required this.label, required this.value});

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

class _StudyChip extends StatelessWidget {
  const _StudyChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(36),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _StudySessionFormDialog extends StatefulWidget {
  const _StudySessionFormDialog({required this.subjects, this.initialSession});

  final List<Subject> subjects;
  final StudySession? initialSession;

  @override
  State<_StudySessionFormDialog> createState() =>
      _StudySessionFormDialogState();
}

class _StudySessionFormDialogState extends State<_StudySessionFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();
  final _durationController = TextEditingController(text: '45');
  late String _subjectId;
  FocusLevel _focusLevel = FocusLevel.deep;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  @override
  void initState() {
    super.initState();
    final session = widget.initialSession;
    _subjectId =
        session?.subjectId ??
        (widget.subjects.isEmpty ? '' : widget.subjects.first.id);
    if (session != null) {
      _titleController.text = session.title;
      _notesController.text = session.notes;
      _durationController.text = session.durationMinutes.toString();
      _focusLevel = session.focusLevel;
      final startsAt = session.startsAt;
      if (startsAt != null) {
        _selectedDate = startsAt;
        if (startsAt.hour != 0 || startsAt.minute != 0) {
          _selectedTime = TimeOfDay(
            hour: startsAt.hour,
            minute: startsAt.minute,
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (selectedDate != null) {
      setState(() {
        _selectedDate = selectedDate;
      });
    }
  }

  Future<void> _pickTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );

    if (selectedTime != null) {
      setState(() {
        _selectedTime = selectedTime;
      });
    }
  }

  void _clearDateTime() {
    setState(() {
      _selectedDate = null;
      _selectedTime = null;
    });
  }

  void _clearTime() {
    setState(() {
      _selectedTime = null;
    });
  }

  DateTime? _buildStartsAt() {
    final selectedDate = _selectedDate;
    if (selectedDate == null) {
      return null;
    }

    final selectedTime = _selectedTime;
    return DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime?.hour ?? 0,
      selectedTime?.minute ?? 0,
    );
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      StudySession(
        id: widget.initialSession?.id,
        subjectId: _subjectId,
        title: _titleController.text.trim(),
        notes: _notesController.text.trim(),
        startsAt: _buildStartsAt(),
        durationMinutes: int.parse(_durationController.text.trim()),
        focusLevel: _focusLevel,
        isCompleted: widget.initialSession?.isCompleted ?? false,
        deletedAt: widget.initialSession?.deletedAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.subjects.isEmpty) {
      return AlertDialog(
        title: const Text('Nueva sesion'),
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
        widget.initialSession == null
            ? 'Nueva sesion de estudio'
            : 'Editar sesion',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titulo'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Campo requerido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Notas'),
              ),
              const SizedBox(height: 10),
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
              DropdownButtonFormField<FocusLevel>(
                initialValue: _focusLevel,
                decoration: const InputDecoration(labelText: 'Enfoque'),
                items: [
                  for (final focusLevel in FocusLevel.values)
                    DropdownMenuItem(
                      value: focusLevel,
                      child: Text(focusLevel.label),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _focusLevel = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Duracion en minutos',
                ),
                validator: (value) {
                  final duration = int.tryParse(value ?? '');
                  if (duration == null || duration < 5 || duration > 600) {
                    return 'Usa un valor entre 5 y 600.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.event_outlined),
                label: Text(
                  _selectedDate == null
                      ? 'Elegir fecha'
                      : 'Fecha ${AppDateFormatter.date(_selectedDate!)}',
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _selectedDate == null ? null : _pickTime,
                icon: const Icon(Icons.schedule_outlined),
                label: Text(
                  _selectedTime == null
                      ? 'Hora opcional'
                      : 'Hora ${_selectedTime!.format(context)}',
                ),
              ),
              if (_selectedDate != null) ...[
                const SizedBox(height: 6),
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  children: [
                    TextButton.icon(
                      onPressed: _clearTime,
                      icon: const Icon(Icons.schedule_send_outlined),
                      label: const Text('Quitar hora'),
                    ),
                    TextButton.icon(
                      onPressed: _clearDateTime,
                      icon: const Icon(Icons.close),
                      label: const Text('Quitar fecha'),
                    ),
                  ],
                ),
              ],
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
