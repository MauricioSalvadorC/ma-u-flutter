import 'package:flutter/material.dart';

import '../../../core/formatters/app_date_formatter.dart';
import '../../../data/database/app_database_provider.dart';
import '../../schedule/data/academic_seed_service.dart';
import '../../schedule/data/schedule_repository.dart';
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

  Future<void> _restoreTask(AcademicTask task) async {
    final id = task.id;
    if (id == null) {
      return;
    }

    await _taskRepository.restoreTask(id);
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
                return _TrashView(
                  subjects: subjects,
                  tasks: tasks,
                  onRestoreTask: _restoreTask,
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
    required this.onRestoreTask,
  });

  final List<Subject> subjects;
  final List<AcademicTask> tasks;
  final ValueChanged<AcademicTask> onRestoreTask;

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
            if (tasks.isEmpty)
              const _EmptyTrashCard()
            else
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
