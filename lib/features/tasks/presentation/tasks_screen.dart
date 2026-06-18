import 'package:flutter/material.dart';

import '../../../core/formatters/app_date_formatter.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/settings/app_settings_repository.dart';
import '../../../core/widgets/app_detail_bottom_sheet.dart';
import '../../../core/widgets/destructive_confirmation_dialog.dart';
import '../../../data/database/app_database_provider.dart';
import '../../schedule/data/academic_seed_service.dart';
import '../../schedule/data/schedule_repository.dart';
import '../../subjects/data/subject_repository.dart';
import '../../subjects/domain/subject.dart';
import '../data/task_repository.dart';
import '../domain/academic_task.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key, this.initialSubjectId});

  final String? initialSubjectId;

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late final SubjectRepository _subjectRepository;
  late final ScheduleRepository _scheduleRepository;
  late final TaskRepository _taskRepository;
  late final AppSettingsRepository _settingsRepository;
  late final Future<void> _seedFuture;

  @override
  void initState() {
    super.initState();
    final database = AppDatabaseProvider.instance;
    _subjectRepository = SubjectRepository(database);
    _scheduleRepository = ScheduleRepository(database);
    _taskRepository = TaskRepository(database);
    _settingsRepository = AppSettingsRepository(database);
    _seedFuture = AcademicSeedService(
      subjectRepository: _subjectRepository,
      scheduleRepository: _scheduleRepository,
    ).seedIfNeeded();
  }

  Future<void> _openTaskForm(
    List<Subject> subjects, {
    AcademicTask? initialTask,
  }) async {
    final defaultReminderMinutes =
        await _settingsRepository.getTaskReminderMinutes() ??
        MaUNotifications.defaultTaskReminderMinutes;
    if (!mounted) {
      return;
    }

    final task = await showDialog<AcademicTask>(
      context: context,
      builder: (_) => _TaskFormDialog(
        subjects: subjects,
        initialTask: initialTask,
        defaultReminderMinutes: defaultReminderMinutes,
      ),
    );

    if (task != null) {
      await _taskRepository.saveTask(task);
    }
  }

  Future<void> _toggleTask(AcademicTask task) async {
    final id = task.id;
    if (id == null) {
      return;
    }

    await _taskRepository.setCompleted(id: id, isCompleted: !task.isCompleted);
  }

  Future<void> _deleteTask(AcademicTask task) async {
    final id = task.id;
    if (id == null) {
      return;
    }

    final confirmed = await DestructiveConfirmationDialog.show(
      context: context,
      title: 'Mover a papelera',
      message:
          'La tarea "${task.title}" se movera a la papelera. Podras restaurarla despues.',
      confirmLabel: 'Mover',
    );

    if (!confirmed) {
      return;
    }

    await _taskRepository.moveToTrash(id);
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
                return _TasksView(
                  subjects: subjects,
                  tasks: tasks,
                  initialSubjectId: widget.initialSubjectId,
                  onAddTask: () => _openTaskForm(subjects),
                  onEditTask: (task) =>
                      _openTaskForm(subjects, initialTask: task),
                  onToggleTask: _toggleTask,
                  onDeleteTask: _deleteTask,
                );
              },
            );
          },
        );
      },
    );
  }
}

class _TasksView extends StatefulWidget {
  const _TasksView({
    required this.subjects,
    required this.tasks,
    required this.initialSubjectId,
    required this.onAddTask,
    required this.onEditTask,
    required this.onToggleTask,
    required this.onDeleteTask,
  });

  final List<Subject> subjects;
  final List<AcademicTask> tasks;
  final String? initialSubjectId;
  final VoidCallback onAddTask;
  final ValueChanged<AcademicTask> onEditTask;
  final ValueChanged<AcademicTask> onToggleTask;
  final ValueChanged<AcademicTask> onDeleteTask;

  @override
  State<_TasksView> createState() => _TasksViewState();
}

class _TasksViewState extends State<_TasksView> {
  _TaskFilter _filter = _TaskFilter.pending;

  @override
  Widget build(BuildContext context) {
    final scopedTasks = widget.initialSubjectId == null
        ? widget.tasks
        : widget.tasks
              .where((task) => task.subjectId == widget.initialSubjectId)
              .toList();
    final pendingCount = scopedTasks.where((task) => !task.isCompleted).length;
    final completedCount = scopedTasks.length - pendingCount;
    final filteredTasks = scopedTasks.where(_matchesFilter).toList();
    final selectedSubject = _subjectFor(widget.initialSubjectId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedSubject == null
              ? 'Tareas'
              : 'Tareas de ${selectedSubject.name}',
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.onAddTask,
        icon: const Icon(Icons.add_task_outlined),
        label: const Text('Tarea'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
          children: [
            _TasksSummary(
              pendingCount: pendingCount,
              completedCount: completedCount,
            ),
            const SizedBox(height: 16),
            _TaskFilterBar(
              selected: _filter,
              onSelected: (filter) {
                setState(() {
                  _filter = filter;
                });
              },
            ),
            const SizedBox(height: 16),
            if (filteredTasks.isEmpty)
              const _EmptyTasksCard()
            else
              for (final task in filteredTasks) ...[
                _TaskCard(
                  task: task,
                  subject: widget.subjects.firstWhere(
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
                  onEdit: () => widget.onEditTask(task),
                  onToggle: () => widget.onToggleTask(task),
                  onDelete: () => widget.onDeleteTask(task),
                ),
                const SizedBox(height: 10),
              ],
          ],
        ),
      ),
    );
  }

