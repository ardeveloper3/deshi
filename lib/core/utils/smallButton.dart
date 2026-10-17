import 'package:flutter/material.dart';

import '../constance/color_const.dart';
import '../constance/textStyle.dart';

class SmallButton extends StatelessWidget {
  final String title;
  Color? color;
  Color? textColor;
  final VoidCallback onTap;
  SmallButton({
    super.key,
    required this.title,
    this.color = ColorConst.lightGreen,
    this.textColor = Colors.black,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextConst.heading.copyWith(color: textColor),
        ),
      ),
    );
  }
}
