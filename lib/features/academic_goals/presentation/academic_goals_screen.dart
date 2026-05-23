import 'package:flutter/material.dart';

import '../../../data/database/app_database_provider.dart';
import '../../academic_record/data/academic_record_repository.dart';
import '../../academic_record/domain/academic_record.dart';
import '../data/academic_goal_repository.dart';
import '../domain/academic_goal.dart';

class AcademicGoalsScreen extends StatefulWidget {
  const AcademicGoalsScreen({super.key});

  @override
  State<AcademicGoalsScreen> createState() => _AcademicGoalsScreenState();
}

class _AcademicGoalsScreenState extends State<AcademicGoalsScreen> {
  late final AcademicRecordRepository _recordRepository;
  late final AcademicGoalRepository _goalRepository;

  @override
  void initState() {
    super.initState();
    final database = AppDatabaseProvider.instance;
    _recordRepository = AcademicRecordRepository(database);
    _goalRepository = AcademicGoalRepository(database);
  }

  Future<void> _openGoalForm(AcademicGoal? currentGoal) async {
    final goal = await showDialog<AcademicGoal>(
      context: context,
      builder: (_) => _GoalFormDialog(initialGoal: currentGoal),
    );

    if (goal != null) {
      await _goalRepository.saveGoal(goal);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SemesterSummary>>(
      stream: _recordRepository.watchSummaries(),
      builder: (context, summarySnapshot) {
        final summaries = summarySnapshot.data ?? const <SemesterSummary>[];
        return StreamBuilder<AcademicGoal?>(
          stream: _goalRepository.watchGoal(),
          builder: (context, goalSnapshot) {
            final goal = goalSnapshot.data;
            return _AcademicGoalsView(
              summaries: summaries,
              goal: goal,
              onEditGoal: () => _openGoalForm(goal),
            );
          },
        );
      },
    );
  }
}

class _AcademicGoalsView extends StatelessWidget {
  const _AcademicGoalsView({
    required this.summaries,
    required this.goal,
    required this.onEditGoal,
  });

  final List<SemesterSummary> summaries;
  final AcademicGoal? goal;
  final VoidCallback onEditGoal;

  @override
  Widget build(BuildContext context) {
    final stats = _AcademicStats.from(summaries);
    final projectedAverage = _projectedAverage(stats);
    final targetAverage = goal?.targetAverage;
    final gap = targetAverage == null || stats.accumulatedAverage == null
        ? null
        : targetAverage - stats.accumulatedAverage!;

    return Scaffold(
      appBar: AppBar(title: const Text('Metas academicas')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onEditGoal,
        icon: const Icon(Icons.track_changes_outlined),
        label: Text(goal == null ? 'Meta' : 'Editar meta'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
          children: [
            _GoalSummaryCard(
              currentAverage: stats.accumulatedAverage,
              targetAverage: targetAverage,
              projectedAverage: projectedAverage,
              gap: gap,
            ),
            const SizedBox(height: 16),
            _SimulationCard(goal: goal, stats: stats),
            const SizedBox(height: 16),
            _CreditWeightCard(summaries: summaries),
          ],
        ),
      ),
    );
  }

  double? _projectedAverage(_AcademicStats stats) {
    final currentAverage = stats.accumulatedAverage;
    final currentCredits = stats.totalCredits;
    final currentGoal = goal;
    if (currentAverage == null ||
        currentGoal == null ||
        currentGoal.plannedCredits <= 0) {
      return null;
    }

    final currentWeighted = currentAverage * currentCredits;
    final plannedWeighted =
        currentGoal.expectedAverage * currentGoal.plannedCredits;
    return (currentWeighted + plannedWeighted) /
        (currentCredits + currentGoal.plannedCredits);
  }
}

class _GoalSummaryCard extends StatelessWidget {
  const _GoalSummaryCard({
    required this.currentAverage,
    required this.targetAverage,
    required this.projectedAverage,
    required this.gap,
  });

