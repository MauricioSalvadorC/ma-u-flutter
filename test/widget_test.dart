import 'package:calculo_nota_flutter/app/app.dart';
import 'package:calculo_nota_flutter/data/database/app_database.dart';
import 'package:calculo_nota_flutter/data/database/app_database_provider.dart';
import 'package:calculo_nota_flutter/features/grades/domain/grade_calculator.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() {
    AppDatabaseProvider.overrideForTesting(
      AppDatabase(NativeDatabase.memory()),
    );
  });

  tearDown(() async {
    await AppDatabaseProvider.resetForTesting();
  });

  group('GradeCalculator', () {
    const calculator = GradeCalculator();

    test('calculates final grade with 30, 30 and 40 percent weights', () {
      final result = calculator.finalGrade(
        firstTerm: 4,
        secondTerm: 3.5,
        thirdTerm: 4.2,
      );

      expect(result, closeTo(3.93, 0.001));
    });

    test('calculates required third term grade', () {
      final result = calculator.requiredThirdTerm(
        firstTerm: 3,
        secondTerm: 3,
        desiredFinalGrade: 3.5,
      );

      expect(result, closeTo(4.25, 0.001));
    });

    test('parses comma decimals and rejects invalid grades', () {
      expect(calculator.parseGrade('4,5'), 4.5);
      expect(calculator.parseGrade('-1'), isNull);
      expect(calculator.parseGrade('5.1'), isNull);
      expect(calculator.parseGrade('abc'), isNull);
    });
  });

  testWidgets('opens the grade calculator from dashboard', (tester) async {
    await tester.pumpWidget(const UniversityCompanionApp());

    expect(find.text('Ma-U'), findsOneWidget);
    expect(find.text('Calcular notas'), findsOneWidget);

    await tester.tap(find.text('Calcular notas'));
    await tester.pumpAndSettle();

    expect(find.text('Sistema 30% / 30% / 40%'), findsOneWidget);
    expect(find.text('Calcular nota necesaria'), findsOneWidget);
  });

  testWidgets('opens settings from dashboard', (tester) async {
    await tester.pumpWidget(const UniversityCompanionApp());

    await tester.tap(find.byTooltip('Configuracion'));
    await tester.pumpAndSettle();

    expect(find.text('Configuracion'), findsOneWidget);
    expect(find.text('Modo'), findsOneWidget);
    expect(find.text('Paleta de colores'), findsOneWidget);
  });

  testWidgets('opens academic planner from dashboard', (tester) async {
    await tester.pumpWidget(const UniversityCompanionApp());

    await tester.tap(find.text('Horario'));
    await tester.pumpAndSettle();

    expect(find.text('Centro academico'), findsOneWidget);
    expect(find.text('Semana organizada'), findsOneWidget);
    expect(find.text('Calculo diferencial'), findsWidgets);
  });

  testWidgets('creates a subject in academic planner', (tester) async {
    await tester.pumpWidget(const UniversityCompanionApp());

    await tester.tap(find.text('Horario'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Materias'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Etica');
    await tester.enterText(find.byType(TextFormField).at(1), 'Ana Ruiz');
    await tester.enterText(find.byType(TextFormField).at(2), 'D-210');
    await tester.enterText(find.byType(TextFormField).at(3), '2');

    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(find.text('Nueva materia'), findsNothing);
    expect(find.text('5'), findsOneWidget);
  });

  testWidgets('opens tasks from dashboard', (tester) async {
    await tester.pumpWidget(const UniversityCompanionApp());

    await tester.tap(find.text('Tareas'));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Tareas'), findsWidgets);
    expect(find.text('Control de entregas'), findsOneWidget);
  });
}
