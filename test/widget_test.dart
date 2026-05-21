import 'package:calculo_nota_flutter/app/app.dart';
import 'package:calculo_nota_flutter/features/grades/domain/grade_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
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

    expect(find.text('MA U'), findsOneWidget);
    expect(find.text('Calculadora de notas'), findsOneWidget);

    await tester.tap(find.text('Calculadora de notas'));
    await tester.pumpAndSettle();

    expect(find.text('Sistema 30% / 30% / 40%'), findsOneWidget);
    expect(find.text('Calcular nota necesaria'), findsOneWidget);
  });
}
