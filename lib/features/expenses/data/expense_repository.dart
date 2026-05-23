import 'package:drift/drift.dart';

import '../../../data/database/app_database.dart';
import '../domain/university_expense.dart';

class ExpenseRepository {
  const ExpenseRepository(this._database);

  final AppDatabase _database;

  Stream<List<UniversityExpense>> watchExpenses() {
    return _database.expensesDao.watchAll().map(
      (rows) => rows.map(_toDomain).toList(),
    );
  }

  Stream<List<UniversityExpense>> watchDeletedExpenses() {
    return _database.expensesDao.watchDeleted().map(
      (rows) => rows.map(_toDomain).toList(),
    );
  }

  Future<int> saveExpense(UniversityExpense expense) {
    if (expense.id != null) {
      return _database.expensesDao
          .updateExpense(_toCompanion(expense))
          .then((_) => expense.id!);
    }
    return _database.expensesDao.insertExpense(_toCompanion(expense));
  }

  Future<bool> moveToTrash(int id) {
    return _database.expensesDao.moveToTrash(id);
  }

  Future<bool> restoreExpense(int id) {
    return _database.expensesDao.restoreExpense(id);
  }

  UniversityExpense _toDomain(ExpenseRow row) {
    return UniversityExpense(
      id: row.id,
      title: row.title,
      amountCents: row.amountCents,
      category: ExpenseCategory.values[row.categoryIndex],
      spentAt: row.spentAt,
      note: row.note ?? '',
      deletedAt: row.deletedAt,
    );
  }

  ExpensesCompanion _toCompanion(UniversityExpense expense) {
    return ExpensesCompanion(
      id: expense.id == null ? const Value.absent() : Value(expense.id!),
      title: Value(expense.title),
      amountCents: Value(expense.amountCents),
      categoryIndex: Value(expense.category.index),
      spentAt: Value(expense.spentAt),
      note: Value(expense.note.isEmpty ? null : expense.note),
      deletedAt: Value(expense.deletedAt),
    );
  }
}
