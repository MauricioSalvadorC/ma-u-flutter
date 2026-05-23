import 'package:flutter/material.dart';

import '../../../core/formatters/money_formatter.dart';
import '../../../core/settings/app_settings_controller.dart';
import '../../../core/settings/app_settings_repository.dart';
import '../../../data/database/app_database_provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late final AppSettingsRepository _repository;
  GradeScale _gradeScale = GradeScale.zeroToFive;
  ExpenseBudgetPeriod _budgetPeriod = ExpenseBudgetPeriod.weekly;
  int _budgetCents = 15000000;
  final _universityController = TextEditingController();
  final _careerController = TextEditingController();
  final _semesterController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _repository = AppSettingsRepository(AppDatabaseProvider.instance);
    _loadAdvancedSettings();
  }

  @override
  void dispose() {
    _universityController.dispose();
    _careerController.dispose();
    _semesterController.dispose();
    super.dispose();
  }

  Future<void> _loadAdvancedSettings() async {
    final gradeScale = await _repository.getGradeScale();
    final budget = await _repository.getExpenseBudgetCents();
    final budgetPeriod = await _repository.getExpenseBudgetPeriod();
    final university = await _repository.getUniversityName();
    final career = await _repository.getCareerName();
    final semester = await _repository.getCurrentSemester();

    if (!mounted) {
      return;
    }

    setState(() {
      _gradeScale = gradeScale ?? _gradeScale;
      _budgetCents = budget ?? _budgetCents;
      _budgetPeriod = budgetPeriod ?? _budgetPeriod;
      _universityController.text = university;
      _careerController.text = career;
      _semesterController.text = semester;
    });
  }

  Future<void> _setGradeScale(GradeScale scale) async {
    setState(() {
      _gradeScale = scale;
    });
    await _repository.setGradeScale(scale);
  }

  Future<void> _openBudgetDialog() async {
    final config = await showDialog<_BudgetConfig>(
      context: context,
      builder: (_) => _BudgetDialog(
        initialCents: _budgetCents,
        initialPeriod: _budgetPeriod,
      ),
    );

    if (config == null) {
      return;
    }

    await _repository.setExpenseBudget(
      cents: config.cents,
      period: config.period,
    );
    setState(() {
      _budgetCents = config.cents;
      _budgetPeriod = config.period;
    });
  }

  Future<void> _saveProfile() async {
    await _repository.setAcademicProfile(
      universityName: _universityController.text.trim(),
      careerName: _careerController.text.trim(),
      currentSemester: _semesterController.text.trim(),
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perfil academico guardado.')),
      );
    }
  }

  Future<void> _resetOnboarding() async {
    await _repository.setOnboardingCompleted(false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El onboarding aparecera al reiniciar la app.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsScope.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Configuracion')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Ajustes de Ma-U',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 6),
            Text(
              'Personaliza apariencia, presupuesto y datos academicos.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            _ColorPreview(settings: settings),
            const SizedBox(height: 12),
            _ThemeModePanel(settings: settings),
            const SizedBox(height: 12),
            _ColorPanel(settings: settings),
            const SizedBox(height: 12),
            _BudgetPanel(
              budgetCents: _budgetCents,
              period: _budgetPeriod,
              onTap: _openBudgetDialog,
            ),
            const SizedBox(height: 12),
            _GradeScalePanel(selected: _gradeScale, onSelected: _setGradeScale),
            const SizedBox(height: 12),
            _AcademicProfilePanel(
              universityController: _universityController,
              careerController: _careerController,
              semesterController: _semesterController,
              onSave: _saveProfile,
            ),
            const SizedBox(height: 12),
            _ResetPanel(onReset: _resetOnboarding),
          ],
        ),
      ),
    );
  }
}

class _ColorPreview extends StatelessWidget {
  const _ColorPreview({required this.settings});

  final AppSettingsController settings;

  @override
  Widget build(BuildContext context) {
    final option = settings.selectedColor;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [option.gradientStart, option.color, option.gradientEnd],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(40),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withAlpha(80)),
              ),
              child: const Padding(
                padding: EdgeInsets.all(5),
                child: Image(
                  image: AssetImage('assets/logo/ma_u_logo_5.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Vista previa',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Paleta ${option.name}',
                    style: TextStyle(color: Colors.white.withAlpha(224)),
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

class _ThemeModePanel extends StatelessWidget {
  const _ThemeModePanel({required this.settings});

  final AppSettingsController settings;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'Modo',
      child: SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(
            value: ThemeMode.system,
            icon: Icon(Icons.phone_android_outlined),
            label: Text('Sistema'),
          ),
          ButtonSegment(
            value: ThemeMode.light,
            icon: Icon(Icons.light_mode_outlined),
            label: Text('Claro'),
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            icon: Icon(Icons.dark_mode_outlined),
            label: Text('Oscuro'),
          ),
        ],
        selected: {settings.themeMode},
        onSelectionChanged: (selection) {
          settings.setThemeMode(selection.first);
        },
      ),
    );
  }
}

