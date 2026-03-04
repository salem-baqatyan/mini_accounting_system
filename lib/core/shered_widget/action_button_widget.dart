import 'package:mini_accounting_system/core/styles/Colors.dart';
import 'package:mini_accounting_system/core/styles/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActionButtonWidget extends StatelessWidget {
  final IconData? iconPath;
  final String title;
  final bool? isSolid;
  final double? width;
  final double? height;
  final void Function()? onTap;
  const ActionButtonWidget({
    super.key,
    this.iconPath,
    required this.title,
    this.isSolid = true,
    this.onTap,
    this.width,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: height!.h,
        width: width ?? double.infinity,
        decoration:
            isSolid == true
                ? BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(5),
                )
                : BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: AppColors.primary),
                ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconPath != null
                ? Padding(
                  padding: EdgeInsets.only(left: 10.w),
                  child: Icon(
                    iconPath,
                    color:
                        isSolid == false ? AppColors.primary : AppColors.white,
                    size: 25.w,
                  ),
                )
                : SizedBox.shrink(),
            Text(
              title,
              style:
                  isSolid == true
                      ? KTextStyle.textStyle13.copyWith(color: AppColors.white)
                      : KTextStyle.textStyle12.copyWith(
                        color: AppColors.greyLight,
                      ),
            ),
          ],
        ),
      ),
    );
  }
}
