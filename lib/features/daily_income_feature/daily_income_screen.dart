import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mini_accounting_system/core/shered_widget/action_button_widget.dart';
import 'package:mini_accounting_system/core/shered_widget/custom_app_bar.dart';
import 'package:mini_accounting_system/core/styles/Colors.dart';
import 'package:mini_accounting_system/core/styles/text_style.dart';
import 'package:mini_accounting_system/sqldb.dart';

class DailyIncomeScreen extends StatefulWidget {
  const DailyIncomeScreen({super.key});

  @override
  State<DailyIncomeScreen> createState() => _DailyIncomeScreenState();
}

class _DailyIncomeScreenState extends State<DailyIncomeScreen> {
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final SqlDb _sqlDb = SqlDb();

  @override
  void initState() {
    super.initState();
    _dateController.text = _formattedToday();
  }

  String _formattedToday() {
    final now = DateTime.now();
    return '${now.year}/${now.month}/${now.day}';
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickeddate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary, // Header background color
              onPrimary: AppColors.white, // Header text color
              onSurface: AppColors.blackDark, // Text color on the calendar
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: AppColors.blackLight, // Button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickeddate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy/MM/dd').format(pickeddate);
      });
    }
  }

  Future<void> _saveIncome() async {
    FocusScope.of(context).unfocus();
    final date = _dateController.text.trim();
    final amount = int.tryParse(_amountController.text.trim());

    if (date.isEmpty || amount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تعبئة الحقول بشكل صحيح')),
      );
      return;
    }

    // // تحقق إذا كان هناك دخل لنفس اليوم
    // final existing = await _sqlDb.readData(
    //   "SELECT * FROM DailyIncomes WHERE date = '$date'",
    // );

    // if (existing.isNotEmpty) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(content: Text('تم تسجيل دخل لهذا اليوم مسبقًا')),
    //   );
    //   return;
    // }

    await _sqlDb.insertData(
      "INSERT INTO DailyIncomes (date, amount) VALUES ('$date', $amount)",
    );
    print("INSERT INTO DailyIncomes (date, amount) VALUES ('$date', $amount)");
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم الحفظ بنجاح')));

    _dateController.text = _formattedToday();
    _amountController.clear();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: AppColors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomAppBar(tital: 'الايرادات اليومية', isBack: true),
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Column(
                  children: [
                    TextField(
                      controller: _dateController,
                      readOnly: true,
                      onTap: () => _selectDate(context),
                      decoration: InputDecoration(
                        label: Text(
                          'التاريخ',
                          style: KTextStyle.textStyle18.copyWith(
                            color: AppColors.greyLight,
                          ),
                        ),
                        suffixIcon: Icon(Icons.calendar_month),

                        fillColor: AppColors.white,
                        filled: true,
                        contentPadding: EdgeInsets.only(
                          right: 10.w,
                          bottom: 15.h,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.greyBorder,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        label: Text(
                          'المبلغ',
                          style: KTextStyle.textStyle18.copyWith(
                            color: AppColors.greyLight,
                          ),
                        ),
                        fillColor: AppColors.white,
                        filled: true,
                        contentPadding: EdgeInsets.only(
                          right: 10.w,
                          bottom: 15.h,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.greyBorder,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ActionButtonWidget(
                      iconPath: Icons.save,
                      title: 'حفظ',
                      onTap: _saveIncome,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
