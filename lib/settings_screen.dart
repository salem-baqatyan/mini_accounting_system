import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:mini_accounting_system/core/function/delete_confirmation.dart';
import 'package:mini_accounting_system/core/shered_widget/action_button_widget.dart';
import 'package:mini_accounting_system/core/shered_widget/custom_app_bar.dart';
import 'package:mini_accounting_system/core/styles/Colors.dart';
import 'package:mini_accounting_system/core/styles/text_style.dart';
import 'package:mini_accounting_system/sqldb.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  List<Map> categories = [];
  final TextEditingController _categoryController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late SqlDb sqlDb;

  @override
  void initState() {
    super.initState();
    sqlDb = Provider.of<SqlDb>(context, listen: false);
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    final result = await sqlDb.readData("SELECT * FROM ExpenseCategories");
    setState(() {
      categories = result;
    });
  }

  Future<void> _addOrUpdateCategory({int? id}) async {
    final name = _categoryController.text.trim();
    if (name.isEmpty) return;

    if (id == null) {
      await sqlDb.insertData(
        "INSERT INTO ExpenseCategories (name) VALUES ('$name')",
      );
    } else {
      await sqlDb.updateData(
        "UPDATE ExpenseCategories SET name = '$name' WHERE id = $id",
      );
    }

    _categoryController.clear();
    Navigator.pop(context);
    _loadCategories();
  }

  Future<void> _showCategoryDialog({int? id, String? initialName}) async {
    _categoryController.text = initialName ?? '';
    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(id == null ? "إضافة نوع مصروف" : "تعديل نوع المصروف"),
            content: Form(
              key: _formKey,
              child: TextFormField(
                controller: _categoryController,
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
                            ? "أدخل اسم النوع"
                            : null,
              ),
            ),
            actions: [
              ActionButtonWidget(
                width: 75.w,
                title: 'الغاء',
                onTap: () {
                  _categoryController.clear();
                  Navigator.pop(context);
                },
                isSolid: false,
              ),
              ActionButtonWidget(
                width: 75.w,
                title: 'موافق',
                onTap: () async {
                  if (_formKey.currentState!.validate()) {
                    _addOrUpdateCategory(id: id);
                  }
                },
              ),
            ],
          ),
    );
  }

  Future<void> _deleteCategory(int id) async {
    final confirmed = await showDeleteConfirmationDialog(context: context);

    if (confirmed) {
      await sqlDb.deleteData("DELETE FROM ExpenseCategories WHERE id = $id");
      Navigator.pop(context);
      _loadCategories();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Container(
          color: AppColors.transparent,
          child: Column(
            children: [
              CustomAppBar(tital: 'الإعدادات', isBack: true),
              SizedBox(height: 10),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      const Text(
                        "📁 النسخ الاحتياطي",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ActionButtonWidget(
                        iconPath: Icons.backup,
                        title: "حفظ النسخة الاحتياطية",
                        onTap: () async {
                          await sqlDb.backupDatabase();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("✅ تم النسخ الاحتياطي"),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      ActionButtonWidget(
                        isSolid: false,
                        iconPath: Icons.restore,
                        title: "استعادة النسخة الاحتياطية",
                        onTap: () async {
                          await sqlDb.restoreDatabase();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("✅ تم الاستعادة")),
                          );
                          _loadCategories();
                        },
                      ),
                      const Divider(height: 40),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "🧾 أنواع المصروفات",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            onPressed: () => _showCategoryDialog(),
                            icon: const Icon(Icons.add, color: Colors.blue),
                          ),
                        ],
                      ),
                      ...categories.map((cat) {
                        return Card(
                          child: ListTile(
                            title: Text(cat['name']),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.orange,
                                  ),
                                  onPressed:
                                      () => _showCategoryDialog(
                                        id: cat['id'],
                                        initialName: cat['name'],
                                      ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _deleteCategory(cat['id']),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
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
