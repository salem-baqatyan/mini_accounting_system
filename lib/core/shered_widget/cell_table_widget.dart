import 'package:mini_accounting_system/core/styles/Colors.dart';
import 'package:mini_accounting_system/core/styles/text_style.dart';
import 'package:flutter/material.dart';

class CellTableWidget extends StatelessWidget {
  final String text;
  final bool? top;
  final bool? bottom;
  final bool? right;
  final bool? left;
  final bool? all;
  const CellTableWidget({
    super.key,
    required this.text,
    this.top = true,
    this.bottom = true,
    this.right = true,
    this.left = true,
    this.all = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 19.5),
      decoration: BoxDecoration(
        border:
            all == true
                ? Border(
                  top:
                      top == true
                          ? BorderSide()
                          : BorderSide(color: Colors.grey.shade100),
                  bottom:
                      bottom == true
                          ? BorderSide()
                          : BorderSide(color: Colors.grey.shade100),
                  right:
                      right == true
                          ? BorderSide()
                          : BorderSide(color: Colors.grey.shade100),
                  left:
                      left == true
                          ? BorderSide()
                          : BorderSide(color: Colors.grey.shade100),
                )
                : null,
      ),
      child: Text(
        text,
        style: KTextStyle.textStyle12.copyWith(color: AppColors.blackDark),
      ),
    );
  }
}
