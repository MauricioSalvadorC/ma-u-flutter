import 'package:flutter/material.dart';

import '../../../core/settings/app_settings_controller.dart';
import '../../../core/settings/app_settings_repository.dart';
import '../../../data/database/app_database_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({required this.onComplete, super.key});

  final Future<void> Function() onComplete;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _budgetController = TextEditingController(text: '150000');
  ExpenseBudgetPeriod _budgetPeriod = ExpenseBudgetPeriod.weekly;
  bool _isSaving = false;

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    final budgetCents = _parseMoneyToCents(_budgetController.text);
    if (budgetCents == null || budgetCents <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un presupuesto valido.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final repository = AppSettingsRepository(AppDatabaseProvider.instance);
    await repository.setExpenseBudget(
      cents: budgetCents,
      period: _budgetPeriod,
    );
    await widget.onComplete();
  }

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsScope.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                gradient: LinearGradient(
                  colors: [
                    settings.selectedColor.gradientStart,
                    settings.selectedColor.color,
                    settings.selectedColor.gradientEnd,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Padding(
                padding: EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image(
                      image: AssetImage('assets/logo/ma_u_logo_5.png'),
                      width: 62,
                      height: 62,
                    ),
                    SizedBox(height: 18),
                    Text(
                      'Configura Ma-U',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Deja lista tu app para estudiar, organizarte y cuidar tu presupuesto.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Modo visual',
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
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Color principal',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final option in AppPalette.colors)
                    _ColorChoice(
                      option: option,
                      selected: settings.seedColor == option.color,
                      onTap: () => settings.setSeedColor(option.color),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _SectionCard(
              title: 'Presupuesto inicial',
              child: Column(
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
                    selected: {_budgetPeriod},
                    onSelectionChanged: (selection) {
                      setState(() {
                        _budgetPeriod = selection.first;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _budgetController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(labelText: 'Monto'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: _isSaving ? null : _finish,
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check),
              label: const Text('Empezar'),
            ),
            const SizedBox(height: 8),
            Text(
              'Luego podras cambiar esto desde Configuracion y Gastos.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _ColorChoice extends StatelessWidget {
  const _ColorChoice({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final AppColorOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
              color: selected
                  ? Theme.of(context).colorScheme.onSurface
                  : Colors.transparent,
              width: 3,
            ),
          ),
          child: selected
              ? const Icon(Icons.check, color: Colors.white, size: 18)
              : null,
        ),
      ),
    );
  }
}

int? _parseMoneyToCents(String value) {
  final normalized = value.trim().replaceAll('.', '').replaceAll(',', '.');
  final amount = double.tryParse(normalized);
  if (amount == null) {
    return null;
  }
  return (amount * 100).round();
}
