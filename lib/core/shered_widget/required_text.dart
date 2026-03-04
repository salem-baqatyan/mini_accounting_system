import 'package:mini_accounting_system/core/styles/Colors.dart';
import 'package:mini_accounting_system/core/styles/text_style.dart';
import 'package:flutter/material.dart';

class RequiredText extends StatelessWidget {
  final String title;
  final bool? unRequired;
  const RequiredText({super.key, required this.title, this.unRequired = false});

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        text: title,
        style: KTextStyle.textStyle13.copyWith(color: AppColors.greyLight),
        children: <TextSpan>[
          unRequired == true
              ? TextSpan()
              : TextSpan(
                text: ' *',
                style: KTextStyle.textStyle13.copyWith(
                  color: AppColors.primary,
                ),
              ),
        ],
      ),
    );
  }
}
