import 'package:flutter/material.dart';
import 'package:mini_accounting_system/core/shered_widget/custom_app_bar.dart';
import 'package:mini_accounting_system/core/styles/Colors.dart';
import 'package:mini_accounting_system/features/daily_expenses_feature/daily_expenses_screen.dart';
import 'package:mini_accounting_system/features/daily_income_feature/daily_income_screen.dart';
import 'package:mini_accounting_system/features/debts_feature/creditors_Screen.dart';
import 'package:mini_accounting_system/features/debts_feature/debt_daily_screen.dart';
import 'package:mini_accounting_system/features/report_feature/report_menu_screen.dart';
import 'package:mini_accounting_system/settings_screen.dart';
import 'package:mini_accounting_system/sqldb.dart';
import 'package:provider/provider.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> actions = [
      //TODO: هنا يتم اضافة مبلغ الدخل اليومي
      {
        "title": 'الايرادات اليومية',
        "icon": "assets/image/income.png",
        "page": DailyIncomeScreen(),
      },
      //TODO: هنا يتم اضافة مبالغ المصروفات اليومية
      {
        "title": 'المصروفات اليومية',
        "icon": "assets/image/expenses.png",
        "page": DailyExpensesScreen(),
      },
      //TODO: هنا يتم ادخال الديون اليومية
      {
        "title": 'الديون اليومية',
        "icon": "assets/image/debts.png",
        "page": DebtDailyScreen(),
      },
      //TODO: هنا يتم عرض قائمة الدائنون مع تفاصيل تددينهم لك
      {
        "title": 'عرض قائمة الدائنين',
        "icon": "assets/image/creditors.png",
        "page": CreditorsScreen(),
      },
      //TODO: هنا يتم عرض التقارير اليومية والشهرية والسنوية مع اظهار صافي الربح
      {
        "title": 'التقارير',
        "icon": "assets/image/reports.png",
        "page": ReportMenuScreen(),
      },
      //TODO: هنا يتم تعيين قوائم انواع المصروفات وادارة قائمة الدائنين
      {
        "title": 'الاعدادت',
        "icon": "assets/image/setting.png",
        "page": SettingsScreen(),
      },
    ];

    return SafeArea(
      child: Scaffold(
        body: Container(
          color: AppColors.transparent,
          child: Column(
            children: [
              CustomAppBar(tital: 'القائمة الرئيسية', isBack: false),
              SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1,
                    children:
                        actions.map((action) {
                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) => action['page'] as Widget,
                                ),
                              );
                            },

                            borderRadius: BorderRadius.circular(12),
                            child: Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              color: Colors.blueGrey.shade50,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Image.asset(
                                        action['icon'] as String,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Expanded(
                                    flex: 1,
                                    child: Text(
                                      action['title'] as String,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
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
