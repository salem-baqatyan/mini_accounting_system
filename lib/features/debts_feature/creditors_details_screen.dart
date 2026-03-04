import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mini_accounting_system/core/function/delete_confirmation.dart';
import 'package:mini_accounting_system/core/shered_widget/action_button_widget.dart';
import 'package:mini_accounting_system/core/shered_widget/custom_app_bar.dart';
import 'package:mini_accounting_system/core/styles/Colors.dart';
import 'package:mini_accounting_system/core/styles/text_style.dart';
import 'package:mini_accounting_system/features/edit_feature/edit_debt_screen.dart';
import 'package:mini_accounting_system/features/edit_feature/edit_expense_screen.dart';
import 'package:mini_accounting_system/sqldb.dart';

class CreditorDetailsScreen extends StatefulWidget {
  final int creditorId;
  final String creditorName;
  final String phone;

  const CreditorDetailsScreen({
    super.key,
    required this.creditorId,
    required this.creditorName,
    required this.phone,
  });

  @override
  State<CreditorDetailsScreen> createState() => _CreditorDetailsScreenState();
}

class _CreditorDetailsScreenState extends State<CreditorDetailsScreen> {
  final SqlDb db = SqlDb();
  List<Map> _debtOperations = [];
  List<Map> _paymentOperations = [];

  double totalDebt = 0;
  double totalPaid = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // جلب الديون
    final debts = await db.readData('''
  SELECT id, amount, date, note FROM Debts
  WHERE creditor_id = ${widget.creditorId}
  ORDER BY date DESC
''');

    // جلب المدفوعات
    final payments = await db.readData('''
      SELECT e.id, e.amount, e.date
      FROM DailyExpenses e
      JOIN ExpenseCategories c ON c.id = e.category_id
      WHERE c.name = 'ديون' AND e.note = "${widget.creditorName}"
      ORDER BY e.date DESC
    ''');

    double totalD = 0;
    double totalP = 0;
    for (var d in debts) totalD += d['amount'] ?? 0;
    for (var p in payments) totalP += p['amount'] ?? 0;

    setState(() {
      _debtOperations = debts;
      _paymentOperations = payments;
      totalDebt = totalD;
      totalPaid = totalP;
    });
  }

  Widget _buildOperationCard({
    required String type,
    required double amount,
    required String date,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text("$type: ${amount.toStringAsFixed(0)} ر.ي"),
        subtitle: Text("📅 $date"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(onPressed: onEdit, icon: const Icon(Icons.edit)),
            IconButton(onPressed: onDelete, icon: const Icon(Icons.delete)),
          ],
        ),
      ),
    );
  }

  Future<void> showEditDialog(Map<String, dynamic> expense) async {
    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditExpenseScreen(
              expense: {
                'id': expense['id'],
                'amount': expense['amount'],
                'date': expense['date'],
                'note': expense['note'] ?? '',
                'category': 'ديون', // ✅ إضافة نوع المصروف
                'creditorid': widget.creditorId, // ✅ تمرير رقم الدائن
              },
            ),
      ),
    );

    if (updated == true) {
      _loadData(); // إعادة تحميل البيانات بعد التعديل
    }
  }

  @override
  Widget build(BuildContext context) {
    final remaining = totalDebt - totalPaid;

    return SafeArea(
      child: Scaffold(
        body: Container(
          color: AppColors.transparent,
          child: Column(
            children: [
              CustomAppBar(tital: 'تفاصيل الدائن', isBack: true),
              SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView(
                    children: [
                      Text(
                        "اسم الدائن: ${widget.creditorName}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      Text(
                        "رقم الهاتف: ${widget.phone}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "💳 إجمالي الدين: ${totalDebt.toStringAsFixed(0)} ر.ي",
                      ),
                      Text("💵 المدفوع: ${totalPaid.toStringAsFixed(0)} ر.ي"),
                      Text("📉 المتبقي: ${remaining.toStringAsFixed(0)} ر.ي"),
                      const Divider(height: 32),
                      const Text(
                        "🧾 العمليات",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // ✅ التحقق من وجود عمليات
                      if (_debtOperations.isEmpty && _paymentOperations.isEmpty)
                        const Center(
                          child: Text(
                            "لا توجد عمليات لهذا الدائن حتى الآن.",
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ),

                      // ✅ عرض العمليات إن وُجدت
                      ..._debtOperations.map(
                        (e) => _buildOperationCard(
                          type: "أستلام دين",
                          amount: e['amount'],
                          date: e['date'],
                          onEdit: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => EditDebtScreen(
                                      debt: {
                                        'id': e['id'],
                                        'date': e['date'],
                                        'amount': e['amount'],
                                        'note': e['note'] ?? '',
                                        'creditor_id': widget.creditorId,
                                      },
                                    ),
                              ),
                            );
                            if (result == true) _loadData();
                          },
                          onDelete: () async {
                            final confirmed =
                                await showDeleteConfirmationDialog(
                                  context: context,
                                );
                            if (confirmed) {
                              await db.deleteData(
                                'DELETE FROM Debts WHERE id = ${e['id']}',
                              );
                              _loadData();
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),

                      ..._paymentOperations.map(
                        (e) => _buildOperationCard(
                          type: "دفع دين",
                          amount: e['amount'],
                          date: e['date'],
                          onEdit:
                              () =>
                                  showEditDialog(Map<String, dynamic>.from(e)),
                          onDelete: () async {
                            final confirmed =
                                await showDeleteConfirmationDialog(
                                  context: context,
                                );
                            if (confirmed) {
                              await db.deleteData(
                                'DELETE FROM DailyExpenses WHERE id = ${e['id']}',
                              );
                              _loadData();
                              Navigator.pop(context);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
