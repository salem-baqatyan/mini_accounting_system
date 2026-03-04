import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mini_accounting_system/core/shered_widget/custom_app_bar.dart';
import 'package:mini_accounting_system/core/styles/Colors.dart';
import 'package:mini_accounting_system/features/report_feature/details/expense_details_screen.dart';
import 'package:mini_accounting_system/features/report_feature/details/income_details_screen.dart';
import 'package:mini_accounting_system/sqldb.dart';
import 'package:provider/provider.dart';

class MonthlyReportScreen extends StatefulWidget {
  const MonthlyReportScreen({super.key});

  @override
  State<MonthlyReportScreen> createState() => _MonthlyReportScreenState();
}

class _MonthlyReportScreenState extends State<MonthlyReportScreen> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  double totalIncome = 0.0;
  double totalExpenses = 0.0;
  Map<String, List<Map<String, dynamic>>> categorizedExpenses = {};

  final List<String> monthsArabic = [
    'يناير',
    'فبراير',
    'مارس',
    'أبريل',
    'مايو',
    'يونيو',
    'يوليو',
    'أغسطس',
    'سبتمبر',
    'أكتوبر',
    'نوفمبر',
    'ديسمبر',
  ];

  Future<void> fetchReport() async {
    final db = Provider.of<SqlDb>(context, listen: false);

    // 🔍 تجهيز استعلام التاريخ (مثلاً: 2025/5/)
    String prefix = '$selectedYear/$selectedMonth/';

    // 🔹 إجمالي الدخل
    var incomeResult = await db.readData('''
      SELECT SUM(amount) as total FROM DailyIncomes
      WHERE date LIKE "$prefix%"
    ''');

    // 🔹 إجمالي المصروفات
    var expenseResult = await db.readData('''
      SELECT SUM(amount) as total FROM DailyExpenses
      WHERE date LIKE "$prefix%"
    ''');

    // 🔹 تفاصيل المصروفات حسب التصنيفات
    var details = await db.readData('''
      SELECT EC.name as category, E.amount, E.note, E.date
      FROM DailyExpenses E
      JOIN ExpenseCategories EC ON E.category_id = EC.id
      WHERE E.date LIKE "$prefix%"
      ORDER BY E.date ASC
    ''');

    // 🔹 تصنيف المصروفات
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var item in details) {
      final category = item['category'] ?? 'أخرى';
      grouped.putIfAbsent(category, () => []).add(item);
    }

    setState(() {
      totalIncome = incomeResult[0]['total'] ?? 0.0;
      totalExpenses = expenseResult[0]['total'] ?? 0.0;
      categorizedExpenses = grouped;
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
              CustomAppBar(tital: 'التقرير الشهري', isBack: true),
              SizedBox(height: 20.h),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 10.h,
                  ),
                  child: Column(
                    children: [
                      // 🔸 اختيار الشهر والسنة
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          DropdownButton<int>(
                            value: selectedMonth,
                            items: List.generate(
                              12,
                              (index) => DropdownMenuItem(
                                value: index + 1,
                                child: Text(monthsArabic[index]),
                              ),
                            ),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() => selectedMonth = value);
                                fetchReport();
                              }
                            },
                          ),
                          const SizedBox(width: 16),

                          IconButton(
                            icon: const Icon(Icons.arrow_left, size: 30),
                            onPressed: () {
                              setState(() => selectedYear--);
                              fetchReport();
                            },
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
                            icon: const Icon(Icons.arrow_right, size: 30),
                            onPressed: () {
                              setState(() => selectedYear++);
                              fetchReport();
                            },
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
                                      reportType: 'monthly',
                                      selectedDate: DateTime(
                                        selectedYear,
                                        selectedMonth,
                                      ),
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
                                      reportType: 'monthly',
                                      selectedDate: DateTime(
                                        selectedYear,
                                        selectedMonth,
                                      ),
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

                      // 🔹 تفاصيل المصروفات مجمعة حسب التصنيفات
                      Expanded(
                        child:
                            categorizedExpenses.isEmpty
                                ? const Center(
                                  child: Text('لا توجد مصروفات لهذا الشهر.'),
                                )
                                : ListView(
                                  children:
                                      categorizedExpenses.entries.map((entry) {
                                        final category = entry.key;
                                        final expenses = entry.value;
                                        final total = expenses.fold<double>(
                                          0.0,
                                          (sum, e) =>
                                              sum + (e['amount'] ?? 0.0),
                                        );
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
                                              expenses.map((e) {
                                                return ListTile(
                                                  title: Text(
                                                    '${e['note'] ?? ''}',
                                                  ),
                                                  subtitle: Text(
                                                    '${e['date']}',
                                                  ),
                                                  trailing: Text(
                                                    '${e['amount'].toStringAsFixed(0)} ر.ي',
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
                            'صافي الربح الشهري',
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
