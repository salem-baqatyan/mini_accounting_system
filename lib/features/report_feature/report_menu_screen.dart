import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mini_accounting_system/core/shered_widget/custom_app_bar.dart';
import 'package:mini_accounting_system/core/styles/Colors.dart';
import 'package:mini_accounting_system/features/report_feature/reports/daily_report_screen.dart';
import 'package:mini_accounting_system/features/report_feature/reports/monthly_report_screen.dart';
import 'package:mini_accounting_system/features/report_feature/reports/yearly_report_screen.dart';

class ReportMenuScreen extends StatelessWidget {
  const ReportMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> options = [
      {
        "title": 'التقارير اليومية',
        "icon": Icons.today_rounded,
        "color": Colors.teal,
        "page": const DailyReportScreen(),
      },
      {
        "title": 'التقارير الشهرية',
        "icon": Icons.calendar_month_rounded,
        "color": Colors.indigo,
        "page": const MonthlyReportScreen(),
      },
      {
        "title": 'التقارير السنوية',
        "icon": Icons.date_range_rounded,
        "color": Colors.deepOrange,
        "page": const YearlyReportScreen(),
      },
    ];

    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            const CustomAppBar(tital: 'التقارير', isBack: true),
            SizedBox(height: 10.h),
            Expanded(
              child: Column(
                children: List.generate(options.length, (index) {
                  final option = options[index];
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 8.h,
                      ),
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => option['page']),
                          );
                        },
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16.r),
                          ),
                          color: option["color"].withOpacity(0.9),
                          elevation: 5,
                          child: Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircleAvatar(
                                  radius: 30.r,
                                  backgroundColor: Colors.white.withOpacity(
                                    0.15,
                                  ),
                                  child: Icon(
                                    option["icon"],
                                    size: 32.sp,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 10.h),
                                Text(
                                  option["title"],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
