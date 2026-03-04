import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';

class SqlDb extends ChangeNotifier {
  static Database? _db;

  Future<Database?> get db async {
    if (_db == null) {
      _db = await intialDb();
      return _db;
    } else {
      return _db;
    }
  }

  Future<Database> intialDb() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'database.db');
    Database mydb = await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
    return mydb;
  }

  Future<void> _onCreate(Database db, int version) async {
    Batch batch = db.batch();
    batch.execute('''
CREATE TABLE "DailyIncomes" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
  "date" TEXT NOT NULL,
  "amount" REAL NOT NULL
)
''');

    batch.execute('''
CREATE TABLE "DailyExpenses" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
  "date" TEXT NOT NULL,
  "category_id" INTEGER NOT NULL,
  "amount" REAL NOT NULL,
  "note" TEXT,
  FOREIGN KEY("category_id") REFERENCES ExpenseCategories(id)
)
''');

    batch.execute('''
CREATE TABLE "Creditors" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
  "name" TEXT NOT NULL,
  "phone" TEXT,
  "total_debt" REAL NOT NULL DEFAULT 0,
  "paid_debt" REAL NOT NULL DEFAULT 0
)
''');

    batch.execute('''
CREATE TABLE "Debts" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
  "date" TEXT NOT NULL,
  "creditor_id" INTEGER NOT NULL,
  "amount" REAL NOT NULL,
  "note" TEXT,
  FOREIGN KEY("creditor_id") REFERENCES Creditors(id)
)
''');

    batch.execute('''
CREATE TABLE "ExpenseCategories" (
  "id" INTEGER PRIMARY KEY AUTOINCREMENT,
  "name" TEXT
)
  ''');
    await batch.commit();
    debugPrint('✅ Create Database and Tables Done');

    // 🔵 إضافة البيانات الافتراضية مباشرة بعد إنشاء الجداول
    await db.rawInsert('''
-- رسائل افتراضية
INSERT INTO ExpenseCategories (name)
VALUES 
("مصروفات عائلية"),
("مواد"),
("معدات"),
("ديون"),
("رواتب"),
("إيجار"),
("كهرباء")
  ''');
    debugPrint('✅ Insert default lenses into Lenses table');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {}

  Future<String> getDatabasePath() async {
    String databasePath = await getDatabasesPath();
    return join(databasePath, 'database.db');
  }

  Future<void> deleteMyDatabase() async {
    String databasePath = await getDatabasesPath();
    String path = join(databasePath, 'database.db');
    await deleteDatabase(path);
  }

  /// ✅ نسخ احتياطي إلى اي مجلد
  Future<void> backupDatabase() async {
    String dbPath = await getDatabasePath();
    File dbFile = File(dbPath);

    if (!await dbFile.exists()) {
      debugPrint('❌ قاعدة البيانات غير موجودة!');
      return;
    }

    String? backupDir = await FilePicker.platform.getDirectoryPath();
    if (backupDir != null) {
      final now = DateTime.now();
      final fileName =
          'backup_${now.year}-${now.month}-${now.day}_${now.hour}-${now.minute}-${now.second}.db';
      final backupPath = join(backupDir, fileName);

      // ✅ نسخ المحتوى يدويًا لتفادي مشاكل read-only
      final newFile = await File(backupPath).create();
      await newFile.writeAsBytes(await dbFile.readAsBytes());

      debugPrint('✅ تم النسخ الاحتياطي بنجاح إلى: $backupPath');
    } else {
      debugPrint('❌ تم إلغاء النسخ الاحتياطي');
    }
  }

  /// ✅ استعادة نسخة من ملف .db يحدده المستخدم
  Future<void> restoreDatabase() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any,
      );

      if (result != null && result.files.single.path != null) {
        String backupFilePath = result.files.single.path!;
        String dbPath = await getDatabasePath();
        File dbFile = File(dbPath);

        // حذف القاعدة القديمة
        if (await dbFile.exists()) {
          await dbFile.delete();
        }

        // ✅ نسخ المحتوى يدويًا لتفادي read-only
        final newDbFile = await File(dbPath).create();
        await newDbFile.writeAsBytes(await File(backupFilePath).readAsBytes());

        // ✅ إعادة فتح الاتصال بالقاعدة
        if (_db != null) {
          await _db!.close();
          _db = null;
        }
        _db = await openDatabase(dbPath);
        notifyListeners();

        print('✅ تم استعادة النسخة الاحتياطية بنجاح');
      } else {
        print('⚠️ لم يتم اختيار أي ملف');
      }
    } catch (e) {
      print('❌ خطأ أثناء استعادة النسخة الاحتياطية: $e');
    }
  }

  Future<dynamic> readData(String sql) async {
    Database? mydb = await db;
    List<Map> response = await mydb!.rawQuery(sql);
    notifyListeners();
    return response;
  }

  Future<dynamic> insertData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawInsert(sql);
    return response;
  }

  Future<dynamic> updateData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawUpdate(sql);
    return response;
  }

  Future<dynamic> deleteData(String sql) async {
    Database? mydb = await db;
    int response = await mydb!.rawDelete(sql);
    return response;
  }
}
