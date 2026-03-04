import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mini_accounting_system/core/shered_widget/custom_app_bar.dart';
import 'package:mini_accounting_system/core/styles/Colors.dart';
import 'package:mini_accounting_system/features/report_feature/details/expense_details_screen.dart';
import 'package:mini_accounting_system/features/report_feature/details/income_details_screen.dart';
import 'package:mini_accounting_system/sqldb.dart';
import 'package:provider/provider.dart';

class YearlyReportScreen extends StatefulWidget {
  const YearlyReportScreen({super.key});

  @override
  State<YearlyReportScreen> createState() => _YearlyReportScreenState();
}

class _YearlyReportScreenState extends State<YearlyReportScreen> {
  int selectedYear = DateTime.now().year;
  double totalIncome = 0.0;
  double totalExpenses = 0.0;
  Map<String, List<Map<String, dynamic>>> categorizedExpenses = {};
  Map<String, double> categoryTotals = {};

  Future<void> fetchReport() async {
    final db = Provider.of<SqlDb>(context, listen: false);
    String yearString = selectedYear.toString();

    // 🔹 إجمالي الدخل السنوي
    var incomeResult = await db.readData('''
      SELECT SUM(amount) as total FROM DailyIncomes 
      WHERE date LIKE "$yearString/%"
    ''');

    // 🔹 إجمالي المصروفات السنوية
    var expenseResult = await db.readData('''
      SELECT SUM(amount) as total FROM DailyExpenses 
      WHERE date LIKE "$yearString/%"
    ''');

    // 🔹 تفاصيل المصروفات مصنفة
    var expenseDetailsResult = await db.readData('''
      SELECT EC.name as category, E.amount, E.note, E.date
      FROM DailyExpenses E
      JOIN ExpenseCategories EC ON E.category_id = EC.id
      WHERE E.date LIKE "$yearString/%"
      ORDER BY E.date ASC
    ''');

    Map<String, List<Map<String, dynamic>>> tempCategorized = {};
    Map<String, double> tempTotals = {};

    for (var item in expenseDetailsResult) {
      String category = item['category'];
      double amount = item['amount'];

      tempCategorized.putIfAbsent(category, () => []).add(item);
      tempTotals[category] = (tempTotals[category] ?? 0) + amount;
    }

    setState(() {
      totalIncome = incomeResult[0]['total'] ?? 0.0;
      totalExpenses = expenseResult[0]['total'] ?? 0.0;
      categorizedExpenses = tempCategorized;
      categoryTotals = tempTotals;
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
              CustomAppBar(tital: 'التقرير السنوي', isBack: true),
              SizedBox(height: 20.h),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  child: Column(
                    children: [
                      // 🔹 اختيار السنة فقط
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                selectedYear--;
                              });
                              fetchReport();
                            },
                            icon: const Icon(Icons.arrow_left, size: 30),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              selectedYear.toString(),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                selectedYear++;
                              });
                              fetchReport();
                            },
                            icon: const Icon(Icons.arrow_right, size: 30),
                          ),
                        ],
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
                                      reportType: 'yearly',
                                      selectedDate: DateTime(selectedYear),
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
                                      reportType: 'yearly',
                                      selectedDate: DateTime(selectedYear),
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

                      // 🔹 تفاصيل المصروفات حسب التصنيف
                      Expanded(
                        child:
                            categorizedExpenses.isEmpty
                                ? const Center(
                                  child: Text(
                                    'لا توجد مصروفات خلال هذه السنة.',
                                  ),
                                )
                                : ListView(
                                  children:
                                      categorizedExpenses.entries.map((entry) {
                                        String category = entry.key;
                                        List<Map<String, dynamic>> expenses =
                                            entry.value;
                                        double total =
                                            categoryTotals[category] ?? 0.0;

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
                                                '${total.toStringAsFixed(0)} ر.ي',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                          initiallyExpanded: false,
                                          children:
                                              expenses.map((item) {
                                                return ListTile(
                                                  title: Text(
                                                    '${item['note'] ?? ''}',
                                                  ),
                                                  subtitle: Text(item['date']),
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

                      // 🔹 صافي الربح السنوي
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
                            'صافي الربح السنوي',
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