  final double? currentAverage;
  final double? targetAverage;
  final double? projectedAverage;
  final double? gap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final reached = gap != null && gap! <= 0;

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
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.track_changes_outlined,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Objetivo de promedio',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        targetAverage == null
                            ? 'Define una meta para empezar.'
                            : reached
                            ? 'Meta alcanzada o superada.'
                            : 'Faltan ${gap!.toStringAsFixed(2)} puntos.',
                        style: TextStyle(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _GoalMetric(
                    label: 'Actual',
                    value: _formatAverage(currentAverage),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _GoalMetric(
                    label: 'Meta',
                    value: _formatAverage(targetAverage),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _GoalMetric(
                    label: 'Proyectado',
                    value: _formatAverage(projectedAverage),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SimulationCard extends StatelessWidget {
  const _SimulationCard({required this.goal, required this.stats});

  final AcademicGoal? goal;
  final _AcademicStats stats;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Simulacion del proximo periodo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              goal == null
                  ? 'Crea una meta para simular cuantos creditos cursaras y que promedio esperas obtener.'
                  : '${goal!.plannedCredits} creditos esperados con promedio ${goal!.expectedAverage.toStringAsFixed(2)}.',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 12),
            Text(
              'Historial base: ${stats.totalCredits} creditos registrados.',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreditWeightCard extends StatelessWidget {
  const _CreditWeightCard({required this.summaries});

  final List<SemesterSummary> summaries;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final ordered = [...summaries]
      ..sort((a, b) => b.credits.compareTo(a.credits));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Semestres con mas peso',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            if (ordered.isEmpty)
              Text(
                'Registra semestres para ver cuales pesan mas en el acumulado.',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              )
            else
              for (final summary in ordered.take(4)) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        summary.semester.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                    Text('${summary.credits} cr'),
                  ],
                ),
                const SizedBox(height: 8),
              ],
          ],
        ),
      ),
    );
  }
}

class _GoalMetric extends StatelessWidget {
  const _GoalMetric({required this.label, required this.value});

  final String label;
  final String value;

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

class _GoalFormDialog extends StatefulWidget {
  const _GoalFormDialog({required this.initialGoal});

  final AcademicGoal? initialGoal;

  @override
  State<_GoalFormDialog> createState() => _GoalFormDialogState();
}

class _GoalFormDialogState extends State<_GoalFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _targetController = TextEditingController(text: '4.0');
  final _creditsController = TextEditingController(text: '15');
  final _expectedController = TextEditingController(text: '4.2');

  @override
  void initState() {
    super.initState();
    final goal = widget.initialGoal;
    if (goal != null) {
      _targetController.text = goal.targetAverage.toStringAsFixed(2);
      _creditsController.text = goal.plannedCredits.toString();
      _expectedController.text = goal.expectedAverage.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _targetController.dispose();
    _creditsController.dispose();
    _expectedController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      AcademicGoal(
        targetAverage: _parseDouble(_targetController.text)!,
        plannedCredits: int.parse(_creditsController.text.trim()),
        expectedAverage: _parseDouble(_expectedController.text)!,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Meta academica'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _targetController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Promedio meta'),
                validator: _gradeValidator,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _creditsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Creditos proximos',
                ),
                validator: (value) {
                  final credits = int.tryParse(value ?? '');
                  if (credits == null || credits <= 0 || credits > 40) {
                    return 'Usa un valor entre 1 y 40.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _expectedController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Promedio esperado',
                ),
                validator: _gradeValidator,
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

  String? _gradeValidator(String? value) {
    final grade = _parseDouble(value ?? '');
    if (grade == null || grade < 0 || grade > 5) {
      return 'Usa una nota entre 0.0 y 5.0.';
    }
    return null;
  }

  double? _parseDouble(String value) {
    return double.tryParse(value.trim().replaceAll(',', '.'));
  }
}

class _AcademicStats {
  const _AcademicStats({
    required this.totalCredits,
    required this.accumulatedAverage,
  });

  final int totalCredits;
  final double? accumulatedAverage;

  factory _AcademicStats.from(List<SemesterSummary> summaries) {
    final totalCredits = summaries.fold<int>(
      0,
      (total, summary) => total + summary.credits,
    );
    if (totalCredits == 0) {
      return const _AcademicStats(totalCredits: 0, accumulatedAverage: null);
    }

    final weighted = summaries.fold<double>(
      0,
      (total, summary) =>
          total +
          summary.courses.fold<double>(
            0,
            (courseTotal, course) =>
                courseTotal + course.finalGrade * course.credits,
          ),
    );
    return _AcademicStats(
      totalCredits: totalCredits,
      accumulatedAverage: weighted / totalCredits,
    );
  }
}

String _formatAverage(double? value) {
  return value == null ? '--' : value.toStringAsFixed(2);
}
