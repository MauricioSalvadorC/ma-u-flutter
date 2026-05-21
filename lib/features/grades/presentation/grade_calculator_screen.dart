import 'package:flutter/material.dart';

import '../domain/grade_calculator.dart';

class GradeCalculatorScreen extends StatefulWidget {
  const GradeCalculatorScreen({super.key});

  @override
  State<GradeCalculatorScreen> createState() => _GradeCalculatorScreenState();
}

class _GradeCalculatorScreenState extends State<GradeCalculatorScreen> {
  final _calculator = const GradeCalculator();
  final _firstTermController = TextEditingController();
  final _secondTermController = TextEditingController();
  final _desiredGradeController = TextEditingController(text: '3.0');
  final _thirdTermController = TextEditingController();

  String? _requiredGradeResult;
  String? _finalGradeResult;

  @override
  void dispose() {
    _firstTermController.dispose();
    _secondTermController.dispose();
    _desiredGradeController.dispose();
    _thirdTermController.dispose();
    super.dispose();
  }

  void _calculateRequiredGrade() {
    final firstTerm = _calculator.parseGrade(_firstTermController.text);
    final secondTerm = _calculator.parseGrade(_secondTermController.text);
    final desiredGrade = _calculator.parseGrade(_desiredGradeController.text);

    if (firstTerm == null || secondTerm == null || desiredGrade == null) {
      setState(() {
        _requiredGradeResult = 'Ingresa notas validas entre 0.0 y 5.0.';
      });
      return;
    }

    final requiredGrade = _calculator.requiredThirdTerm(
      firstTerm: firstTerm,
      secondTerm: secondTerm,
      desiredFinalGrade: desiredGrade,
    );

    setState(() {
      if (requiredGrade > 5) {
        _requiredGradeResult =
            'Necesitarias ${requiredGrade.toStringAsFixed(2)}. Con estos cortes, la meta supera 5.0.';
      } else if (requiredGrade <= 0) {
        _requiredGradeResult =
            'Ya alcanzaste la meta. Solo necesitas mantenerte.';
      } else {
        _requiredGradeResult =
            'Necesitas ${requiredGrade.toStringAsFixed(2)} en el tercer corte.';
      }
    });
  }

  void _calculateFinalGrade() {
    final firstTerm = _calculator.parseGrade(_firstTermController.text);
    final secondTerm = _calculator.parseGrade(_secondTermController.text);
    final thirdTerm = _calculator.parseGrade(_thirdTermController.text);

    if (firstTerm == null || secondTerm == null || thirdTerm == null) {
      setState(() {
        _finalGradeResult = 'Ingresa notas validas entre 0.0 y 5.0.';
      });
      return;
    }

    final finalGrade = _calculator.finalGrade(
      firstTerm: firstTerm,
      secondTerm: secondTerm,
      thirdTerm: thirdTerm,
    );

    setState(() {
      _finalGradeResult =
          'Tu nota final seria ${finalGrade.toStringAsFixed(2)}.';
    });
  }

  void _clearForm() {
    _firstTermController.clear();
    _secondTermController.clear();
    _desiredGradeController.text = '3.0';
    _thirdTermController.clear();

    setState(() {
      _requiredGradeResult = null;
      _finalGradeResult = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculadora de notas')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const _CalculatorIntro(),
            const SizedBox(height: 20),
            _GradeInput(label: 'Corte 1', controller: _firstTermController),
            const SizedBox(height: 12),
            _GradeInput(label: 'Corte 2', controller: _secondTermController),
            const SizedBox(height: 20),
            _GradeInput(
              label: 'Nota final deseada',
              controller: _desiredGradeController,
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _calculateRequiredGrade,
              icon: const Icon(Icons.flag_outlined),
              label: const Text('Calcular nota necesaria'),
            ),
            _ResultCard(text: _requiredGradeResult),
            const SizedBox(height: 24),
            _GradeInput(
              label: 'Posible corte 3',
              controller: _thirdTermController,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _calculateFinalGrade,
              icon: const Icon(Icons.functions),
              label: const Text('Calcular nota final'),
            ),
            _ResultCard(text: _finalGradeResult),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: _clearForm,
              icon: const Icon(Icons.refresh),
              label: const Text('Limpiar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CalculatorIntro extends StatelessWidget {
  const _CalculatorIntro();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Sistema 30% / 30% / 40%',
          style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          'Usa punto o coma decimal. Por ahora validamos notas entre 0.0 y 5.0.',
          style: textTheme.bodyMedium,
        ),
      ],
    );
  }
}

class _GradeInput extends StatelessWidget {
  const _GradeInput({required this.label, required this.controller});

  final String label;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.grade_outlined),
      ),
    );
  }
}

class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.text});

  final String? text;

  @override
  Widget build(BuildContext context) {
    if (text == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            text!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
      ),
    );
  }
}
