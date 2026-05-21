class GradeWeights {
  const GradeWeights({
    this.firstTerm = 0.3,
    this.secondTerm = 0.3,
    this.thirdTerm = 0.4,
  });

  final double firstTerm;
  final double secondTerm;
  final double thirdTerm;
}

class GradeCalculator {
  const GradeCalculator({this.weights = const GradeWeights()});

  final GradeWeights weights;

  double finalGrade({
    required double firstTerm,
    required double secondTerm,
    required double thirdTerm,
  }) {
    return firstTerm * weights.firstTerm +
        secondTerm * weights.secondTerm +
        thirdTerm * weights.thirdTerm;
  }

  double requiredThirdTerm({
    required double firstTerm,
    required double secondTerm,
    required double desiredFinalGrade,
  }) {
    return (desiredFinalGrade -
            firstTerm * weights.firstTerm -
            secondTerm * weights.secondTerm) /
        weights.thirdTerm;
  }

  double? parseGrade(String value) {
    final normalizedValue = value.trim().replaceAll(',', '.');
    if (normalizedValue.isEmpty) {
      return null;
    }

    final grade = double.tryParse(normalizedValue);
    if (grade == null || grade < 0 || grade > 5) {
      return null;
    }

    return grade;
  }
}
