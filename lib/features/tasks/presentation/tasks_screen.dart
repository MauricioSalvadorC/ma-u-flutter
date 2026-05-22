import 'package:flutter/material.dart';

import '../../../data/database/app_database_provider.dart';
import '../../schedule/data/academic_seed_service.dart';
import '../../schedule/data/schedule_repository.dart';
import '../../subjects/data/subject_repository.dart';
import '../../subjects/domain/subject.dart';
import '../data/task_repository.dart';
import '../domain/academic_task.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late final SubjectRepository _subjectRepository;
  late final ScheduleRepository _scheduleRepository;
  late final TaskRepository _taskRepository;
  late final Future<void> _seedFuture;

  @override
  void initState() {
    super.initState();
    final database = AppDatabaseProvider.instance;
    _subjectRepository = SubjectRepository(database);
    _scheduleRepository = ScheduleRepository(database);
    _taskRepository = TaskRepository(database);
    _seedFuture = AcademicSeedService(
      subjectRepository: _subjectRepository,
      scheduleRepository: _scheduleRepository,
    ).seedIfNeeded();
  }

  Future<void> _openTaskForm(List<Subject> subjects) async {
    final task = await showDialog<AcademicTask>(
      context: context,
      builder: (_) => _TaskFormDialog(subjects: subjects),
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

    await _taskRepository.deleteTask(id);
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
                  onAddTask: () => _openTaskForm(subjects),
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

class _TasksView extends StatelessWidget {
  const _TasksView({
    required this.subjects,
    required this.tasks,
    required this.onAddTask,
    required this.onToggleTask,
    required this.onDeleteTask,
  });

  final List<Subject> subjects;
  final List<AcademicTask> tasks;
  final VoidCallback onAddTask;
  final ValueChanged<AcademicTask> onToggleTask;
  final ValueChanged<AcademicTask> onDeleteTask;

  @override
  Widget build(BuildContext context) {
    final pendingCount = tasks.where((task) => !task.isCompleted).length;
    final completedCount = tasks.length - pendingCount;

    return Scaffold(
      appBar: AppBar(title: const Text('Tareas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onAddTask,
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
            if (tasks.isEmpty)
              const _EmptyTasksCard()
            else
              for (final task in tasks) ...[
                _TaskCard(
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
                  onToggle: () => onToggleTask(task),
                  onDelete: () => onDeleteTask(task),
                ),
                const SizedBox(height: 10),
              ],
          ],
        ),
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
    required this.onToggle,
    required this.onDelete,
  });

  final AcademicTask task;
  final Subject subject;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final subjectColor = Color(subject.accentColorValue);
    final colorScheme = Theme.of(context).colorScheme;
    final dueDate = task.dueDate;

    return Card(
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
                          label: _formatDate(dueDate),
                          color: colorScheme.primary,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'Eliminar tarea',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }

  static Color _priorityColor(TaskPriority priority) {
    return switch (priority) {
      TaskPriority.low => const Color(0xFF16A34A),
      TaskPriority.medium => const Color(0xFFD97706),
      TaskPriority.high => const Color(0xFFDC2626),
    };
  }

  static String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
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
  const _TaskFormDialog({required this.subjects});

  final List<Subject> subjects;

  @override
  State<_TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<_TaskFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  late String _subjectId;
  TaskPriority _priority = TaskPriority.medium;
  DateTime? _dueDate;

  @override
  void initState() {
    super.initState();
    _subjectId = widget.subjects.isEmpty ? '' : widget.subjects.first.id;
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
      initialDate: _dueDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 5),
    );

    if (selectedDate != null) {
      setState(() {
        _dueDate = selectedDate;
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      AcademicTask(
        subjectId: _subjectId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _dueDate,
        priority: _priority,
        isCompleted: false,
      ),
    );
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
      title: const Text('Nueva tarea'),
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
                  _dueDate == null
                      ? 'Elegir fecha'
                      : 'Fecha ${_TaskCard._formatDate(_dueDate!)}',
                ),
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
