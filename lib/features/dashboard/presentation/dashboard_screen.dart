import 'package:flutter/material.dart';

import '../../grades/presentation/grade_calculator_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MA U')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const _WelcomeHeader(),
            const SizedBox(height: 20),
            _ActionCard(
              icon: Icons.calculate_outlined,
              title: 'Calculadora de notas',
              subtitle: 'Calcula tu nota final o cuanto necesitas en el corte.',
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const GradeCalculatorScreen(),
                  ),
                );
              },
            ),
            const SizedBox(height: 12),
            const _ActionCard(
              icon: Icons.calendar_month_outlined,
              title: 'Agenda academica',
              subtitle: 'Proximo modulo para clases, entregas y parciales.',
            ),
            const SizedBox(height: 12),
            const _ActionCard(
              icon: Icons.task_alt_outlined,
              title: 'Tareas y proyectos',
              subtitle: 'Espacio planeado para pendientes por materia.',
            ),
            const SizedBox(height: 12),
            const _ActionCard(
              icon: Icons.menu_book_outlined,
              title: 'Recursos de estudio',
              subtitle: 'Apuntes, enlaces y recordatorios de cada curso.',
            ),
          ],
        ),
      ),
    );
  }
}

class _WelcomeHeader extends StatelessWidget {
  const _WelcomeHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tu espacio universitario',
          style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Empezamos con notas, pero la idea es crecer hacia una app que ordene clases, entregas, parciales y recursos.',
          style: textTheme.bodyLarge,
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.primaryContainer,
                foregroundColor: colorScheme.onPrimaryContainer,
                child: Icon(icon),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle),
                  ],
                ),
              ),
              if (onTap != null) const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
