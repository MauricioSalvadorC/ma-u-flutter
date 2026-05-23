import 'package:flutter/material.dart';

import '../../../core/formatters/app_date_formatter.dart';
import '../../../core/formatters/money_formatter.dart';
import '../../../core/widgets/app_detail_bottom_sheet.dart';
import '../../../core/widgets/destructive_confirmation_dialog.dart';
import '../../../data/database/app_database_provider.dart';
import '../data/expense_repository.dart';
import '../domain/university_expense.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  static const _budgetKey = 'monthly_expense_budget_cents';

  late final ExpenseRepository _expenseRepository;
  ExpenseCategory? _selectedCategory;
  int _monthlyBudgetCents = 60000000;

  @override
  void initState() {
    super.initState();
    final database = AppDatabaseProvider.instance;
    _expenseRepository = ExpenseRepository(database);
    _loadBudget();
  }

  Future<void> _loadBudget() async {
    final value = await AppDatabaseProvider.instance.settingsDao.getValue(
      _budgetKey,
    );
    final budget = int.tryParse(value ?? '');
    if (budget != null && mounted) {
      setState(() {
        _monthlyBudgetCents = budget;
      });
    }
  }

  Future<void> _saveBudget(int cents) async {
    await AppDatabaseProvider.instance.settingsDao.setValue(
      key: _budgetKey,
      value: cents.toString(),
    );
    if (mounted) {
      setState(() {
        _monthlyBudgetCents = cents;
      });
    }
  }

  Future<void> _openBudgetForm() async {
    final cents = await showDialog<int>(
      context: context,
      builder: (_) => _BudgetDialog(initialCents: _monthlyBudgetCents),
    );
    if (cents != null) {
      await _saveBudget(cents);
    }
  }

  Future<void> _openExpenseForm({UniversityExpense? initialExpense}) async {
    final expense = await showDialog<UniversityExpense>(
      context: context,
      builder: (_) => _ExpenseFormDialog(initialExpense: initialExpense),
    );
    if (expense != null) {
      await _expenseRepository.saveExpense(expense);
    }
  }

  Future<void> _moveToTrash(UniversityExpense expense) async {
    final id = expense.id;
    if (id == null) {
      return;
    }

    final confirmed = await DestructiveConfirmationDialog.show(
      context: context,
      title: 'Mover gasto a papelera',
      message:
          'El gasto "${expense.title}" se ocultara del resumen. Podras restaurarlo despues.',
      confirmLabel: 'Mover',
    );

    if (confirmed) {
      await _expenseRepository.moveToTrash(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<UniversityExpense>>(
      stream: _expenseRepository.watchExpenses(),
      builder: (context, snapshot) {
        final expenses = snapshot.data ?? const <UniversityExpense>[];
        return _ExpensesView(
          expenses: expenses,
          monthlyBudgetCents: _monthlyBudgetCents,
          selectedCategory: _selectedCategory,
          onBudgetTap: _openBudgetForm,
          onAddExpense: () => _openExpenseForm(),
          onEditExpense: (expense) => _openExpenseForm(initialExpense: expense),
          onDeleteExpense: _moveToTrash,
          onSelectCategory: (category) {
            setState(() {
              _selectedCategory = category;
            });
          },
        );
      },
    );
  }
}

class _ExpensesView extends StatelessWidget {
  const _ExpensesView({
    required this.expenses,
    required this.monthlyBudgetCents,
    required this.selectedCategory,
    required this.onBudgetTap,
    required this.onAddExpense,
    required this.onEditExpense,
    required this.onDeleteExpense,
    required this.onSelectCategory,
  });

  final List<UniversityExpense> expenses;
  final int monthlyBudgetCents;
  final ExpenseCategory? selectedCategory;
  final VoidCallback onBudgetTap;
  final VoidCallback onAddExpense;
  final ValueChanged<UniversityExpense> onEditExpense;
  final ValueChanged<UniversityExpense> onDeleteExpense;
  final ValueChanged<ExpenseCategory?> onSelectCategory;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monthExpenses = expenses.where((expense) {
      return expense.spentAt.year == now.year &&
          expense.spentAt.month == now.month;
    }).toList();
    final filteredExpenses = monthExpenses.where((expense) {
      return selectedCategory == null || expense.category == selectedCategory;
    }).toList();
    final spentCents = monthExpenses.fold<int>(
      0,
      (total, expense) => total + expense.amountCents,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Gastos universitarios')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onAddExpense,
        icon: const Icon(Icons.add_outlined),
        label: const Text('Gasto'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 96),
          children: [
            _ExpenseSummaryCard(
              spentCents: spentCents,
              budgetCents: monthlyBudgetCents,
              onBudgetTap: onBudgetTap,
            ),
            const SizedBox(height: 16),
            _CategoryFilterBar(
              selectedCategory: selectedCategory,
              expenses: monthExpenses,
              onSelected: onSelectCategory,
            ),
            const SizedBox(height: 16),
            _CategoryBreakdown(expenses: monthExpenses),
            const SizedBox(height: 16),
            if (filteredExpenses.isEmpty)
              const _EmptyExpensesCard()
            else
              for (final expense in filteredExpenses) ...[
                _ExpenseCard(
                  expense: expense,
                  onEdit: () => onEditExpense(expense),
                  onDelete: () => onDeleteExpense(expense),
                ),
                const SizedBox(height: 10),
              ],
          ],
        ),
      ),
    );
  }
}

