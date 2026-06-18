import 'package:flutter/material.dart';

import '../../../core/formatters/app_date_formatter.dart';
import '../../../core/settings/app_settings_repository.dart';
import '../../../core/widgets/app_detail_bottom_sheet.dart';
import '../../../core/widgets/destructive_confirmation_dialog.dart';
import '../../../data/database/app_database_provider.dart';
import '../../schedule/data/academic_seed_service.dart';
import '../../schedule/data/schedule_repository.dart';
import '../../subjects/data/subject_repository.dart';
import '../../subjects/domain/subject.dart';
import '../data/grade_assessment_repository.dart';
import '../domain/academic_assessment.dart';
import 'grade_calculator_screen.dart';

class AcademicGradesScreen extends StatefulWidget {
  const AcademicGradesScreen({super.key, this.initialSubjectId});

  final String? initialSubjectId;

  @override
  State<AcademicGradesScreen> createState() => _AcademicGradesScreenState();
}

class _AcademicGradesScreenState extends State<AcademicGradesScreen> {
  late final SubjectRepository _subjectRepository;
  late final ScheduleRepository _scheduleRepository;
  late final GradeAssessmentRepository _assessmentRepository;
  late final AppSettingsRepository _settingsRepository;
  late final Future<void> _seedFuture;
  GradeScale _scale = GradeScale.zeroToFive;
  double _passingGrade = GradeScale.zeroToFive.defaultPassingGrade;

  @override
  void initState() {
    super.initState();
    final database = AppDatabaseProvider.instance;
    _subjectRepository = SubjectRepository(database);
    _scheduleRepository = ScheduleRepository(database);
    _assessmentRepository = GradeAssessmentRepository(database);
    _settingsRepository = AppSettingsRepository(database);
    _seedFuture = AcademicSeedService(
      subjectRepository: _subjectRepository,
      scheduleRepository: _scheduleRepository,
    ).seedIfNeeded();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final scale = await _settingsRepository.getGradeScale();
    final resolvedScale = scale ?? _scale;
    final passingGrade = await _settingsRepository.getPassingGrade();
    if (!mounted) {
      return;
    }
    setState(() {
      _scale = resolvedScale;
      _passingGrade = passingGrade ?? resolvedScale.defaultPassingGrade;
    });
  }

  Future<void> _openForm({
    required List<Subject> subjects,
    required List<AcademicAssessment> assessments,
    AcademicAssessment? initialAssessment,
    String? initialSubjectId,
  }) async {
    final assessment = await showDialog<AcademicAssessment>(
      context: context,
      builder: (_) => _AssessmentFormDialog(
        subjects: subjects,
        assessments: assessments,
        scale: _scale,
        initialAssessment: initialAssessment,
        initialSubjectId: initialSubjectId ?? widget.initialSubjectId,
      ),
    );

    if (assessment != null) {
      await _assessmentRepository.saveAssessment(assessment);
    }
  }

