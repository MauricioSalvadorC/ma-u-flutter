enum ExpenseCategory {
  transport('Transporte'),
  food('Comida'),
  copies('Copias'),
  books('Libros'),
  tuition('Matricula'),
  supplies('Materiales'),
  leisure('Ocio'),
  other('Otro');

  const ExpenseCategory(this.label);

  final String label;
}

class UniversityExpense {
  const UniversityExpense({
    this.id,
    required this.title,
    required this.amountCents,
    required this.category,
    required this.spentAt,
    required this.note,
    required this.deletedAt,
  });

  final int? id;
  final String title;
  final int amountCents;
  final ExpenseCategory category;
  final DateTime spentAt;
  final String note;
  final DateTime? deletedAt;

  double get amount => amountCents / 100;
}