class _ExpenseSummaryCard extends StatelessWidget {
  const _ExpenseSummaryCard({
    required this.spentCents,
    required this.budgetCents,
    required this.onBudgetTap,
  });

  final int spentCents;
  final int budgetCents;
  final VoidCallback onBudgetTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final progress = budgetCents == 0 ? 0.0 : spentCents / budgetCents;
    final statusColor = progress >= 1
        ? const Color(0xFFBE123C)
        : progress >= 0.8
        ? const Color(0xFFD97706)
        : const Color(0xFF16A34A);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onBudgetTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(36),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.account_balance_wallet_outlined,
                      color: statusColor,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Presupuesto mensual',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${MoneyFormatter.pesos(spentCents)} de ${MoneyFormatter.pesos(budgetCents)}',
                          style: TextStyle(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.tune_outlined),
                ],
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  minHeight: 10,
                  value: progress.clamp(0, 1),
                  color: statusColor,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryFilterBar extends StatelessWidget {
  const _CategoryFilterBar({
    required this.selectedCategory,
    required this.expenses,
    required this.onSelected,
  });

  final ExpenseCategory? selectedCategory;
  final List<UniversityExpense> expenses;
  final ValueChanged<ExpenseCategory?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          ChoiceChip(
            label: Text('Todos (${expenses.length})'),
            selected: selectedCategory == null,
            onSelected: (_) => onSelected(null),
          ),
          const SizedBox(width: 8),
          for (final category in ExpenseCategory.values) ...[
            ChoiceChip(
              label: Text('${category.label} (${_count(category)})'),
              selected: selectedCategory == category,
              onSelected: (_) => onSelected(category),
            ),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }

  int _count(ExpenseCategory category) {
    return expenses.where((expense) => expense.category == category).length;
  }
}

class _CategoryBreakdown extends StatelessWidget {
  const _CategoryBreakdown({required this.expenses});

  final List<UniversityExpense> expenses;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final totals = {
      for (final category in ExpenseCategory.values)
        category: expenses
            .where((expense) => expense.category == category)
            .fold<int>(0, (total, expense) => total + expense.amountCents),
    };
    final visibleTotals =
        totals.entries.where((entry) => entry.value > 0).toList()
          ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen por categoria',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            if (visibleTotals.isEmpty)
              Text(
                'Aun no hay gastos este mes.',
                style: TextStyle(color: colorScheme.onSurfaceVariant),
              )
            else
              for (final entry in visibleTotals.take(5)) ...[
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        entry.key.label,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    Text(MoneyFormatter.pesos(entry.value)),
                  ],
                ),
                const SizedBox(height: 8),
              ],
          ],
        ),
      ),
    );
  }
}

class _ExpenseCard extends StatelessWidget {
  const _ExpenseCard({
    required this.expense,
    required this.onEdit,
    required this.onDelete,
  });