  Future<void> _moveToTrash(AcademicAssessment assessment) async {
    final id = assessment.id;
    if (id == null) {
      return;
    }

    final confirmed = await DestructiveConfirmationDialog.show(
      context: context,
      title: 'Mover evaluacion a papelera',
      message:
          'La evaluacion "${assessment.title}" se ocultara de las notas. Podras restaurarla despues.',
      confirmLabel: 'Mover',
    );

    if (confirmed) {
      await _assessmentRepository.moveToTrash(id);
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
            return StreamBuilder<List<AcademicAssessment>>(
              stream: _assessmentRepository.watchAssessments(),
              builder: (context, assessmentSnapshot) {
                final assessments =
                    assessmentSnapshot.data ?? const <AcademicAssessment>[];
                return _AcademicGradesView(
                  subjects: subjects,
                  assessments: assessments,
                  initialSubjectId: widget.initialSubjectId,
                  scale: _scale,
                  passingGrade: _passingGrade,
                  onAdd: (subjectId) => _openForm(
                    subjects: subjects,
                    assessments: assessments,
                    initialSubjectId: subjectId,
                  ),
                  onEdit: (assessment) => _openForm(
                    subjects: subjects,
                    assessments: assessments,
                    initialAssessment: assessment,
                  ),
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

class _AcademicGradesView extends StatelessWidget {
  const _AcademicGradesView({
    required this.subjects,
    required this.assessments,
    required this.initialSubjectId,
    required this.scale,
    required this.passingGrade,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Subject> subjects;
  final List<AcademicAssessment> assessments;
  final String? initialSubjectId;
  final GradeScale scale;
  final double passingGrade;
  final ValueChanged<String?> onAdd;
  final ValueChanged<AcademicAssessment> onEdit;
  final ValueChanged<AcademicAssessment> onDelete;

  @override
  Widget build(BuildContext context) {
    final selectedSubject = _subjectFor(initialSubjectId);
    final visibleAssessments = initialSubjectId == null
        ? assessments
        : assessments
              .where((assessment) => assessment.subjectId == initialSubjectId)
              .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedSubject == null ? 'Notas por materia' : selectedSubject.name,
        ),
        actions: [
          IconButton(
            tooltip: 'Calculadora rapida',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const GradeCalculatorScreen(),
                ),
              );
            },
            icon: const Icon(Icons.calculate_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => onAdd(initialSubjectId),
        icon: const Icon(Icons.add_outlined),
        label: const Text('Evaluacion'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
          children: [
            if (selectedSubject == null)
              for (final subject in subjects) ...[
                _SubjectGradeCard(
                  subject: subject,
                  assessments: assessments
                      .where((assessment) => assessment.subjectId == subject.id)
                      .toList(),
                  scale: scale,
                  passingGrade: passingGrade,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            AcademicGradesScreen(initialSubjectId: subject.id),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
              ]
            else ...[
              _GradeSummaryCard(
                progress: GradeProgress(
                  assessments: visibleAssessments,
                  scale: scale,
                  passingGrade: passingGrade,
                ),
              ),
              const SizedBox(height: 16),
              if (visibleAssessments.isEmpty)
                const _EmptyAssessmentsCard()
              else
                for (final assessment in _sortedAssessments(
                  visibleAssessments,
                )) ...[
                  _AssessmentCard(
                    assessment: assessment,
                    scale: scale,
                    onTap: () => _showAssessmentDetails(context, assessment),
                    onEdit: () => onEdit(assessment),
                    onDelete: () => onDelete(assessment),
                  ),
                  const SizedBox(height: 10),
                ],
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

    for (final subject in subjects) {
      if (subject.id == subjectId) {
        return subject;
      }
    }

    return null;
  }

  Future<void> _showAssessmentDetails(
    BuildContext context,
    AcademicAssessment assessment,
  ) {
    return AppDetailBottomSheet.show(
      context: context,
      children: [
        Text(
          assessment.title,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 14),
        _DetailRow(label: 'Nota', value: _formatGrade(assessment.grade, scale)),
        _DetailRow(
          label: 'Porcentaje',
          value: '${_formatPercent(assessment.weightPercent)}%',
        ),
        _DetailRow(
          label: 'Fecha',
          value: assessment.date == null
              ? 'Sin fecha'
              : AppDateFormatter.dateWithOptionalTime(assessment.date!),
        ),
        if (assessment.notes.isNotEmpty)
          _DetailRow(label: 'Notas', value: assessment.notes),
      ],
    );
  }
}

class _SubjectGradeCard extends StatelessWidget {
  const _SubjectGradeCard({
    required this.subject,
    required this.assessments,
    required this.scale,
    required this.passingGrade,
    required this.onTap,
  });

  final Subject subject;
  final List<AcademicAssessment> assessments;
  final GradeScale scale;
  final double passingGrade;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = GradeProgress(
      assessments: assessments,
      scale: scale,
      passingGrade: passingGrade,
    );
    final colorScheme = Theme.of(context).colorScheme;
    final accent = Color(subject.accentColorValue);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: accent.withAlpha(40),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.grade_outlined, color: accent),
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
                      _summaryLine(progress),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(Icons.east, color: colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }

  String _summaryLine(GradeProgress progress) {
    final average = progress.registeredAverage;
    if (average == null) {
      return 'Sin evaluaciones - meta ${_formatGrade(passingGrade, scale)}';
    }

    return '${_formatPercent(progress.evaluatedPercent)}% evaluado - promedio ${_formatGrade(average, scale)}';
  }
}

class _GradeSummaryCard extends StatelessWidget {
  const _GradeSummaryCard({required this.progress});

  final GradeProgress progress;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen academico',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: (progress.evaluatedPercent / 100).clamp(0, 1),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _SummaryPill(
                  label: 'Evaluado',
                  value: '${_formatPercent(progress.evaluatedPercent)}%',
                ),
                _SummaryPill(
                  label: 'Acumulado',
                  value: _formatGrade(
                    progress.accumulatedGrade,
                    progress.scale,
                  ),
                ),
                _SummaryPill(
                  label: 'Promedio',
                  value: progress.registeredAverage == null
                      ? '--'
                      : _formatGrade(
                          progress.registeredAverage!,
                          progress.scale,
                        ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              _goalMessage(progress),
              style: TextStyle(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _goalMessage(GradeProgress progress) {
    final target = _formatGrade(progress.passingGrade, progress.scale);
    final required = progress.requiredGrade;
    return switch (progress.status) {
      GradeGoalStatus.secured =>
        'Meta $target asegurada con lo evaluado hasta ahora.',
      GradeGoalStatus.unreachable =>
        'Para llegar a $target necesitarias mas de ${_formatGrade(progress.scale.maxValue.toDouble(), progress.scale)}.',
      GradeGoalStatus.passed =>
        'Nota final ${_formatGrade(progress.accumulatedGrade, progress.scale)}. Meta alcanzada.',
      GradeGoalStatus.failed =>
        'Nota final ${_formatGrade(progress.accumulatedGrade, progress.scale)}. Meta no alcanzada.',
      GradeGoalStatus.pending =>
        required == null
            ? 'Registra evaluaciones para calcular avance.'
            : 'Necesitas ${_formatGrade(required, progress.scale)} en el ${_formatPercent(progress.remainingPercent)}% restante para llegar a $target.',
    };
  }
}

class _AssessmentCard extends StatelessWidget {
  const _AssessmentCard({
    required this.assessment,
    required this.scale,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final AcademicAssessment assessment;
  final GradeScale scale;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        onLongPress: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Icon(Icons.grade_outlined, color: colorScheme.primary),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assessment.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_formatGrade(assessment.grade, scale)} - ${_formatPercent(assessment.weightPercent)}%',
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<_AssessmentAction>(
                tooltip: 'Opciones',
                onSelected: (action) {
                  switch (action) {
                    case _AssessmentAction.view:
                      onTap();
                    case _AssessmentAction.edit:
                      onEdit();
                    case _AssessmentAction.delete:
                      onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _AssessmentAction.view,
                    child: Text('Ver detalle'),
                  ),
                  PopupMenuItem(
                    value: _AssessmentAction.edit,
                    child: Text('Editar'),
                  ),
                  PopupMenuItem(
                    value: _AssessmentAction.delete,
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
}

class _AssessmentFormDialog extends StatefulWidget {
  const _AssessmentFormDialog({
    required this.subjects,
    required this.assessments,
    required this.scale,
    this.initialAssessment,
    this.initialSubjectId,
  });

  final List<Subject> subjects;
  final List<AcademicAssessment> assessments;
  final GradeScale scale;
  final AcademicAssessment? initialAssessment;
  final String? initialSubjectId;

  @override
  State<_AssessmentFormDialog> createState() => _AssessmentFormDialogState();
}

class _AssessmentFormDialogState extends State<_AssessmentFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _gradeController = TextEditingController();
  final _weightController = TextEditingController();
  final _notesController = TextEditingController();
  late String _subjectId;
  DateTime? _date;

  @override
  void initState() {
    super.initState();
    final assessment = widget.initialAssessment;
    _subjectId =
        assessment?.subjectId ??
        widget.initialSubjectId ??
        (widget.subjects.isEmpty ? '' : widget.subjects.first.id);
    if (assessment != null) {
      _titleController.text = assessment.title;
      _gradeController.text = _formatInput(assessment.grade);
      _weightController.text = _formatInput(assessment.weightPercent);
      _notesController.text = assessment.notes;
      _date = assessment.date;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _gradeController.dispose();
    _weightController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final selected = await showDatePicker(
      context: context,
      initialDate: _date ?? now,
      firstDate: DateTime(now.year - 5),
      lastDate: DateTime(now.year + 5),
    );
    if (selected != null) {
      setState(() {
        _date = selected;
      });
    }
  }

  void _clearDate() {
    setState(() {
      _date = null;
    });
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final grade = _parseNumber(_gradeController.text)!;
    final weight = _parseNumber(_weightController.text)!;
    final now = DateTime.now();
    Navigator.of(context).pop(
      AcademicAssessment(
        id: widget.initialAssessment?.id,
        subjectId: _subjectId,
        title: _titleController.text.trim(),
        grade: grade,
        weightPercent: weight,
        date: _date,
        notes: _notesController.text.trim(),
        createdAt: widget.initialAssessment?.createdAt ?? now,
        updatedAt: now,
        deletedAt: widget.initialAssessment?.deletedAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.subjects.isEmpty) {
      return AlertDialog(
        title: const Text('Nueva evaluacion'),
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
        widget.initialAssessment == null
            ? 'Nueva evaluacion'
            : 'Editar evaluacion',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Nombre'),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Campo requerido.'
                    : null,
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
              TextFormField(
                controller: _gradeController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: 'Nota',
                  helperText: 'Escala ${widget.scale.label}',
                ),
                validator: _validateGrade,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Porcentaje',
                  suffixText: '%',
                ),
                validator: _validateWeight,
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.event_outlined),
                label: Text(
                  _date == null
                      ? 'Fecha opcional'
                      : AppDateFormatter.date(_date!),
                ),
              ),
              if (_date != null)
                TextButton.icon(
                  onPressed: _clearDate,
                  icon: const Icon(Icons.close),
                  label: const Text('Quitar fecha'),
                ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _notesController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Notas'),
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

  String? _validateGrade(String? value) {
    final grade = _parseNumber(value ?? '');
    if (grade == null || grade < 0 || grade > widget.scale.maxValue) {
      return 'Ingresa una nota entre 0 y ${widget.scale.maxValue}.';
    }
    return null;
  }

  String? _validateWeight(String? value) {
    final weight = _parseNumber(value ?? '');
    if (weight == null || weight <= 0 || weight > 100) {
      return 'Ingresa un porcentaje entre 0 y 100.';
    }

    final usedPercent = widget.assessments
        .where((assessment) => assessment.subjectId == _subjectId)
        .where((assessment) => assessment.id != widget.initialAssessment?.id)
        .fold<double>(
          0,
          (total, assessment) => total + assessment.weightPercent,
        );
    if (usedPercent + weight > 100.0001) {
      return 'Supera el 100%. Disponible: ${_formatPercent(100 - usedPercent)}%.';
    }

    return null;
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900)),
        ],
      ),
    );
  }
}

class _EmptyAssessmentsCard extends StatelessWidget {
  const _EmptyAssessmentsCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(Icons.grade_outlined, color: colorScheme.primary, size: 38),
            const SizedBox(height: 10),
            const Text(
              'Sin evaluaciones',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              'Agrega parciales, talleres o actividades con porcentaje.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

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
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

enum _AssessmentAction { view, edit, delete }

List<AcademicAssessment> _sortedAssessments(
  List<AcademicAssessment> assessments,
) {
  return [...assessments]..sort((a, b) {
    final aDate = a.date;
    final bDate = b.date;
    if (aDate == null && bDate == null) {
      return b.updatedAt.compareTo(a.updatedAt);
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

double? _parseNumber(String value) {
  return double.tryParse(value.trim().replaceAll(',', '.'));
}

String _formatGrade(double value, GradeScale scale) {
  final decimals = scale == GradeScale.zeroToHundred ? 1 : 2;
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }

  return value.toStringAsFixed(decimals);
}

String _formatPercent(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }

  return value.toStringAsFixed(1);
}

String _formatInput(double value) {
  if (value == value.roundToDouble()) {
    return value.toStringAsFixed(0);
  }

  return value.toStringAsFixed(2);
}