  Subject? _subjectFor(String? subjectId) {
    if (subjectId == null) {
      return null;
    }

    for (final subject in widget.subjects) {
      if (subject.id == subjectId) {
        return subject;
      }
    }

    return null;
  }

  bool _matchesFilter(AcademicTask task) {
    return switch (_filter) {
      _TaskFilter.all => true,
      _TaskFilter.pending => !task.isCompleted,
      _TaskFilter.critical =>
        !task.isCompleted && task.priority == TaskPriority.high,
      _TaskFilter.completed => task.isCompleted,
    };
  }
}

enum _TaskFilter {
  all('Todas'),
  pending('Pendientes'),
  critical('Criticas'),
  completed('Completadas');

  const _TaskFilter(this.label);

  final String label;
}

class _TaskFilterBar extends StatelessWidget {
  const _TaskFilterBar({required this.selected, required this.onSelected});

  final _TaskFilter selected;
  final ValueChanged<_TaskFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in _TaskFilter.values) ...[
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

class _TasksSummary extends StatelessWidget {
  const _TasksSummary({
    required this.pendingCount,
    required this.completedCount,
  });

  final int pendingCount;
  final int completedCount;

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
                Icons.task_alt_outlined,
                color: colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Control de entregas',
                    style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$pendingCount pendientes - $completedCount completadas',
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

class _EmptyTasksCard extends StatelessWidget {
  const _EmptyTasksCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(Icons.inbox_outlined, color: colorScheme.primary, size: 38),
            const SizedBox(height: 10),
            const Text(
              'Sin tareas todavia',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              'Crea entregas, lecturas, proyectos o parciales por materia.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.subject,
    required this.onEdit,
    required this.onToggle,
    required this.onDelete,
  });

  final AcademicTask task;
  final Subject subject;
  final VoidCallback onEdit;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final subjectColor = Color(subject.accentColorValue);
    final colorScheme = Theme.of(context).colorScheme;
    final dueDate = task.dueDate;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showTaskDetails(context),
        onLongPress: () => _showTaskActions(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(value: task.isCompleted, onChanged: (_) => onToggle()),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        decoration: task.isCompleted
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                    if (task.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        task.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _TaskChip(label: subject.name, color: subjectColor),
                        _TaskChip(
                          label: task.priority.label,
                          color: _priorityColor(task.priority),
                        ),
                        if (dueDate != null)
                          _TaskChip(
                            label: AppDateFormatter.dateWithOptionalTime(
                              dueDate,
                            ),
                            color: colorScheme.primary,
                          ),
                        if (task.reminderEnabled && dueDate != null)
                          _TaskChip(
                            label: _reminderLabel(task.reminderMinutesBefore),
                            color: const Color(0xFF7C3AED),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_TaskAction>(
                tooltip: 'Opciones de tarea',
                onSelected: (action) {
                  switch (action) {
                    case _TaskAction.view:
                      _showTaskDetails(context);
                    case _TaskAction.edit:
                      onEdit();
                    case _TaskAction.delete:
                      onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _TaskAction.view,
                    child: Text('Ver detalle'),
                  ),
                  PopupMenuItem(value: _TaskAction.edit, child: Text('Editar')),
                  PopupMenuItem(
                    value: _TaskAction.delete,
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

  void _showTaskDetails(BuildContext context) {
    final dueDate = task.dueDate;
    final deletedAt = task.deletedAt;

    AppDetailBottomSheet.show(
      context: context,
      children: [
        Text(
          task.title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 14),
        _TaskDetailRow(label: 'Materia', value: subject.name),
        _TaskDetailRow(label: 'Prioridad', value: task.priority.label),
        _TaskDetailRow(
          label: 'Estado',
          value: task.isCompleted ? 'Completada' : 'Pendiente',
        ),
        if (dueDate != null)
          _TaskDetailRow(
            label: 'Fecha limite',
            value: AppDateFormatter.dateWithOptionalTime(dueDate),
          ),
        if (task.reminderEnabled && dueDate != null)
          _TaskDetailRow(
            label: 'Recordatorio',
            value: _reminderLabel(task.reminderMinutesBefore),
          ),
        if (task.description.isNotEmpty)
          _TaskDetailRow(label: 'Descripcion', value: task.description),
        if (deletedAt != null)
          _TaskDetailRow(
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

  void _showTaskActions(BuildContext context) {
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
                    _showTaskDetails(context);
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

  static Color _priorityColor(TaskPriority priority) {
    return switch (priority) {
      TaskPriority.low => const Color(0xFF16A34A),
      TaskPriority.medium => const Color(0xFFD97706),
      TaskPriority.high => const Color(0xFFDC2626),
    };
  }
}

enum _TaskAction { view, edit, delete }

class _TaskDetailRow extends StatelessWidget {
  const _TaskDetailRow({required this.label, required this.value});

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

class _TaskChip extends StatelessWidget {
  const _TaskChip({required this.label, required this.color});

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

class _TaskFormDialog extends StatefulWidget {
  const _TaskFormDialog({
    required this.subjects,
    required this.defaultReminderMinutes,
    this.initialTask,
  });

  final List<Subject> subjects;
  final int defaultReminderMinutes;
  final AcademicTask? initialTask;

  @override
  State<_TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<_TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late String _subjectId;
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _reminderEnabled = true;
  late int _reminderMinutesBefore;

  @override
  void initState() {
    super.initState();
    final task = widget.initialTask;
    _reminderMinutesBefore = widget.defaultReminderMinutes;
    _subjectId =
        task?.subjectId ??
        (widget.subjects.isEmpty ? '' : widget.subjects.first.id);
    if (task != null) {
      _titleController.text = task.title;
      _descriptionController.text = task.description;
      _priority = task.priority;
      _reminderEnabled = task.reminderEnabled;
      _reminderMinutesBefore = task.reminderMinutesBefore;
      final dueDate = task.dueDate;
      if (dueDate != null) {
        _selectedDate = dueDate;
        if (dueDate.hour != 0 || dueDate.minute != 0) {
          _selectedTime = TimeOfDay(hour: dueDate.hour, minute: dueDate.minute);
        }
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
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

  void _clearTime() {
    setState(() {
      _selectedTime = null;
    });
  }

  Future<void> _toggleReminder(bool enabled) async {
    if (!enabled) {
      setState(() {
        _reminderEnabled = false;
      });
      return;
    }

    if (_selectedDate == null) {
      _showSnackBar('Primero elige una fecha para la tarea.');
      return;
    }

    final granted = await MaUNotifications.instance.requestPermission();
    if (!mounted) {
      return;
    }

    if (!granted) {
      _showSnackBar('Activa las notificaciones del sistema para recordarte.');
      return;
    }

    setState(() {
      _reminderEnabled = true;
    });
  }

  DateTime? _buildDueDate() {
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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final dueDate = _buildDueDate();
    final reminderEnabled = _reminderEnabled && dueDate != null;
    if (reminderEnabled &&
        !MaUNotifications.instance.canSchedule(
          dueDate,
          _reminderMinutesBefore,
        )) {
      _showSnackBar('Ese recordatorio queda en el pasado. Ajusta la hora.');
      return;
    }

    if (reminderEnabled) {
      final granted = await MaUNotifications.instance.requestPermission();
      if (!mounted) {
        return;
      }
      if (!granted) {
        _showSnackBar('Activa las notificaciones del sistema para recordarte.');
        return;
      }
    }

    Navigator.of(context).pop(
      AcademicTask(
        id: widget.initialTask?.id,
        subjectId: _subjectId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: dueDate,
        priority: _priority,
        reminderEnabled: reminderEnabled,
        reminderMinutesBefore: _reminderMinutesBefore,
        isCompleted: widget.initialTask?.isCompleted ?? false,
        deletedAt: widget.initialTask?.deletedAt,
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    if (widget.subjects.isEmpty) {
      return AlertDialog(
        title: const Text('Nueva tarea'),
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
      title: Text(widget.initialTask == null ? 'Nueva tarea' : 'Editar tarea'),
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
                controller: _descriptionController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Descripcion'),
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
              DropdownButtonFormField<TaskPriority>(
                initialValue: _priority,
                decoration: const InputDecoration(labelText: 'Prioridad'),
                items: [
                  for (final priority in TaskPriority.values)
                    DropdownMenuItem(
                      value: priority,
                      child: Text(priority.label),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _priority = value;
                    });
                  }
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
              if (_selectedTime != null) ...[
                const SizedBox(height: 6),
                TextButton.icon(
                  onPressed: _clearTime,
                  icon: const Icon(Icons.close),
                  label: const Text('Quitar hora'),
                ),
              ],
              const SizedBox(height: 10),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Recordarme'),
                subtitle: Text(
                  _selectedDate == null
                      ? 'Elige una fecha para activar recordatorio.'
                      : 'Ma-U te avisara antes de la entrega.',
                ),
                value: _reminderEnabled && _selectedDate != null,
                onChanged: _selectedDate == null ? null : _toggleReminder,
              ),
              if (_reminderEnabled && _selectedDate != null) ...[
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  initialValue: _reminderMinutesBefore,
                  decoration: const InputDecoration(labelText: 'Avisar'),
                  items: [
                    for (final option in MaUNotifications.reminderOptions)
                      DropdownMenuItem(
                        value: option.minutesBefore,
                        child: Text(option.label),
                      ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _reminderMinutesBefore = value;
                      });
                    }
                  },
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

String _reminderLabel(int minutesBefore) {
  return switch (minutesBefore) {
    5 => '5 min antes',
    10 => '10 min antes',
    30 => '30 min antes',
    60 => '1 hora antes',
    1440 => '1 dia antes',
    _ => '$minutesBefore min antes',
  };
}