  final UniversityExpense expense;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoryColor = _categoryColor(expense.category);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _showDetails(context),
        onLongPress: () => _showActions(context),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: categoryColor.withAlpha(36),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _categoryIcon(expense.category),
                  color: categoryColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${expense.category.label} - ${AppDateFormatter.date(expense.spentAt)}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                MoneyFormatter.pesos(expense.amountCents),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
              PopupMenuButton<_ExpenseAction>(
                tooltip: 'Opciones de gasto',
                onSelected: (action) {
                  switch (action) {
                    case _ExpenseAction.view:
                      _showDetails(context);
                    case _ExpenseAction.edit:
                      onEdit();
                    case _ExpenseAction.delete:
                      onDelete();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: _ExpenseAction.view,
                    child: Text('Ver detalle'),
                  ),
                  PopupMenuItem(
                    value: _ExpenseAction.edit,
                    child: Text('Editar'),
                  ),
                  PopupMenuItem(
                    value: _ExpenseAction.delete,
                    child: Text('Mover a papelera'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    AppDetailBottomSheet.show(
      context: context,
      children: [
        Text(
          expense.title,
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
        ),
        const SizedBox(height: 14),
        _ExpenseDetailRow(
          label: 'Monto',
          value: MoneyFormatter.pesos(expense.amountCents),
        ),
        _ExpenseDetailRow(label: 'Categoria', value: expense.category.label),
        _ExpenseDetailRow(
          label: 'Fecha',
          value: AppDateFormatter.date(expense.spentAt),
        ),
        if (expense.note.isNotEmpty)
          _ExpenseDetailRow(label: 'Nota', value: expense.note),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onEdit();
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Editar'),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.of(context).pop();
                  onDelete();
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Papelera'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showActions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.visibility_outlined),
                  title: const Text('Ver detalle'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showDetails(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit_outlined),
                  title: const Text('Editar'),
                  onTap: () {
                    Navigator.of(context).pop();
                    onEdit();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Mover a papelera'),
                  onTap: () {
                    Navigator.of(context).pop();
                    onDelete();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ExpenseDetailRow extends StatelessWidget {
  const _ExpenseDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _EmptyExpensesCard extends StatelessWidget {
  const _EmptyExpensesCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(
              Icons.receipt_long_outlined,
              color: colorScheme.primary,
              size: 38,
            ),
            const SizedBox(height: 10),
            const Text(
              'Sin gastos este mes',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 4),
            Text(
              'Registra transporte, comida, copias, libros o materiales.',
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _ExpenseFormDialog extends StatefulWidget {
  const _ExpenseFormDialog({this.initialExpense});

  final UniversityExpense? initialExpense;

  @override
  State<_ExpenseFormDialog> createState() => _ExpenseFormDialogState();
}

class _ExpenseFormDialogState extends State<_ExpenseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  ExpenseCategory _category = ExpenseCategory.transport;
  DateTime _spentAt = DateTime.now();

  @override
  void initState() {
    super.initState();
    final expense = widget.initialExpense;
    if (expense != null) {
      _titleController.text = expense.title;
      _amountController.text = (expense.amountCents / 100).toStringAsFixed(0);
      _noteController.text = expense.note;
      _category = expense.category;
      _spentAt = expense.spentAt;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _spentAt,
      firstDate: DateTime(DateTime.now().year - 2),
      lastDate: DateTime(DateTime.now().year + 2),
    );

    if (selectedDate != null) {
      setState(() {
        _spentAt = selectedDate;
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    Navigator.of(context).pop(
      UniversityExpense(
        id: widget.initialExpense?.id,
        title: _titleController.text.trim(),
        amountCents: _parseMoneyToCents(_amountController.text)!,
        category: _category,
        spentAt: _spentAt,
        note: _noteController.text.trim(),
        deletedAt: widget.initialExpense?.deletedAt,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.initialExpense == null ? 'Nuevo gasto' : 'Editar gasto',
      ),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Titulo'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Campo requerido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(labelText: 'Monto'),
                validator: (value) {
                  final cents = _parseMoneyToCents(value ?? '');
                  if (cents == null || cents <= 0) {
                    return 'Ingresa un monto valido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<ExpenseCategory>(
                initialValue: _category,
                decoration: const InputDecoration(labelText: 'Categoria'),
                items: [
                  for (final category in ExpenseCategory.values)
                    DropdownMenuItem(
                      value: category,
                      child: Text(category.label),
                    ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _category = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.event_outlined),
                label: Text(AppDateFormatter.date(_spentAt)),
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _noteController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Nota'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _save, child: const Text('Guardar')),
      ],
    );
  }
}

class _BudgetDialog extends StatefulWidget {
  const _BudgetDialog({required this.initialCents});

  final int initialCents;

  @override
  State<_BudgetDialog> createState() => _BudgetDialogState();
}

class _BudgetDialogState extends State<_BudgetDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: (widget.initialCents / 100).toStringAsFixed(0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final cents = _parseMoneyToCents(_controller.text);
    if (cents == null || cents <= 0) {
      return;
    }
    Navigator.of(context).pop(cents);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Presupuesto mensual'),
      content: TextField(
        controller: _controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: const InputDecoration(labelText: 'Monto'),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _save, child: const Text('Guardar')),
      ],
    );
  }
}

enum _ExpenseAction { view, edit, delete }

int? _parseMoneyToCents(String value) {
  final normalized = value.trim().replaceAll('.', '').replaceAll(',', '.');
  final amount = double.tryParse(normalized);
  if (amount == null) {
    return null;
  }
  return (amount * 100).round();
}

Color _categoryColor(ExpenseCategory category) {
  return switch (category) {
    ExpenseCategory.transport => const Color(0xFF2563EB),
    ExpenseCategory.food => const Color(0xFF16A34A),
    ExpenseCategory.copies => const Color(0xFF7C3AED),
    ExpenseCategory.books => const Color(0xFFBE123C),
    ExpenseCategory.tuition => const Color(0xFFDC6B19),
    ExpenseCategory.supplies => const Color(0xFF0F766E),
    ExpenseCategory.leisure => const Color(0xFFC026D3),
    ExpenseCategory.other => const Color(0xFF475569),
  };
}

IconData _categoryIcon(ExpenseCategory category) {
  return switch (category) {
    ExpenseCategory.transport => Icons.directions_bus_outlined,
    ExpenseCategory.food => Icons.restaurant_outlined,
    ExpenseCategory.copies => Icons.content_copy_outlined,
    ExpenseCategory.books => Icons.menu_book_outlined,
    ExpenseCategory.tuition => Icons.account_balance_outlined,
    ExpenseCategory.supplies => Icons.inventory_2_outlined,
    ExpenseCategory.leisure => Icons.local_activity_outlined,
    ExpenseCategory.other => Icons.more_horiz_outlined,
  };
}
