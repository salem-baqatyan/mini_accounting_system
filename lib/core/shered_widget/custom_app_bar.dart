import 'package:mini_accounting_system/core/styles/Colors.dart';
import 'package:mini_accounting_system/core/styles/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomAppBar extends StatelessWidget {
  final String tital;
  final bool? isBack;
  final bool? isOptionalButton;
  final IconData? optionalButtonIcon;
  final Color? optionalButtonColor;
  final void Function()? onBackTab;
  final void Function()? onOptionalButtonTab;

  const CustomAppBar({
    super.key,
    required this.tital,
    this.onBackTab,
    this.onOptionalButtonTab,
    this.isBack = true,
    this.isOptionalButton = false,
    this.optionalButtonIcon,
    this.optionalButtonColor,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.white,
      height: 75.h,
      width: double.infinity.w,
      child: Stack(
        children: [
          isBack == true
              ? Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: Container(
                    height: 40.h,
                    width: 40.w,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.greyBorder),
                      borderRadius: BorderRadius.circular(5.r),
                      color: AppColors.primaryBackground,
                    ),
                    child: InkWell(
                      onTap: onBackTab ?? () => Navigator.of(context).pop(),
                      child: Icon(Icons.arrow_back_ios_sharp, size: 25.w),
                    ),
                  ),
                ),
              )
              : const SizedBox.shrink(),
          Center(
            child: Text(
              tital,
              style: KTextStyle.textStyle20.copyWith(
                color: AppColors.blackDark,
              ),
            ),
          ),
          isOptionalButton == true
              ? Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 20),
                  child: InkWell(
                    onTap: onOptionalButtonTab,
                    child: Container(
                      height: 40.h,
                      width: 40.w,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.greyBorder),
                        borderRadius: BorderRadius.circular(5.r),
                        color:
                            optionalButtonColor ?? AppColors.primaryBackground,
                      ),
                      child: Icon(optionalButtonIcon, size: 25.w),
                    ),
                  ),
                ),
              )
              : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
