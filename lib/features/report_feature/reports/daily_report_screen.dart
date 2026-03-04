import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mini_accounting_system/core/shered_widget/custom_app_bar.dart';
import 'package:mini_accounting_system/core/styles/Colors.dart';
import 'package:mini_accounting_system/features/report_feature/details/expense_details_screen.dart';
import 'package:mini_accounting_system/features/report_feature/details/income_details_screen.dart';
import 'package:mini_accounting_system/sqldb.dart';
import 'package:provider/provider.dart';

class DailyReportScreen extends StatefulWidget {
  const DailyReportScreen({super.key});

  @override
  State<DailyReportScreen> createState() => _DailyReportScreenState();
}

class _DailyReportScreenState extends State<DailyReportScreen> {
  DateTime selectedDate = DateTime.now();
  double totalIncome = 0.0;
  double totalExpenses = 0.0;
  List<Map> expenseDetails = [];

  String getFormattedDbDate(DateTime date) {
    // ✅ تنسيق التاريخ ليتطابق مع قاعدة البيانات: yyyy/M/d (بدون أصفار بادئة)
    return '${date.year}/${date.month}/${date.day}';
  }

  String getFormattedDisplayDate(DateTime date) {
    // ✅ تنسيق للعرض: yyyy/MM/dd
    return DateFormat('yyyy/MM/dd').format(date);
  }

  Map<String, List<Map<String, dynamic>>> groupedExpenses = {};
  Map<String, double> groupedSums = {};
  Future<void> fetchReport() async {
    final db = Provider.of<SqlDb>(context, listen: false);
    String dateString = getFormattedDbDate(selectedDate);

    // 🔹 إجمالي الدخل
    var incomeResult = await db.readData('''
      SELECT SUM(amount) as total FROM DailyIncomes WHERE date = "$dateString"
    ''');

    // 🔹 إجمالي المصروفات
    var expenseResult = await db.readData('''
      SELECT SUM(amount) as total FROM DailyExpenses WHERE date = "$dateString"
    ''');

    // 🔹 تفاصيل المصروفات
    var groupedExpensesResult = await db.readData('''
  SELECT EC.name as category, E.amount, E.note, E.date
  FROM DailyExpenses E
  JOIN ExpenseCategories EC ON E.category_id = EC.id
  WHERE E.date = "$dateString"
  ORDER BY E.id ASC
''');
    Map<String, List<Map<String, dynamic>>> tempGrouped = {};
    Map<String, double> tempSums = {};

    for (var row in groupedExpensesResult) {
      String category = row['category'];
      tempGrouped.putIfAbsent(category, () => []).add(row);

      double amount = row['amount'] ?? 0.0;
      tempSums[category] = (tempSums[category] ?? 0.0) + amount;
    }
    setState(() {
      totalIncome =
          incomeResult[0]['total'] != null ? incomeResult[0]['total'] : 0.0;
      totalExpenses =
          expenseResult[0]['total'] != null ? expenseResult[0]['total'] : 0.0;
      groupedExpenses = tempGrouped;
      groupedSums = tempSums;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchReport();
  }

  @override
  Widget build(BuildContext context) {
    double netProfit = totalIncome - totalExpenses;

    return SafeArea(
      child: Scaffold(
        body: Container(
          color: AppColors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomAppBar(tital: 'التقرير اليومي', isBack: true),
              SizedBox(height: 20.h),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        width: 175.w,
                        child: ListTile(
                          title: Text(
                            getFormattedDisplayDate(selectedDate),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          trailing: Icon(Icons.calendar_today),
                          onTap: () async {
                            DateTime? picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                              locale: const Locale('ar'),
                            );
                            if (picked != null) {
                              setState(() {
                                selectedDate = picked;
                              });
                              fetchReport();
                            }
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 🔹 إجمالي الدخل
                      Card(
                        child: ListTile(
                          title: const Text('إجمالي الدخل'),
                          trailing: Text(
                            '${totalIncome.toStringAsFixed(0)}+ ر.ي',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => IncomeDetailsScreen(
                                      reportType: 'daily',
                                      selectedDate: selectedDate,
                                    ),
                              ),
                            ).then((_) => fetchReport);
                          },
                        ),
                      ),

                      // 🔹 إجمالي المصروفات
                      Card(
                        child: ListTile(
                          title: const Text('إجمالي المصروفات'),
                          trailing: Text(
                            '${totalExpenses.toStringAsFixed(0)}- ر.ي',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => ExpenseDetailsScreen(
                                      reportType: 'daily',
                                      selectedDate: selectedDate,
                                    ),
                              ),
                            ).then((_) => fetchReport);
                          },
                        ),
                      ),

                      const SizedBox(height: 16),

                      // 🔹 تفاصيل المصروفات
                      const Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'تفاصيل المصروفات:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),

                      // 🔹 تفاصيل المصروفات حسب التصنيفات
                      Expanded(
                        child:
                            groupedExpenses.isEmpty
                                ? const Center(
                                  child: Text('لا توجد مصروفات في هذا اليوم.'),
                                )
                                : ListView(
                                  children:
                                      groupedExpenses.entries.map((entry) {
                                        String category = entry.key;
                                        List<Map<String, dynamic>> expenses =
                                            entry.value;
                                        double categoryTotal =
                                            groupedSums[category] ?? 0.0;

                                        return ExpansionTile(
                                          title: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                category,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              Text(
                                                '${categoryTotal.toStringAsFixed(0)} ر.ي',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          children:
                                              expenses.map((item) {
                                                return ListTile(
                                                  title: Text(
                                                    '${item['note'] ?? 'بدون ملاحظة'}',
                                                  ),
                                                  // subtitle: Text(
                                                  //   'التاريخ: ${item['date']}',
                                                  // ),
                                                  trailing: Text(
                                                    '${item['amount'].toStringAsFixed(0)} ر.ي',
                                                  ),
                                                );
                                              }).toList(),
                                        );
                                      }).toList(),
                                ),
                      ),
                      const SizedBox(height: 16),
                      // 🔹 صافي الربح
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${netProfit.toStringAsFixed(0)} ر.ي',

                            style: TextStyle(
                              fontSize: 20,
                              color: netProfit >= 0 ? Colors.green : Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Text(
                            'صافي الربح اليومي',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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
