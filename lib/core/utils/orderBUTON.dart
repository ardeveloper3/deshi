import 'package:deshi/core/constance/color_const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constance/textStyle.dart';

class OrderButton extends StatelessWidget {
  final VoidCallback onTap;
  final String title;
  Color? color;
  OrderButton({
    super.key,
    required this.title,
    required this.onTap,
    this.color = ColorConst.darkGreenColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 46,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Center(
          child: Text(
            title,
            style: TextConst.heading.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
