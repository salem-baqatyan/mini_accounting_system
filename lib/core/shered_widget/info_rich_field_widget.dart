import 'package:mini_accounting_system/core/shered_widget/required_text.dart';
import 'package:mini_accounting_system/core/shered_widget/section_title_widget.dart';
import 'package:mini_accounting_system/core/styles/Colors.dart';
import 'package:mini_accounting_system/core/styles/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfoRichFieldWidget extends StatelessWidget {
  final TextInputType keybord;
  final TextDirection textDirection;
  final TextEditingController textController;
  final String text;
  final String labelText;
  final double width;
  final double height;
  final int? maxLines;
  final bool? isEnable;

  const InfoRichFieldWidget({
    this.keybord = TextInputType.multiline,
    this.textDirection = TextDirection.rtl,
    super.key,
    required this.textController,
    required this.text,
    this.labelText = "",
    this.width = 147.0,
    this.height = 40.0,
    this.maxLines,
    this.isEnable = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitleWidget(title: text, style: KTextStyle.textStyle18),
        SizedBox(height: 10.0.h),
        SizedBox(
          width: width.w,
          height: height.h,
          child: AbsorbPointer(
            absorbing: isEnable == true ? false : true,
            child: TextFormField(
              keyboardType: keybord,
              textDirection: textDirection,
              decoration: InputDecoration(
                hintText: 'أكتب هنا...',
                hintStyle: KTextStyle.textStyle12.copyWith(
                  color: AppColors.greyLight,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: AppColors.greyBorder,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: AppColors.primary,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.circular(5.0),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: AppColors.primaryBackground,
                    width: 1.w,
                  ),
                ),
              ),
              controller: textController,
              maxLines: maxLines,
            ),
          ),
        ),
      ],
    );
  }
}
