import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mini_accounting_system/core/shered_widget/action_button_widget.dart';
import 'package:mini_accounting_system/core/shered_widget/custom_app_bar.dart';
import 'package:mini_accounting_system/core/styles/Colors.dart';
import 'package:mini_accounting_system/core/styles/text_style.dart';
import 'package:mini_accounting_system/sqldb.dart';

class DailyExpensesScreen extends StatefulWidget {
  final Map<String, dynamic>? prefill;

  const DailyExpensesScreen({super.key, this.prefill});

  @override
  State<DailyExpensesScreen> createState() => _DailyExpensesScreenState();
}

class _DailyExpensesScreenState extends State<DailyExpensesScreen> {
  TextEditingController _dateController = TextEditingController();
  TextEditingController _amountController = TextEditingController();
  TextEditingController _noteController = TextEditingController();

  List<Map> _categories = [];
  String? _selectedCategoryName;

  List<Map> _creditors = [];
  int? _selectedCreditorId;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadCreditors();
    _dateController.text = _formattedToday();
    if (widget.prefill != null) {
      _dateController.text = widget.prefill!['date'] ?? '';
      _noteController.text = widget.prefill!['note'] ?? '';
      _selectedCategoryName = widget.prefill!['category'];
      _selectedCreditorId = widget.prefill!['creditorid'];

      if (_selectedCategoryName == 'ديون' && widget.prefill!['note'] != null) {
        _loadCreditors();
        var found = _creditors.firstWhere(
          (c) => c['id'] == widget.prefill!['id'],
          orElse: () => {},
        );
        if (found.isNotEmpty) {
          setState(() {
            _selectedCreditorId = found['id'];
          });
        }
      }
    }
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

  Future<void> _loadCategories() async {
    final result = await SqlDb().readData('SELECT * FROM ExpenseCategories');
    setState(() {
      _categories = result;
    });
  }

  Future<void> _loadCreditors() async {
    final result = await SqlDb().readData('SELECT * FROM Creditors');
    setState(() {
      _creditors = result;
    });
  }

  void _saveExpense() async {
    FocusScope.of(context).unfocus();
    final date = _dateController.text.trim();
    final amount = int.tryParse(_amountController.text.trim()) ?? 0;
    final note = _noteController.text.trim();

    if (date.isEmpty || amount <= 0 || _selectedCategoryName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تعبئة الحقول بشكل صحيح')),
      );
      return;
    }

    if (_selectedCategoryName == 'ديون' && _selectedCreditorId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى اختيار حساب الدائن')));
      return;
    }

    // حفظ المصروف
    final insertSql = '''
      INSERT INTO DailyExpenses (date, category_id, amount, note)
      VALUES (
        "$date",
        (SELECT id FROM ExpenseCategories WHERE name = "$_selectedCategoryName" LIMIT 1),
        $amount,
        "$note"
      )
    ''';
    print(insertSql);
    await SqlDb().insertData(insertSql);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('تم الحفظ بنجاح')));

    _dateController.text = _formattedToday();
    _amountController.clear();
    _noteController.clear();
  }

  @override
  void dispose() {
    _dateController.dispose();
    _amountController.dispose();
    _noteController.dispose();
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
              CustomAppBar(tital: 'المصروفات اليومية', isBack: true),
              SizedBox(height: 20.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
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
                    DropdownButtonFormField<String>(
                      value: _selectedCategoryName,
                      items:
                          _categories.map<DropdownMenuItem<String>>((category) {
                            return DropdownMenuItem(
                              value: category['name'],
                              child: Text(category['name']),
                            );
                          }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCategoryName = val;
                          ;
                          if (val != 'ديون') _selectedCreditorId = null;
                        });
                      },
                      decoration: InputDecoration(
                        label: Text(
                          "نوع المصروف",
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
                    SizedBox(height: 5.h),
                    ActionButtonWidget(
                      width: 175.w,
                      iconPath: Icons.add,
                      title: 'أضافة نوع جديد',
                      isSolid: false,
                      onTap: _showAddCategoryDialog,
                    ),
                    if (_selectedCategoryName == 'ديون') ...[
                      const SizedBox(height: 12),
                      DropdownButtonFormField<int>(
                        value: _selectedCreditorId,
                        decoration: InputDecoration(
                          label: Text(
                            "حساب الدائن",
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

                        items:
                            _creditors.map<DropdownMenuItem<int>>((c) {
                              return DropdownMenuItem(
                                value: c['id'],
                                child: Text(c['name']),
                              );
                            }).toList(),
                        onChanged: (val) {
                          setState(() {
                            _selectedCreditorId = val;
                            final selectedCreditor = _creditors.firstWhere(
                              (c) => c['id'] == val,
                            );
                            _noteController.text = selectedCreditor['name'];
                          });
                        },
                      ),
                    ],
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
                    const SizedBox(height: 12),
                    TextField(
                      controller: _noteController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        label: Text(
                          'الملاحظة',
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
                      onTap: _saveExpense,
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

  Future<void> _showAddCategoryDialog() async {
    final TextEditingController _newCategoryController =
        TextEditingController();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('إضافة نوع مصروف جديد'),
            content: TextField(
              controller: _newCategoryController,
              keyboardType: TextInputType.name,
              decoration: InputDecoration(
                label: Text(
                  'نوع مصروف',
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
                  borderSide: BorderSide(color: AppColors.primary, width: 1.0),
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
            actions: [
              ActionButtonWidget(
                width: 75.w,
                title: 'الغاء',
                onTap: () {
                  _newCategoryController.clear();
                  Navigator.pop(context);
                },
                isSolid: false,
              ),
              ActionButtonWidget(
                width: 75.w,
                title: 'موافق',
                onTap: () async {
                  final name = _newCategoryController.text.trim();
                  if (name.isNotEmpty) {
                    // اضافة نوع المصروف
                    final insertSql = '''
                    INSERT INTO ExpenseCategories (name) VALUES ("$name")
                        ''';
                    await SqlDb().insertData(insertSql);
                    Navigator.pop(context);
                    await _loadCategories(); // تحديث القائمة
                    setState(() {
                      _selectedCategoryName = name; // تحديد المضاف تلقائيًا
                    });
                  }
                },
              ),
            ],
          ),
    );
  }
}
