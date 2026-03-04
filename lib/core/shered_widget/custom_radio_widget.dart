import 'package:mini_accounting_system/core/styles/Colors.dart';
import 'package:mini_accounting_system/core/styles/text_style.dart';
import 'package:flutter/material.dart';

class CustomRadioWidget extends StatelessWidget {
  final String title;
  final String value;
  final String? selectedOption;
  final void Function(String? p1)? onChanged;

  const CustomRadioWidget({
    super.key,
    required this.title,
    required this.value,
    required this.selectedOption,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return RadioListTile<String>(
      title: Text(
        title,
        style: KTextStyle.textStyle13.copyWith(color: AppColors.greyLight),
      ),
      value: value,
      groupValue: selectedOption,
      onChanged: onChanged,
      activeColor: AppColors.primary,
      visualDensity: VisualDensity(horizontal: 0, vertical: -4),
    );
  }
}
