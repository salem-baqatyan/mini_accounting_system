import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mini_accounting_system/core/function/delete_confirmation.dart';
import 'package:mini_accounting_system/core/shered_widget/action_button_widget.dart';
import 'package:mini_accounting_system/core/shered_widget/custom_app_bar.dart';
import 'package:mini_accounting_system/core/styles/Colors.dart';
import 'package:mini_accounting_system/core/styles/text_style.dart';
import 'package:mini_accounting_system/sqldb.dart';
import 'package:intl/intl.dart';

class IncomeDetailsScreen extends StatefulWidget {
  final String reportType; // 'daily' or 'monthly' or 'yearly'
  final DateTime selectedDate;

  const IncomeDetailsScreen({
    super.key,
    required this.reportType,
    required this.selectedDate,
  });

  @override
  State<IncomeDetailsScreen> createState() => _IncomeDetailsScreenState();
}

class _IncomeDetailsScreenState extends State<IncomeDetailsScreen> {
  final SqlDb db = SqlDb();
  List<Map> incomes = [];
  String titleIncomes = "";

  Future<void> fetchData() async {
    String condition = '';
    final d = widget.selectedDate;

    if (widget.reportType == 'daily') {
      condition = 'date = "${d.year}/${d.month}/${d.day}"';
      titleIncomes = 'اليومية';
    } else if (widget.reportType == 'monthly') {
      condition = 'date LIKE "${d.year}/${d.month}/%"';
      titleIncomes = 'الشهرية';
    } else if (widget.reportType == 'yearly') {
      condition = 'date LIKE "${d.year}/%"';
      titleIncomes = 'السنوية';
    }

    final result = await db.readData(
      'SELECT * FROM DailyIncomes WHERE $condition ORDER BY id ASC',
    );
    setState(() {
      incomes = result;
    });
  }

  Future<void> deleteIncome(int id) async {
    final confirmed = await showDeleteConfirmationDialog(context: context);

    if (confirmed) {
      await db.deleteData('DELETE FROM DailyIncomes WHERE id = $id');
      fetchData(); // refresh list
      Navigator.pop(context); // للعودة للخلف بعد الحذف
    }
  }

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> showEditIncomeDialog(Map income) async {
    final TextEditingController amountController = TextEditingController(
      text: income['amount'].toStringAsFixed(0),
    );
    final TextEditingController dateController = TextEditingController(
      text: income['date'],
    );
    final _formKey = GlobalKey<FormState>();
    DateTime? pickedDate = null;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("تعديل الإيراد"),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: amountController,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    label: Text(
                      'المبلغ',
                      style: KTextStyle.textStyle14.copyWith(
                        color: AppColors.greyLight,
                      ),
                    ),
                    fillColor: AppColors.transparent,
                    filled: true,
                    contentPadding: EdgeInsets.only(right: 10.w, bottom: 15.h),
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
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'أدخل اسم الدائن'
                              : null,
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: dateController,
                  readOnly: true,
                  keyboardType: TextInputType.name,
                  decoration: InputDecoration(
                    label: Text(
                      'التاريخ',
                      style: KTextStyle.textStyle14.copyWith(
                        color: AppColors.greyLight,
                      ),
                    ),
                    suffixIcon: Icon(Icons.calendar_today),

                    fillColor: AppColors.transparent,
                    filled: true,
                    contentPadding: EdgeInsets.only(right: 10.w, bottom: 15.h),
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
                  validator:
                      (value) =>
                          value == null || value.isEmpty
                              ? 'أدخل اسم الدائن'
                              : null,
                  onTap: () async {
                    pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                      locale: const Locale('ar'),
                    );
                    if (pickedDate != null) {
                      dateController.text =
                          "${pickedDate!.year}/${pickedDate!.month}/${pickedDate!.day}";
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            ActionButtonWidget(
              width: 75.w,
              title: 'الغاء',
              onTap: () {
                amountController.clear();
                dateController.clear();
                Navigator.pop(context);
              },
              isSolid: false,
            ),
            ActionButtonWidget(
              width: 75.w,
              title: 'موافق',
              onTap: () async {
                if (_formKey.currentState!.validate()) {
                  final newAmount = double.tryParse(amountController.text) ?? 0;
                  final newDate = dateController.text.trim();

                  await db.updateData('''
      UPDATE DailyIncomes
      SET amount = $newAmount, date = "$newDate"
      WHERE id = ${income['id']}
    ''');

                  Navigator.pop(context);
                  fetchData(); // يعاد تحميل البيانات بعد التعديل
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: Colors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomAppBar(tital: 'تعديل الايرادات', isBack: true),
              SizedBox(height: 20),

              incomes.isEmpty
                  ? const Center(
                    child: Text('لا توجد إيرادات لهذا النطاق الزمني'),
                  )
                  : Align(
                    alignment: Alignment.center,
                    child: Text(
                      'الايرادات $titleIncomes',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: ListView.builder(
                    itemCount: incomes.length,
                    itemBuilder: (context, index) {
                      final item = incomes[index];
                      return Card(
                        child: ListTile(
                          title: Text(
                            '${item['amount'].toStringAsFixed(0)} ر.ي',
                          ),
                          subtitle: Text('📅 ${item['date']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () => showEditIncomeDialog(item),
                              ),

                              IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => deleteIncome(item['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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
