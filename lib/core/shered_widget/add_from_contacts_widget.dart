import 'package:mini_accounting_system/core/styles/Colors.dart';
import 'package:mini_accounting_system/core/styles/text_style.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AddFromContactsWidget extends StatelessWidget {
  final void Function() onTap;
  const AddFromContactsWidget({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: SizedBox(
        height: 90.h, // تصغير الحجم
        width: 90.w, // تصغير الحجم
        child: Card(
          // استخدام Card بدل DottedBorder
          elevation: 1.5, // ظل خفيف
          color: AppColors.backgroundColor, // لون خلفية الكارت
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r), // حواف دائرية
            side: BorderSide(
              color: AppColors.primary.withOpacity(0.3),
              width: 1.w,
            ), // حدود اختيارية
          ),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(8.r), // لمطابقة حواف الكارت
            child: Padding(
              // تقليل الـ padding قليلاً إذا لزم الأمر
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.contacts_outlined, // أيقونة أنسب
                    size: 40.sp, // تصغير الأيقونة
                    color: AppColors.primary, // استخدام لون الثيم
                  ),
                  SizedBox(height: 4.h), // مسافة صغيرة
                  Text(
                    'جهات الاتصال', // يمكن اختصار النص
                    textAlign: TextAlign.center,
                    style: KTextStyle.textStyle9.copyWith(
                      // قد تحتاج لتعديل حجم الخط
                      color: AppColors.blackDark,
                      fontSize: 10.sp, // مثال لتصغير الخط
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
