import 'package:flutter/material.dart';
import 'package:mini_accounting_system/core/function/delete_confirmation.dart';
import 'package:mini_accounting_system/core/shered_widget/custom_app_bar.dart';
import 'package:mini_accounting_system/features/edit_feature/edit_expense_screen.dart';
import 'package:mini_accounting_system/sqldb.dart';

class ExpenseDetailsScreen extends StatefulWidget {
  final String reportType; // 'daily' or 'monthly' or 'yearly'
  final DateTime selectedDate;

  const ExpenseDetailsScreen({
    super.key,
    required this.reportType,
    required this.selectedDate,
  });

  @override
  State<ExpenseDetailsScreen> createState() => _ExpenseDetailsScreenState();
}

class _ExpenseDetailsScreenState extends State<ExpenseDetailsScreen> {
  final SqlDb db = SqlDb();
  Map<String, List<Map<String, dynamic>>> categorizedExpenses = {};
  Map<String, double> categoryTotals = {};
  String titleIncomes = "";

  Future<void> fetchData() async {
    String condition = '';
    final d = widget.selectedDate;

    if (widget.reportType == 'daily') {
      condition = 'E.date = "${d.year}/${d.month}/${d.day}"';
      titleIncomes = 'اليومية';
    } else if (widget.reportType == 'monthly') {
      condition = 'E.date LIKE "${d.year}/${d.month}/%"';
      titleIncomes = 'الشهرية';
    } else if (widget.reportType == 'yearly') {
      condition = 'E.date LIKE "${d.year}/%"';
      titleIncomes = 'السنوية';
    }

    final result = await db.readData('''
      SELECT E.id, EC.name AS category, E.amount, E.note, E.date
      FROM DailyExpenses E
      JOIN ExpenseCategories EC ON E.category_id = EC.id
      WHERE $condition
      ORDER BY E.date ASC
    ''');

    Map<String, List<Map<String, dynamic>>> grouped = {};
    Map<String, double> totals = {};

    for (var item in result) {
      final category = item['category'] ?? 'أخرى';
      grouped.putIfAbsent(category, () => []).add(item);

      final amount = item['amount'] ?? 0.0;
      totals[category] = (totals[category] ?? 0.0) + amount;
    }

    setState(() {
      categorizedExpenses = grouped;
      categoryTotals = totals;
    });
  }

  Future<void> deleteExpense(int id) async {
    final confirmed = await showDeleteConfirmationDialog(context: context);

    if (confirmed) {
      await db.deleteData('DELETE FROM DailyExpenses WHERE id = $id');
      fetchData();
      Navigator.pop(context);
    }
  }

  Future<void> showEditDialog(Map<String, dynamic> expense) async {
    int? creditorId;

    // فقط إذا كان نوع المصروف "ديون"، نحاول جلب رقم الدائن من اسمه في الملاحظة
    if (expense['category'] == 'ديون' && expense['note'] != null) {
      final creditor = await db.readData('''
        SELECT id FROM Creditors WHERE name = "${expense['note']}"
      ''');

      if (creditor.isNotEmpty) {
        creditorId = creditor.first['id'];
      }
    }

    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditExpenseScreen(
              expense: {
                'id': expense['id'],
                'amount': expense['amount'],
                'date': expense['date'],
                'note': expense['note'],
                'category': expense['category'],
                'creditorid': creditorId, // ✅ تمرير id الدائن إن وُجد
              },
            ),
      ),
    );

    if (updated == true) {
      fetchData();
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CustomAppBar(tital: 'تفاصيل المصروفات', isBack: true),
            const SizedBox(height: 20),
            categorizedExpenses.isEmpty
                ? const Center(
                  child: Text('لا توجد مصروفات لهذا النطاق الزمني'),
                )
                : Align(
                  alignment: Alignment.center,
                  child: Text(
                    'الإيرادات $titleIncomes',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                child: ListView(
                  children:
                      categorizedExpenses.entries.map((entry) {
                        final category = entry.key;
                        final expenses = entry.value;
                        final total = categoryTotals[category] ?? 0.0;

                        return ExpansionTile(
                          title: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                category,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${total.toStringAsFixed(0)} ر.ي',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          children:
                              expenses.map((e) {
                                return ListTile(
                                  title: Text('${e['note'] ?? 'بدون ملاحظة'}'),
                                  subtitle: Text('📅 ${e['date']}'),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        '${e['amount'].toStringAsFixed(0)} ر.ي',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () => showEditDialog(e),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete),
                                        onPressed: () => deleteExpense(e['id']),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                        );
                      }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
