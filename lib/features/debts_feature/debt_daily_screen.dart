import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:mini_accounting_system/core/shered_widget/action_button_widget.dart';
import 'package:mini_accounting_system/core/shered_widget/custom_app_bar.dart';
import 'package:mini_accounting_system/core/styles/Colors.dart';
import 'package:mini_accounting_system/core/styles/text_style.dart';
import 'package:mini_accounting_system/sqldb.dart';
import 'package:permission_handler/permission_handler.dart';

class DebtDailyScreen extends StatefulWidget {
  const DebtDailyScreen({super.key});

  @override
  State<DebtDailyScreen> createState() => _DebtDailyScreenState();
}

class _DebtDailyScreenState extends State<DebtDailyScreen> {
  final SqlDb _sqlDb = SqlDb();

  List<Map> _creditors = [];

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  int? _selectedCreditorId;

  @override
  void initState() {
    super.initState();
    _loadCreditors();
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

  Future<void> _loadCreditors() async {
    final List<Map> result = await _sqlDb.readData("SELECT * FROM Creditors");
    setState(() {
      _creditors = result;
    });
  }

  Future<void> _saveDebt() async {
    FocusScope.of(context).unfocus();
    if (_selectedCreditorId == null ||
        _amountController.text.isEmpty ||
        _dateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('الرجاء تعبئة الحقول بشكل صحيح')),
      );
      return;
    }

    final date = _dateController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final note = _noteController.text.trim();

    await _sqlDb.insertData('''
      INSERT INTO Debts (date, creditor_id, amount, note)
      VALUES ("$date", $_selectedCreditorId, $amount, "$note")
    ''');

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
              CustomAppBar(tital: 'الديون اليومية', isBack: true),
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
                    DropdownButtonFormField<int>(
                      items:
                          _creditors.map((creditor) {
                            return DropdownMenuItem<int>(
                              value: creditor['id'],
                              child: Text(creditor['name']),
                            );
                          }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedCreditorId = val;
                        });
                      },
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
                    ),
                    SizedBox(height: 5.h),
                    ActionButtonWidget(
                      width: 175.w,
                      iconPath: Icons.add,
                      title: 'إضافة حساب دائن جديد',
                      isSolid: false,
                      onTap: _showAddCreditorDialog,
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
                      onTap: _saveDebt,
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

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  Future<void> _pickFromContacts() async {
    final FlutterNativeContactPicker _contactPicker =
        FlutterNativeContactPicker();

    try {
      final Contact? contact = await _contactPicker.selectContact();
      if (contact != null) {
        String rawPhone = contact.phoneNumbers?.first ?? 'No phone';

        // تنظيف الرقم من الرموز غير الرقمية
        String cleanedPhone = rawPhone.replaceAll(RegExp(r'\D'), '');

        // إزالة بادئة الدولة إن وجدت
        if (cleanedPhone.startsWith('00967')) {
          cleanedPhone = cleanedPhone.substring(5);
        } else if (cleanedPhone.startsWith('967')) {
          cleanedPhone = cleanedPhone.substring(3);
        }

        setState(() {
          _nameController.text = contact.fullName ?? 'No name';
          _phoneController.text = cleanedPhone;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل في اختيار جهة الاتصال: $e')));
    }
  }

  Future<void> _showAddCreditorDialog() async {
    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('إضافة حساب دائن'),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      label: Text(
                        'اسم الدائن',
                        style: KTextStyle.textStyle14.copyWith(
                          color: AppColors.greyLight,
                        ),
                      ),
                      fillColor: AppColors.transparent,
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
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? 'أدخل اسم الدائن'
                                : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.name,
                    decoration: InputDecoration(
                      label: Text(
                        'رقم الجوال',
                        style: KTextStyle.textStyle14.copyWith(
                          color: AppColors.greyLight,
                        ),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.contacts),
                        onPressed: _pickFromContacts,
                      ),
                      fillColor: AppColors.transparent,
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
                ],
              ),
            ),
            actions: [
              ActionButtonWidget(
                width: 75.w,
                title: 'الغاء',
                onTap: () {
                  _nameController.clear();
                  _phoneController.clear();
                  Navigator.pop(context);
                },
                isSolid: false,
              ),
              ActionButtonWidget(
                width: 75.w,
                title: 'موافق',
                onTap: () async {
                  if (_formKey.currentState!.validate()) {
                    final name = _nameController.text.trim();
                    final phone = _phoneController.text.trim();

                    final id = await _sqlDb.insertData('''
                    INSERT INTO Creditors (name, phone)
                    VALUES ("$name", "$phone")
                  ''');
                    _loadCreditors();
                    setState(() {
                      _selectedCreditorId = id; // تحديد المضاف تلقائيًا
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('✅ تم إضافة الدائن بنجاح')),
                    );
                    _nameController.clear();
                    _phoneController.clear();
                    Navigator.pop(context);
                  }
                },
              ),
            ],
          ),
    );
  }
}
