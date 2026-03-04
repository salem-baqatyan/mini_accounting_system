import 'package:mini_accounting_system/core/styles/Colors.dart';
import 'package:mini_accounting_system/core/styles/text_style.dart';
import 'package:flutter/material.dart';

class SectionTitleWidget extends StatelessWidget {
  final String title;
  final TextStyle? style;
  const SectionTitleWidget({super.key, required this.title, this.style});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style:
          style ?? KTextStyle.textStyle14.copyWith(color: AppColors.blackLight),
    );
  }
}
