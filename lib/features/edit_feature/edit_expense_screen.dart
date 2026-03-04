import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mini_accounting_system/core/shered_widget/action_button_widget.dart';
import 'package:mini_accounting_system/core/shered_widget/custom_app_bar.dart';
import 'package:mini_accounting_system/core/styles/Colors.dart';
import 'package:mini_accounting_system/core/styles/text_style.dart';
import 'package:mini_accounting_system/sqldb.dart';

class EditExpenseScreen extends StatefulWidget {
  final Map<String, dynamic> expense;

  const EditExpenseScreen({super.key, required this.expense});

  @override
  State<EditExpenseScreen> createState() => _EditExpenseScreenState();
}

class _EditExpenseScreenState extends State<EditExpenseScreen> {
  final SqlDb db = SqlDb();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  List<Map> _categories = [];
  List<Map> _creditors = [];

  String? _selectedCategoryName;
  int? _selectedCreditorId;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadCreditors();

    _dateController.text = widget.expense['date'] ?? '';
    _amountController.text = widget.expense['amount'].toStringAsFixed(0);
    _noteController.text = widget.expense['note']?.toString() ?? '';
    _selectedCategoryName = widget.expense['category'];
    _selectedCreditorId =
        widget.expense['creditorid']; // هذا يجب أن يكون موجود في البيانات
  }

  Future<void> _loadCategories() async {
    final result = await db.readData('SELECT * FROM ExpenseCategories');
    setState(() => _categories = result);
  }

  Future<void> _loadCreditors() async {
    final result = await db.readData('SELECT * FROM Creditors');
    setState(() {
      _creditors = result;

      // ✅ بعد تحميل الدائنين، اضبط note تلقائيًا إن وُجد دائن محدد مسبقًا
      if (_selectedCategoryName == 'ديون' && _selectedCreditorId != null) {
        final selectedCreditor = _creditors.firstWhere(
          (c) => c['id'] == _selectedCreditorId,
          orElse: () => <String, dynamic>{}, // ✅ هذا يُعيد Map<String, dynamic>
        );

        if (selectedCreditor.isNotEmpty) {
          _noteController.text = selectedCreditor['name'];
        }
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final initial = DateFormat('yyyy/MM/dd').parse(widget.expense['date']);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder:
          (context, child) => Theme(
            data: ThemeData.light().copyWith(
              colorScheme: ColorScheme.light(
                primary: AppColors.primary,
                onPrimary: AppColors.white,
                onSurface: AppColors.blackDark,
              ),
            ),
            child: child!,
          ),
    );
    if (picked != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy/MM/dd').format(picked);
      });
    }
  }

  Future<void> _updateExpense() async {
    final date = _dateController.text.trim();
    final note = _noteController.text.trim();
    final amount = int.tryParse(_amountController.text.trim()) ?? 0;

    if (date.isEmpty || _selectedCategoryName == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تعبئة الحقول بشكل صحيح')),
      );
      return;
    }

    if (_selectedCategoryName == 'ديون' && _selectedCreditorId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('يرجى اختيار حساب الدائن')));
      return;
    }

    final expenseId = widget.expense['id'];
    final categoryIdSql =
        '(SELECT id FROM ExpenseCategories WHERE name = "$_selectedCategoryName" LIMIT 1)';
    final creditorIdValue =
        (_selectedCategoryName == 'ديون')
            ? _selectedCreditorId.toString()
            : 'NULL';

    final sql = '''
      UPDATE DailyExpenses SET
        date = "$date",
        amount = $amount,
        note = "$note",
        category_id = $categoryIdSql,
        creditorid = $creditorIdValue
      WHERE id = $expenseId
    ''';

    await db.updateData(sql);

    Navigator.pop(context, true); // رجوع مع إشارة نجاح
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
              const CustomAppBar(tital: 'تعديل المصروف', isBack: true),
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
                          _categories
                              .map<DropdownMenuItem<String>>(
                                (c) => DropdownMenuItem(
                                  value: c['name'],
                                  child: Text(c['name']),
                                ),
                              )
                              .toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCategoryName = val;
                          if (val != 'ديون') {
                            _selectedCreditorId = null;
                          }
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
                      title: 'تحديث',
                      onTap: _updateExpense,
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
