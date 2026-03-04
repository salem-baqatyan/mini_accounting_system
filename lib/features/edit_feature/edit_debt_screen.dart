import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mini_accounting_system/core/shered_widget/action_button_widget.dart';
import 'package:mini_accounting_system/core/shered_widget/custom_app_bar.dart';
import 'package:mini_accounting_system/core/styles/Colors.dart';
import 'package:mini_accounting_system/core/styles/text_style.dart';
import 'package:mini_accounting_system/sqldb.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EditDebtScreen extends StatefulWidget {
  final Map<String, dynamic> debt;

  const EditDebtScreen({super.key, required this.debt});

  @override
  State<EditDebtScreen> createState() => _EditDebtScreenState();
}

class _EditDebtScreenState extends State<EditDebtScreen> {
  final SqlDb db = SqlDb();

  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  List<Map> _creditors = [];
  int? _selectedCreditorId;

  @override
  void initState() {
    super.initState();
    _loadCreditors();

    _dateController.text = widget.debt['date'] ?? '';
    _amountController.text = widget.debt['amount'].toStringAsFixed(0);
    _noteController.text = widget.debt['note']?.toString() ?? ''; // ✅ إصلاح هنا
    _selectedCreditorId = widget.debt['creditor_id'];
  }

  Future<void> _loadCreditors() async {
    final result = await db.readData("SELECT * FROM Creditors");
    setState(() {
      _creditors = result;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final initialDate = DateFormat('yyyy/MM/dd').parse(widget.debt['date']);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.blackDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('yyyy/MM/dd').format(pickedDate);
      });
    }
  }

  Future<void> _updateDebt() async {
    final date = _dateController.text.trim();
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    final note = _noteController.text.trim();
    final id = widget.debt['id'];

    if (_selectedCreditorId == null || amount <= 0 || date.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى تعبئة البيانات بشكل صحيح')),
      );
      return;
    }

    await db.updateData('''
      UPDATE Debts SET
        date = "$date",
        amount = $amount,
        note = "$note",
        creditor_id = $_selectedCreditorId
      WHERE id = $id
    ''');

    Navigator.pop(context, true); // رجوع مع نجاح
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const CustomAppBar(tital: 'تعديل الدين', isBack: true),
            const SizedBox(height: 20),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                children: [
                  TextField(
                    controller: _dateController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: _inputDecoration(
                      'التاريخ',
                      Icons.calendar_today,
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    value: _selectedCreditorId,
                    decoration: _inputDecoration("حساب الدائن", Icons.person),
                    items:
                        _creditors
                            .map<DropdownMenuItem<int>>(
                              (c) => DropdownMenuItem<int>(
                                value: c['id'] as int,
                                child: Text(c['name']),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (val) => setState(() => _selectedCreditorId = val),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: _inputDecoration(
                      'المبلغ',
                      Icons.monetization_on,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _noteController,
                    decoration: _inputDecoration('الملاحظة', Icons.note_alt),
                  ),
                  const SizedBox(height: 20),
                  ActionButtonWidget(
                    iconPath: Icons.save,
                    title: 'تحديث',
                    onTap: _updateDebt,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      label: Text(
        label,
        style: KTextStyle.textStyle18.copyWith(color: AppColors.greyLight),
      ),
      suffixIcon: Icon(icon),
      fillColor: AppColors.white,
      filled: true,
      contentPadding: EdgeInsets.only(right: 10.w, bottom: 15.h),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.greyBorder),
        borderRadius: BorderRadius.circular(5.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.primary),
        borderRadius: BorderRadius.circular(5.0),
      ),
    );
  }
}
