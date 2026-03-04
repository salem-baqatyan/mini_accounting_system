import 'package:mini_accounting_system/core/styles/Colors.dart';
import 'package:mini_accounting_system/core/styles/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfoHintFieldWidget extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool? isEnable;
  final Function(String)? onChanged;

  const InfoHintFieldWidget({
    super.key,
    required this.label,
    required this.controller,
    required this.keyboardType,
    this.isEnable = true,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: AbsorbPointer(
        absorbing: isEnable == true ? false : true,
        child: TextFormField(
          onChanged: onChanged,
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            label: Text(
              label,
              style: KTextStyle.textStyle12.copyWith(
                color: AppColors.greyLight,
              ),
            ),
            contentPadding: EdgeInsets.only(right: 10.w, bottom: 15.h),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.greyBorder, width: 1.0),
              borderRadius: BorderRadius.circular(5.0),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: AppColors.primary, width: 1.0),
              borderRadius: BorderRadius.circular(5.0),
            ),
          ),
        ),
      ),
    );
  }
}
