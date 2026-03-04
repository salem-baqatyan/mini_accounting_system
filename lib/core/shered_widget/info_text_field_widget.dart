import 'package:mini_accounting_system/core/shered_widget/required_text.dart';
import 'package:mini_accounting_system/core/styles/Colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class InfoTextFieldWidget extends StatefulWidget {
  final String title;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final String Function(String value)? validator;
  final bool? isEnable;
  final bool? unRequired;

  const InfoTextFieldWidget({
    super.key,
    required this.title,
    required this.controller,
    required this.keyboardType,
    this.validator,
    this.isEnable = true,
    this.unRequired = false,
  });

  @override
  State<InfoTextFieldWidget> createState() => _InfoTextFieldWidgetState();
}

class _InfoTextFieldWidgetState extends State<InfoTextFieldWidget> {
  String? errorText;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        RequiredText(title: widget.title, unRequired: widget.unRequired),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            children: [
              AbsorbPointer(
                absorbing: widget.isEnable == true ? false : true,
                child: SizedBox(
                  height: 40.h,
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      if (!hasFocus && widget.validator != null) {
                        final validationResult = widget.validator!(
                          widget.controller.text,
                        );
                        setState(() {
                          errorText =
                              validationResult.isEmpty
                                  ? null
                                  : validationResult;
                        });
                      }
                    },
                    child: TextFormField(
                      controller: widget.controller,
                      keyboardType: widget.keyboardType,
                      textDirection: TextDirection.rtl,
                      decoration: InputDecoration(
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
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: AppColors.primary,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Text(
                errorText ?? '',
                style: TextStyle(color: Colors.red, fontSize: 10),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
