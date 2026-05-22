import 'package:flutter/material.dart';

import '../../../core/settings/app_settings_controller.dart';
import '../../grades/presentation/grade_calculator_screen.dart';
import '../../schedule/presentation/academic_planner_screen.dart';
import '../../settings/presentation/settings_screen.dart';
import '../../tasks/presentation/tasks_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = AppSettingsScope.of(context);
    final selectedColor = settings.selectedColor;
    final modules = [
      _DashboardModule(
        icon: Icons.calculate_outlined,
        title: 'Calcular notas',
        subtitle: 'Final, cortes y cuanto necesitas para pasar.',
        color: selectedColor.color,
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const GradeCalculatorScreen(),
            ),
          );
        },
      ),
      _DashboardModule(
        icon: Icons.calendar_month_outlined,
        title: 'Horario',
        subtitle: 'Clases, salones, docentes y bloques de estudio.',
        color: const Color(0xFF2563EB),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const AcademicPlannerScreen(),
            ),
          );
        },
      ),
      _DashboardModule(
        icon: Icons.task_alt_outlined,
        title: 'Tareas',
        subtitle: 'Recordatorios, entregas y avance por materia.',
        color: const Color(0xFF7C3AED),
        onTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute<void>(builder: (_) => const TasksScreen()));
        },
      ),
      const _DashboardModule(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Gastos',
        subtitle: 'Transporte, comida, copias y presupuesto mensual.',
        color: Color(0xFFDC6B19),
      ),
      const _DashboardModule(
        icon: Icons.track_changes_outlined,
        title: 'Metas academicas',
        subtitle: 'Promedio acumulado, semestre y plan para subir notas.',
        color: Color(0xFFBE123C),
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const _AppTitle(),
        actions: [
          IconButton(
            tooltip: 'Configuracion',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
              );
            },
            icon: const Icon(Icons.tune_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          children: [
            _StatusHeader(colorOption: selectedColor),
            const SizedBox(height: 20),
            Text(
              'Modulos principales',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 620;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: modules.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isWide ? 2 : 1,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    mainAxisExtent: 126,
                  ),
                  itemBuilder: (context, index) {
                    return _ModuleCard(module: modules[index]);
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            const _RoadmapPanel(),
          ],
        ),
      ),
    );
  }
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.colorOption});

  final AppColorOption colorOption;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          colors: [
            colorOption.gradientStart,
            colorOption.color,
            colorOption.gradientEnd,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withAlpha(24),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(36),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withAlpha(72)),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Image(
                      image: AssetImage('assets/logo/ma_u_logo_5.png'),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const Spacer(),
                const _StatusChip(label: 'Semana activa'),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              'Centro de control universitario',
              style: textTheme.headlineSmall?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Notas, horario, tareas, gastos y metas en una sola app.',
              style: textTheme.bodyLarge?.copyWith(
                color: Colors.white.withAlpha(224),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AppTitle extends StatelessWidget {
  const _AppTitle();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(
            'assets/logo/ma_u_logo_3.png',
            width: 30,
            height: 30,
            fit: BoxFit.contain,
          ),
        ),
        const SizedBox(width: 10),
        const Text('Ma-U'),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(36),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withAlpha(72)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _DashboardModule {
  const _DashboardModule({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;
}

class _ModuleCard extends StatelessWidget {
  const _ModuleCard({required this.module});

  final _DashboardModule module;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: module.onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: module.color.withAlpha(42),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(module.icon, color: module.color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      module.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      module.subtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                module.onTap == null ? Icons.lock_clock_outlined : Icons.east,
                color: module.onTap == null
                    ? colorScheme.outline
                    : colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RoadmapPanel extends StatelessWidget {
  const _RoadmapPanel();

  static const items = [
    'Promedio acumulado',
    'Control de parciales',
    'Lista de materias',
    'Notas por semestre',
    'Agenda de estudio',
    'Modo semana de parciales',
  ];

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
                Icon(Icons.auto_awesome_outlined, color: colorScheme.primary),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Ideas buenas para construir despues',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [for (final item in items) _RoadmapChip(label: item)],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoadmapChip extends StatelessWidget {
  const _RoadmapChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withAlpha(128),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: colorScheme.onSecondaryContainer,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
