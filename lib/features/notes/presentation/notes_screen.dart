import 'package:flutter/material.dart';

import '../../../core/formatters/app_date_formatter.dart';
import '../../../core/widgets/app_detail_bottom_sheet.dart';
import '../../../core/widgets/destructive_confirmation_dialog.dart';
import '../../../data/database/app_database_provider.dart';
import '../../schedule/data/academic_seed_service.dart';
import '../../schedule/data/schedule_repository.dart';
import '../../subjects/data/subject_repository.dart';
import '../../subjects/domain/subject.dart';
import '../data/note_repository.dart';
import '../domain/academic_note.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key, this.initialSubjectId});

  final String? initialSubjectId;

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

class _NotesScreenState extends State<NotesScreen> {
  late final SubjectRepository _subjectRepository;
  late final ScheduleRepository _scheduleRepository;
  late final NoteRepository _noteRepository;
  late final Future<void> _seedFuture;

  @override
  void initState() {
    super.initState();
    final database = AppDatabaseProvider.instance;
    _subjectRepository = SubjectRepository(database);
    _scheduleRepository = ScheduleRepository(database);
    _noteRepository = NoteRepository(database);
    _seedFuture = AcademicSeedService(
      subjectRepository: _subjectRepository,
      scheduleRepository: _scheduleRepository,
    ).seedIfNeeded();
  }

  Future<void> _openForm(
    List<Subject> subjects, {
    AcademicNote? initialNote,
  }) async {
    final note = await showDialog<AcademicNote>(
      context: context,
      builder: (_) =>
          _NoteFormDialog(subjects: subjects, initialNote: initialNote),
    );

    if (note != null) {
      await _noteRepository.saveNote(note);
    }
  }

