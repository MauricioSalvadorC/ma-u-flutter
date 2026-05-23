part of '../database/app_database.dart';

@DriftAccessor(tables: [Expenses])
class ExpensesDao extends DatabaseAccessor<AppDatabase>
    with _$ExpensesDaoMixin {
  ExpensesDao(super.db);

  Stream<List<ExpenseRow>> watchAll() {
    return (select(expenses)
          ..where((table) => table.deletedAt.isNull())
          ..orderBy([
            (table) => OrderingTerm.desc(table.spentAt),
            (table) => OrderingTerm.desc(table.createdAt),
          ]))
        .watch();
  }

  Stream<List<ExpenseRow>> watchDeleted() {
    return (select(expenses)
          ..where((table) => table.deletedAt.isNotNull())
          ..orderBy([(table) => OrderingTerm.desc(table.deletedAt)]))
        .watch();
  }

  Future<int> insertExpense(ExpensesCompanion expense) {
    return into(expenses).insert(expense);
  }

  Future<bool> updateExpense(ExpensesCompanion expense) {
    final id = expense.id.value;
    return (update(expenses)..where((table) => table.id.equals(id)))
        .write(expense)
        .then((rows) => rows > 0);
  }

  Future<bool> moveToTrash(int id) {
    return (update(expenses)..where((table) => table.id.equals(id)))
        .write(ExpensesCompanion(deletedAt: Value(DateTime.now())))
        .then((rows) => rows > 0);
  }

  Future<bool> restoreExpense(int id) {
    return (update(expenses)..where((table) => table.id.equals(id)))
        .write(const ExpensesCompanion(deletedAt: Value(null)))
        .then((rows) => rows > 0);
  }
}
