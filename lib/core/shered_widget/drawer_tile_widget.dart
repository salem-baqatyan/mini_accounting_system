import 'package:flutter/material.dart';
import 'package:mini_accounting_system/core/styles/Colors.dart';

class DrawerTile extends StatelessWidget {
  final String title;
  final Widget leading;
  final void Function()? ontap;

  const DrawerTile({
    Key? key,
    required this.title,
    required this.leading,
    required this.ontap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: TextStyle(color: AppColors.black)),
      leading: leading,
      onTap: ontap,
    );
  }
}