  Future<void> _moveToTrash(AcademicNote note) async {
    final id = note.id;
    if (id == null) {
      return;
    }

    final confirmed = await DestructiveConfirmationDialog.show(
      context: context,
      title: 'Mover apunte a papelera',
      message:
          'El apunte "${note.title}" se ocultara de tu biblioteca. Podras restaurarlo despues.',
      confirmLabel: 'Mover',
    );

    if (confirmed) {
      await _noteRepository.moveToTrash(id);
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
            return StreamBuilder<List<AcademicNote>>(
              stream: _noteRepository.watchNotes(),
              builder: (context, noteSnapshot) {
                final notes = noteSnapshot.data ?? const <AcademicNote>[];
                return _NotesView(
                  subjects: subjects,
                  notes: notes,
                  initialSubjectId: widget.initialSubjectId,
                  onAdd: () => _openForm(subjects),
                  onEdit: (note) => _openForm(subjects, initialNote: note),
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

class _NotesView extends StatefulWidget {
  const _NotesView({
    required this.subjects,
    required this.notes,
    required this.initialSubjectId,
    required this.onAdd,
    required this.onEdit,
    required this.onDelete,
  });

  final List<Subject> subjects;
  final List<AcademicNote> notes;
  final String? initialSubjectId;
  final VoidCallback onAdd;
  final ValueChanged<AcademicNote> onEdit;
  final ValueChanged<AcademicNote> onDelete;

  @override
  State<_NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<_NotesView> {
  _NoteFilter _filter = _NoteFilter.all;
  String _query = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialSubjectId != null) {
      _filter = _NoteFilter.subjects;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scopedNotes = widget.initialSubjectId == null
        ? widget.notes
        : widget.notes
              .where((note) => note.subjectId == widget.initialSubjectId)
              .toList();
    final filteredNotes = scopedNotes.where(_matches).toList();
    final linkedCount = scopedNotes
        .where((note) => note.subjectId != null)
        .length;
    final globalCount = scopedNotes.length - linkedCount;
    final selectedSubject = _subjectFor(widget.initialSubjectId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedSubject == null
              ? 'Apuntes'
              : 'Apuntes de ${selectedSubject.name}',
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: widget.onAdd,
        icon: const Icon(Icons.edit_note_outlined),
        label: const Text('Apunte'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
          children: [
            _NotesSummaryCard(
              total: scopedNotes.length,
              linked: linkedCount,
              global: globalCount,
              subjectName: selectedSubject?.name,
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (value) {
                setState(() {
                  _query = value;
                });
              },
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                hintText: 'Buscar apuntes, materias o etiquetas',
                prefixIcon: Icon(Icons.search),
              ),
            ),
            if (widget.initialSubjectId == null) ...[
              const SizedBox(height: 12),
              _NoteFilterBar(
                selected: _filter,
                notes: widget.notes,
                onSelected: (filter) {
                  setState(() {
                    _filter = filter;
                  });
                },
              ),
            ],
            const SizedBox(height: 16),
            if (filteredNotes.isEmpty)
              const _EmptyNotesCard()
            else
              for (final note in filteredNotes) ...[
                _NoteCard(
                  note: note,
                  subject: _subjectFor(note.subjectId),
                  onTap: () => _showDetails(note),
                  onEdit: () => widget.onEdit(note),
                  onDelete: () => widget.onDelete(note),
                ),
                const SizedBox(height: 10),
              ],
          ],
        ),
      ),
    );
  }

  bool _matches(AcademicNote note) {
    if (widget.initialSubjectId != null &&
        note.subjectId != widget.initialSubjectId) {
      return false;
    }

    final subject = _subjectFor(note.subjectId);
    final filterMatches = switch (_filter) {
      _NoteFilter.all => true,
      _NoteFilter.subjects => note.subjectId != null,
      _NoteFilter.global => note.subjectId == null,
    };
    final query = _query.trim().toLowerCase();
    final queryMatches =
        query.isEmpty ||
        '${note.title} ${note.content} ${note.tags.join(' ')} ${subject?.name ?? ''}'
            .toLowerCase()
            .contains(query);
    return filterMatches && queryMatches;
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

  Future<void> _showDetails(AcademicNote note) {
    final subject = _subjectFor(note.subjectId);
    final colorScheme = Theme.of(context).colorScheme;
    return AppDetailBottomSheet.show(
      context: context,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                note.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            IconButton(
              tooltip: 'Editar',
              onPressed: () {
                Navigator.of(context).pop();
                widget.onEdit(note);
              },
              icon: const Icon(Icons.edit_outlined),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _DetailPill(
          icon: Icons.menu_book_outlined,
          text: subject?.name ?? 'Nota global',
        ),
        const SizedBox(height: 8),
        Text(
          'Actualizado ${AppDateFormatter.dateTime(note.updatedAt)}',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 4),
        Text(
          'Creado ${AppDateFormatter.dateTime(note.createdAt)}',
          style: TextStyle(color: colorScheme.onSurfaceVariant),
        ),
        if (note.tags.isNotEmpty) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [for (final tag in note.tags) _TagChip(label: tag)],
          ),
        ],
        const SizedBox(height: 18),
        SelectableText(
          note.content,
          style: const TextStyle(fontSize: 15, height: 1.45),
        ),
      ],
    );
  }
}

class _NotesSummaryCard extends StatelessWidget {
  const _NotesSummaryCard({
    required this.total,
    required this.linked,
    required this.global,
    required this.subjectName,
  });

  final int total;
  final int linked;
  final int global;
  final String? subjectName;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.auto_stories_outlined,
                color: colorScheme.onPrimary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Biblioteca personal',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subjectName == null
                        ? '$total apuntes - $linked por materia - $global globales'
                        : '$total apuntes guardados para $subjectName',
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

class _NoteFilterBar extends StatelessWidget {
  const _NoteFilterBar({
    required this.selected,
    required this.notes,
    required this.onSelected,
  });

  final _NoteFilter selected;
  final List<AcademicNote> notes;
  final ValueChanged<_NoteFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final filter in _NoteFilter.values) ...[
            ChoiceChip(
              label: Text('${filter.label} (${_count(filter)})'),
              selected: selected == filter,
              onSelected: (_) => onSelected(filter),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  int _count(_NoteFilter filter) {
    return switch (filter) {
      _NoteFilter.all => notes.length,
      _NoteFilter.subjects =>
        notes.where((note) => note.subjectId != null).length,
      _NoteFilter.global =>
        notes.where((note) => note.subjectId == null).length,
    };
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.subject,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final AcademicNote note;
  final Subject? subject;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final accent = subject == null
        ? colorScheme.primary
        : Color(subject!.accentColorValue);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        onLongPress: onEdit,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.edit_note_outlined, color: accent),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subject?.name ?? 'Nota global',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<_NoteAction>(
                    tooltip: 'Opciones',
                    onSelected: (action) {
                      switch (action) {
                        case _NoteAction.view:
                          onTap();
                        case _NoteAction.edit:
                          onEdit();
                        case _NoteAction.delete:
                          onDelete();
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                        value: _NoteAction.view,
                        child: Text('Ver detalle'),
                      ),
                      PopupMenuItem(
                        value: _NoteAction.edit,
                        child: Text('Editar'),
                      ),
                      PopupMenuItem(
                        value: _NoteAction.delete,
                        child: Text('Mover a papelera'),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                note.content,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(height: 1.35),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _TagChip(
                    label:
                        'Actualizado ${AppDateFormatter.date(note.updatedAt)}',
                  ),
                  for (final tag in note.tags.take(3)) _TagChip(label: tag),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _DetailPill extends StatelessWidget {
  const _DetailPill({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: colorScheme.onPrimaryContainer),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyNotesCard extends StatelessWidget {
  const _EmptyNotesCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(Icons.note_add_outlined, color: colorScheme.primary, size: 38),
            const SizedBox(height: 10),
            const Text(
              'Aun no hay apuntes',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              'Guarda ideas, resumenes, formulas o dudas por materia.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoteFormDialog extends StatefulWidget {
  const _NoteFormDialog({required this.subjects, this.initialNote});

  final List<Subject> subjects;
  final AcademicNote? initialNote;

  @override
  State<_NoteFormDialog> createState() => _NoteFormDialogState();
}

class _NoteFormDialogState extends State<_NoteFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagsController = TextEditingController();
  late String _subjectId;

  @override
  void initState() {
    super.initState();
    final note = widget.initialNote;
    _subjectId = note?.subjectId ?? '';
    if (note != null) {
      _titleController.text = note.title;
      _contentController.text = note.content;
      _tagsController.text = note.tags.join(', ');
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final now = DateTime.now();
    Navigator.of(context).pop(
      AcademicNote(
        id: widget.initialNote?.id,
        subjectId: _subjectId.isEmpty ? null : _subjectId,
        title: _titleController.text.trim(),
        content: _contentController.text.trim(),
        tags: _parseTags(_tagsController.text),
        createdAt: widget.initialNote?.createdAt ?? now,
        updatedAt: now,
        deletedAt: widget.initialNote?.deletedAt,
      ),
    );
  }

  List<String> _parseTags(String value) {
    return value
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialNote == null ? 'Nuevo apunte' : 'Editar apunte',
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
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Campo requerido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                initialValue: _subjectId,
                decoration: const InputDecoration(labelText: 'Materia'),
                items: [
                  const DropdownMenuItem(value: '', child: Text('Nota global')),
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
                controller: _contentController,
                decoration: const InputDecoration(labelText: 'Contenido'),
                minLines: 5,
                maxLines: 10,
                textCapitalization: TextCapitalization.sentences,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Campo requerido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  labelText: 'Etiquetas',
                  hintText: 'parcial, formula, resumen',
                ),
                textInputAction: TextInputAction.done,
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

enum _NoteAction { view, edit, delete }

enum _NoteFilter {
  all('Todo'),
  subjects('Por materia'),
  global('Globales');

  const _NoteFilter(this.label);

  final String label;
}
