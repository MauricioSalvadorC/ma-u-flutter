import 'package:flutter/material.dart';

import '../../../core/widgets/destructive_confirmation_dialog.dart';
import '../../../data/database/app_database_provider.dart';
import '../data/academic_record_repository.dart';
import '../domain/academic_record.dart';

class AcademicRecordScreen extends StatefulWidget {
  const AcademicRecordScreen({super.key});

  @override
  State<AcademicRecordScreen> createState() => _AcademicRecordScreenState();
}

class _AcademicRecordScreenState extends State<AcademicRecordScreen> {
  late final AcademicRecordRepository _repository;

  @override
  void initState() {
    super.initState();
    _repository = AcademicRecordRepository(AppDatabaseProvider.instance);
  }

  Future<void> _openSemesterForm() async {
    final semester = await showDialog<AcademicSemester>(
      context: context,
      builder: (_) => const _SemesterFormDialog(),
    );

    if (semester != null) {
      await _repository.saveSemester(semester);
    }
  }

  Future<void> _openCourseForm(
    AcademicSemester semester, {
    SemesterCourse? initialCourse,
  }) async {
    final course = await showDialog<SemesterCourse>(
      context: context,
      builder: (_) =>
          _CourseFormDialog(semester: semester, initialCourse: initialCourse),
    );

    if (course != null) {
      await _repository.saveCourse(course);
    }
  }

  Future<void> _deleteSemester(SemesterSummary summary) async {
    final confirmed = await DestructiveConfirmationDialog.show(
      context: context,
      title: 'Mover semestre a papelera',
      message:
          'El semestre "${summary.semester.name}" y sus materias se ocultaran del historial.',
      confirmLabel: 'Mover',
    );

    if (confirmed) {
      await _repository.moveSemesterToTrash(summary.semester.id);
    }
  }

  Future<void> _deleteCourse(SemesterCourse course) async {
    final id = course.id;
    if (id == null) {
      return;
    }

    final confirmed = await DestructiveConfirmationDialog.show(
      context: context,
      title: 'Mover materia a papelera',
      message:
          'La materia "${course.name}" se ocultara del historial academico.',
      confirmLabel: 'Mover',
    );

    if (confirmed) {
      await _repository.moveCourseToTrash(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<SemesterSummary>>(
      stream: _repository.watchSummaries(),
      builder: (context, snapshot) {
        final summaries = snapshot.data ?? const <SemesterSummary>[];
        return _AcademicRecordView(
          summaries: summaries,
          onAddSemester: _openSemesterForm,
          onAddCourse: (semester) => _openCourseForm(semester),
          onEditCourse: (semester, course) =>
              _openCourseForm(semester, initialCourse: course),
          onDeleteSemester: _deleteSemester,
          onDeleteCourse: _deleteCourse,
        );
      },
    );
  }
}

class _AcademicRecordView extends StatelessWidget {
  const _AcademicRecordView({
    required this.summaries,
    required this.onAddSemester,
    required this.onAddCourse,
    required this.onEditCourse,
    required this.onDeleteSemester,
    required this.onDeleteCourse,
  });

  final List<SemesterSummary> summaries;
  final VoidCallback onAddSemester;
  final ValueChanged<AcademicSemester> onAddCourse;
  final void Function(AcademicSemester semester, SemesterCourse course)
  onEditCourse;
  final ValueChanged<SemesterSummary> onDeleteSemester;
  final ValueChanged<SemesterCourse> onDeleteCourse;

  @override
  Widget build(BuildContext context) {
    final accumulated = _accumulatedAverage();
    final totalCredits = summaries.fold<int>(
      0,
      (total, summary) => total + summary.credits,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Promedio acumulado')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onAddSemester,
        icon: const Icon(Icons.add_outlined),
        label: const Text('Semestre'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
          children: [
            _RecordSummaryCard(
              accumulatedAverage: accumulated,
              totalCredits: totalCredits,
              semesterCount: summaries.length,
            ),
            const SizedBox(height: 16),
            if (summaries.isEmpty)
              const _EmptyRecordCard()
            else
              for (final summary in summaries) ...[
                _SemesterCard(
                  summary: summary,
                  onAddCourse: () => onAddCourse(summary.semester),
                  onEditCourse: (course) =>
                      onEditCourse(summary.semester, course),
                  onDeleteSemester: () => onDeleteSemester(summary),
                  onDeleteCourse: onDeleteCourse,
                ),
                const SizedBox(height: 12),
              ],
          ],
        ),
      ),
    );
  }

  double? _accumulatedAverage() {
    final totalCredits = summaries.fold<int>(
      0,
      (total, summary) => total + summary.credits,
    );
    if (totalCredits == 0) {
      return null;
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
    return weighted / totalCredits;
  }
}

class _RecordSummaryCard extends StatelessWidget {
  const _RecordSummaryCard({
    required this.accumulatedAverage,
    required this.totalCredits,
    required this.semesterCount,
  });

  final double? accumulatedAverage;
  final int totalCredits;
  final int semesterCount;

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
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.school_outlined,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Historial academico',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('$semesterCount semestres - $totalCredits creditos'),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              accumulatedAverage == null
                  ? '--'
                  : accumulatedAverage!.toStringAsFixed(2),
              style: const TextStyle(fontSize: 36, fontWeight: FontWeight.w900),
            ),
            Text(
              'Promedio acumulado ponderado',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _SemesterCard extends StatelessWidget {
  const _SemesterCard({
    required this.summary,
    required this.onAddCourse,
    required this.onEditCourse,
    required this.onDeleteSemester,
    required this.onDeleteCourse,
  });

  final SemesterSummary summary;
  final VoidCallback onAddCourse;
  final ValueChanged<SemesterCourse> onEditCourse;
  final VoidCallback onDeleteSemester;
  final ValueChanged<SemesterCourse> onDeleteCourse;

  @override
  Widget build(BuildContext context) {
    final average = summary.average;

    return Card(
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
        title: Text(
          summary.semester.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          '${summary.credits} creditos - promedio ${average == null ? '--' : average.toStringAsFixed(2)}',
        ),
        trailing: PopupMenuButton<_SemesterAction>(
          tooltip: 'Opciones de semestre',
          onSelected: (action) {
            switch (action) {
              case _SemesterAction.addCourse:
                onAddCourse();
              case _SemesterAction.delete:
                onDeleteSemester();
            }
          },
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: _SemesterAction.addCourse,
              child: Text('Agregar materia'),
            ),
            PopupMenuItem(
              value: _SemesterAction.delete,
              child: Text('Mover a papelera'),
            ),
          ],
        ),
        children: [
          if (summary.courses.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Agrega materias con creditos y nota final.'),
            )
          else
            for (final course in summary.courses) ...[
              _CourseTile(
                course: course,
                onEdit: () => onEditCourse(course),
                onDelete: () => onDeleteCourse(course),
              ),
              const SizedBox(height: 8),
            ],
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: OutlinedButton.icon(
              onPressed: onAddCourse,
              icon: const Icon(Icons.add_outlined),
              label: const Text('Materia'),
            ),
          ),
        ],
      ),
    );
  }
}

