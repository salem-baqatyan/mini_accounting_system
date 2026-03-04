import 'package:flutter/material.dart';
import 'package:flutter_native_contact_picker/flutter_native_contact_picker.dart';
import 'package:flutter_native_contact_picker/model/contact.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mini_accounting_system/core/function/delete_confirmation.dart';
import 'package:mini_accounting_system/core/shered_widget/action_button_widget.dart';
import 'package:mini_accounting_system/core/shered_widget/custom_app_bar.dart';
import 'package:mini_accounting_system/core/styles/Colors.dart';
import 'package:mini_accounting_system/core/styles/text_style.dart';
import 'package:mini_accounting_system/features/daily_expenses_feature/daily_expenses_screen.dart';
import 'package:mini_accounting_system/features/debts_feature/creditors_details_screen.dart';
import 'package:mini_accounting_system/sqldb.dart';
import 'package:url_launcher/url_launcher.dart';

class CreditorsScreen extends StatefulWidget {
  const CreditorsScreen({super.key});

  @override
  State<CreditorsScreen> createState() => _CreditorsScreenState();
}

class _CreditorsScreenState extends State<CreditorsScreen> {
  final SqlDb _sqlDb = SqlDb();
  List<Map> _creditors = [];

  @override
  void initState() {
    super.initState();
    _loadCreditors();
  }

  Future<void> _loadCreditors() async {
    final result = await _sqlDb.readData('''
      SELECT 
        c.id,
        c.name,
        c.phone,
        IFNULL(SUM(d.amount), 0) AS total_debt,
        (
          SELECT IFNULL(SUM(e.amount), 0)
          FROM DailyExpenses e
          JOIN ExpenseCategories cat ON cat.id = e.category_id
          WHERE cat.name = 'ديون' AND e.note = c.name
        ) AS paid_amount
      FROM Creditors c
      LEFT JOIN Debts d ON d.creditor_id = c.id
      GROUP BY c.id
    ''');
    setState(() {
      _creditors = result;
    });
  }

  Future<void> _deleteCreditor(int id) async {
    final confirmed = await showDeleteConfirmationDialog(context: context);

    if (confirmed) {
      await _sqlDb.deleteData("DELETE FROM Creditors WHERE id = $id");
      await _sqlDb.deleteData("DELETE FROM Debts WHERE creditor_id = $id");
      Navigator.pop(context); // للعودة للخلف بعد الحذف
    }
  }

  Future<void> _showEditCreditorDialog(
    int creditorId,
    String currentName,
    String currentPhone,
  ) async {
    final TextEditingController _nameController = TextEditingController(
      text: currentName,
    );
    final TextEditingController _phoneController = TextEditingController(
      text: currentPhone,
    );
    final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل في اختيار جهة الاتصال: $e')),
        );
      }
    }

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
                    final newName = _nameController.text.trim();
                    final newPhone = _phoneController.text.trim();

                    await _sqlDb.updateData('''
    UPDATE Creditors
    SET name = "$newName", phone = "$newPhone"
    WHERE id = $creditorId
  ''');

                    await _sqlDb.updateData('''
    UPDATE DailyExpenses
    SET note = "$newName"
    WHERE category_id IN (
      SELECT id FROM ExpenseCategories WHERE name = 'ديون'
    ) AND note = "$currentName"
  ''');
                    Navigator.pop(context);
                    Navigator.pop(context);
                    setState(() {
                      _loadCreditors(); // إعادة تحميل البيانات
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("✅ تم تحديث معلومات الدائن"),
                      ),
                    );
                  }
                },
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddCreditorDialog,
          child: Icon(Icons.add),
        ),
        body: Container(
          color: AppColors.transparent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CustomAppBar(tital: 'الدائنون', isBack: true),
              SizedBox(height: 20.h),
              _creditors.isEmpty
                  ? const Center(child: Text('لا يوجد دائنون بعد...'))
                  : Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 10.h,
                      ),
                      child: ListView.builder(
                        itemCount: _creditors.length,
                        itemBuilder: (context, index) {
                          final creditor = _creditors[index];
                          final totalDebt = creditor['total_debt'] ?? 0;
                          final paid = creditor['paid_amount'] ?? 0;
                          final remaining = totalDebt - paid;

                          return InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => CreditorDetailsScreen(
                                        creditorId: creditor['id'],
                                        creditorName: creditor['name'],
                                        phone: creditor['phone'],
                                      ),
                                ),
                              ).then((_) => _loadCreditors());
                            },
                            child: Card(
                              elevation: 3,
                              margin: const EdgeInsets.symmetric(
                                vertical: 6,
                                horizontal: 4,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.all(12),
                                title: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "اسم الدائن: ${creditor['name']}",
                                            style: KTextStyle.textStyle16
                                                .copyWith(
                                                  color: AppColors.blackDark,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          Text(
                                            "رقم الجوال: ${creditor['phone']}",
                                            style: KTextStyle.textStyle16
                                                .copyWith(
                                                  color: AppColors.blackDark,
                                                ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            size: 20,
                                          ),
                                          tooltip: 'تعديل',
                                          onPressed: () async {
                                            await _showEditCreditorDialog(
                                              creditor['id'],
                                              creditor['name'],
                                              creditor['phone'],
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed:
                                              () => _deleteCreditor(
                                                creditor['id'],
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                subtitle: SizedBox(
                                  width: double.infinity,
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(
                                            "💳 إجمالي الدين: ${totalDebt == 0 ? 'لا يوجد دين بعد' : totalDebt.toStringAsFixed(0) + ' ر.ي'}",
                                          ),
                                          Text(
                                            "💵 المدفوع: ${totalDebt == 0
                                                ? 'لا يوجد دين بعد'
                                                : paid == 0
                                                ? 'لم يتم التسديد بعد'
                                                : paid.toStringAsFixed(0) + ' ر.ي'}",
                                          ),
                                          Text(
                                            "📉 المتبقي: ${totalDebt == 0
                                                ? 'لا يوجد دين بعد'
                                                : remaining == 0
                                                ? 'تم التسديد الدين'
                                                : remaining.toStringAsFixed(0) + ' ر.ي'}",
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          ElevatedButton.icon(
                                            onPressed: () {
                                              final Uri launchUri = Uri(
                                                scheme: 'tel',
                                                path: creditor['phone'],
                                              );
                                              launchUrl(launchUri);
                                            },
                                            icon: const Icon(Icons.call),
                                            label: const Text('اتصال'),
                                          ),
                                          ElevatedButton.icon(
                                            onPressed:
                                                totalDebt == 0
                                                    ? null
                                                    : () {
                                                      final today =
                                                          DateTime.now();
                                                      final todayFormatted =
                                                          "${today.year}/${today.month}/${today.day}";
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder:
                                                              (
                                                                _,
                                                              ) => DailyExpensesScreen(
                                                                prefill: {
                                                                  'category':
                                                                      'ديون',
                                                                  'creditorid':
                                                                      creditor['id'],
                                                                  'note':
                                                                      creditor['name'],
                                                                  'date':
                                                                      todayFormatted,
                                                                },
                                                              ),
                                                        ),
                                                      ).then(
                                                        (_) => _loadCreditors(),
                                                      );
                                                    },
                                            icon: const Icon(
                                              Icons.monetization_on,
                                            ),
                                            label: const Text('تسديد'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
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
                    print(id);
                    _loadCreditors();
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
