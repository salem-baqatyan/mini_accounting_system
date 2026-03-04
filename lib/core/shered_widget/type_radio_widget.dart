import 'package:mini_accounting_system/core/shered_widget/custom_radio_widget.dart';
import 'package:mini_accounting_system/core/shered_widget/section_title_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TypeRadioWidget extends StatelessWidget {
  final String? selectedOption;
  final void Function(String?)? onChangedOptometry;
  final void Function(String?)? onChangedPurchases;
  const TypeRadioWidget({
    super.key,
    required this.selectedOption,
    this.onChangedOptometry,
    this.onChangedPurchases,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitleWidget(title: 'طلب العميل'),
        SizedBox(height: 10.h),
        CustomRadioWidget(
          title: 'فحص نظر',
          value: 'Optometry',
          selectedOption: selectedOption,
          onChanged: onChangedOptometry,
        ),
        CustomRadioWidget(
          title: 'نظارة جديدة',
          value: 'Purchases',
          selectedOption: selectedOption,
          onChanged: onChangedPurchases,
        ),
      ],
    );
  }
}