class _CourseTile extends StatelessWidget {
  const _CourseTile({
    required this.course,
    required this.onEdit,
    required this.onDelete,
  });

  final SemesterCourse course;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withAlpha(120),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 4),
                Text(
                  '${course.credits} cr - nota ${course.finalGrade.toStringAsFixed(2)}',
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          PopupMenuButton<_CourseAction>(
            tooltip: 'Opciones de materia',
            onSelected: (action) {
              switch (action) {
                case _CourseAction.edit:
                  onEdit();
                case _CourseAction.delete:
                  onDelete();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: _CourseAction.edit, child: Text('Editar')),
              PopupMenuItem(
                value: _CourseAction.delete,
                child: Text('Mover a papelera'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

enum _SemesterAction { addCourse, delete }

enum _CourseAction { edit, delete }

class _EmptyRecordCard extends StatelessWidget {
  const _EmptyRecordCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(
              Icons.auto_stories_outlined,
              color: colorScheme.primary,
              size: 38,
            ),
            const SizedBox(height: 10),
            const Text(
              'Sin semestres todavia',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              'Crea tu primer semestre y registra materias con creditos y nota final.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _SemesterFormDialog extends StatefulWidget {
  const _SemesterFormDialog();

  @override
  State<_SemesterFormDialog> createState() => _SemesterFormDialogState();
}

class _SemesterFormDialogState extends State<_SemesterFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _yearController = TextEditingController(
    text: DateTime.now().year.toString(),
  );
  int _termIndex = 1;

  @override
  void dispose() {
    _nameController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final year = int.parse(_yearController.text.trim());
    final name = _nameController.text.trim().isEmpty
        ? '$year-$_termIndex'
        : _nameController.text.trim();
    Navigator.of(context).pop(
      AcademicSemester(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        name: name,
        year: year,
        termIndex: _termIndex,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Nuevo semestre'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nombre opcional',
                  hintText: '2026-1',
                ),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _yearController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Ano'),
                validator: (value) {
                  final year = int.tryParse(value ?? '');
                  if (year == null || year < 2000 || year > 2100) {
                    return 'Usa un ano valido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<int>(
                initialValue: _termIndex,
                decoration: const InputDecoration(labelText: 'Periodo'),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('1')),
                  DropdownMenuItem(value: 2, child: Text('2')),
                  DropdownMenuItem(value: 3, child: Text('Intersemestral')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _termIndex = value;
                    });
                  }
                },
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

class _CourseFormDialog extends StatefulWidget {
  const _CourseFormDialog({required this.semester, this.initialCourse});

  final AcademicSemester semester;
  final SemesterCourse? initialCourse;

  @override
  State<_CourseFormDialog> createState() => _CourseFormDialogState();
}

class _CourseFormDialogState extends State<_CourseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _creditsController = TextEditingController(text: '3');
  final _gradeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final course = widget.initialCourse;
    if (course != null) {
      _nameController.text = course.name;
      _creditsController.text = course.credits.toString();
      _gradeController.text = course.finalGrade.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _creditsController.dispose();
    _gradeController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      SemesterCourse(
        id: widget.initialCourse?.id,
        semesterId: widget.semester.id,
        name: _nameController.text.trim(),
        credits: int.parse(_creditsController.text.trim()),
        finalGrade: double.parse(
          _gradeController.text.trim().replaceAll(',', '.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialCourse == null ? 'Nueva materia' : 'Editar materia',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Materia'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Campo requerido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _creditsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Creditos'),
                validator: (value) {
                  final credits = int.tryParse(value ?? '');
                  if (credits == null || credits <= 0 || credits > 20) {
                    return 'Usa un valor entre 1 y 20.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _gradeController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Nota final'),
                validator: (value) {
                  final grade = double.tryParse(
                    (value ?? '').trim().replaceAll(',', '.'),
                  );
                  if (grade == null || grade < 0 || grade > 5) {
                    return 'Usa una nota entre 0.0 y 5.0.';
                  }
                  return null;
                },
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