class _ColorPanel extends StatelessWidget {
  const _ColorPanel({required this.settings});

  final AppSettingsController settings;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'Paleta de colores',
      subtitle: 'El color elegido se aplica al tema, tarjetas y gradientes.',
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final option in AppPalette.colors)
            _ColorSwatchButton(
              option: option,
              isSelected: settings.seedColor == option.color,
              onTap: () => settings.setSeedColor(option.color),
            ),
        ],
      ),
    );
  }
}

class _BudgetPanel extends StatelessWidget {
  const _BudgetPanel({
    required this.budgetCents,
    required this.period,
    required this.onTap,
  });

  final int budgetCents;
  final ExpenseBudgetPeriod period;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'Presupuesto',
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(Icons.account_balance_wallet_outlined),
        title: Text(MoneyFormatter.pesos(budgetCents)),
        subtitle: Text(period.label),
        trailing: const Icon(Icons.edit_outlined),
        onTap: onTap,
      ),
    );
  }
}

class _GradeScalePanel extends StatelessWidget {
  const _GradeScalePanel({required this.selected, required this.onSelected});

  final GradeScale selected;
  final ValueChanged<GradeScale> onSelected;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'Escala de notas',
      subtitle: 'Preparado para adaptar calculadoras y metas academicas.',
      child: SegmentedButton<GradeScale>(
        segments: [
          for (final scale in GradeScale.values)
            ButtonSegment(value: scale, label: Text(scale.label)),
        ],
        selected: {selected},
        onSelectionChanged: (selection) => onSelected(selection.first),
      ),
    );
  }
}

class _AcademicProfilePanel extends StatelessWidget {
  const _AcademicProfilePanel({
    required this.universityController,
    required this.careerController,
    required this.semesterController,
    required this.onSave,
  });

  final TextEditingController universityController;
  final TextEditingController careerController;
  final TextEditingController semesterController;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'Perfil academico',
      child: Column(
        children: [
          TextField(
            controller: universityController,
            decoration: const InputDecoration(labelText: 'Universidad'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: careerController,
            decoration: const InputDecoration(labelText: 'Carrera'),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: semesterController,
            decoration: const InputDecoration(labelText: 'Semestre actual'),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: onSave,
              icon: const Icon(Icons.save_outlined),
              label: const Text('Guardar'),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResetPanel extends StatelessWidget {
  const _ResetPanel({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return _SettingsCard(
      title: 'Inicio guiado',
      subtitle: 'Puedes volver a mostrar el onboarding al reiniciar la app.',
      child: OutlinedButton.icon(
        onPressed: onReset,
        icon: const Icon(Icons.restart_alt_outlined),
        label: const Text('Mostrar onboarding otra vez'),
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 4),
              Text(
                subtitle!,
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              ),
            ],
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _ColorSwatchButton extends StatelessWidget {
  const _ColorSwatchButton({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  final AppColorOption option;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: option.name,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [option.gradientStart, option.color, option.gradientEnd],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? colorScheme.onSurface : Colors.transparent,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: option.color.withAlpha(isSelected ? 72 : 24),
                blurRadius: isSelected ? 12 : 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: isSelected
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : null,
        ),
      ),
    );
  }
}

class _BudgetDialog extends StatefulWidget {
  const _BudgetDialog({
    required this.initialCents,
    required this.initialPeriod,
  });

  final int initialCents;
  final ExpenseBudgetPeriod initialPeriod;

  @override
  State<_BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<_BudgetDialog> {
  late final TextEditingController _controller;
  late ExpenseBudgetPeriod _period;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: (widget.initialCents / 100).toStringAsFixed(0),
    );
    _period = widget.initialPeriod;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final cents = _parseMoneyToCents(_controller.text);
    if (cents == null || cents <= 0) {
      return;
    }
    Navigator.of(context).pop(_BudgetConfig(cents: cents, period: _period));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Presupuesto'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SegmentedButton<ExpenseBudgetPeriod>(
            segments: const [
              ButtonSegment(
                value: ExpenseBudgetPeriod.weekly,
                icon: Icon(Icons.view_week_outlined),
                label: Text('Semanal'),
              ),
              ButtonSegment(
                value: ExpenseBudgetPeriod.monthly,
                icon: Icon(Icons.calendar_month_outlined),
                label: Text('Mensual'),
              ),
            ],
            selected: {_period},
            onSelectionChanged: (selection) {
              setState(() {
                _period = selection.first;
              });
            },
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Monto'),
          ),
        ],
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

class _BudgetConfig {
  const _BudgetConfig({required this.cents, required this.period});

  final int cents;
  final ExpenseBudgetPeriod period;
}

int? _parseMoneyToCents(String value) {
  final normalized = value.trim().replaceAll('.', '').replaceAll(',', '.');
  final amount = double.tryParse(normalized);
  if (amount == null) {
    return null;
  }
  return (amount * 100).round();
}
