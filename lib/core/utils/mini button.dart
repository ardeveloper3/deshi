import 'package:deshi/core/constance/color_const.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget miniButton({
  required IconData icon,
  required VoidCallback onTap,
  required Color color,
  required Color iconColor,
  required bool isBorderEnable,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      margin: EdgeInsets.all(10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
        border: isBorderEnable
            ? Border.all(color: ColorConst.lightGreen)
            : null,
      ),
      child: Center(child: Icon(icon, color: iconColor)),
    ),
  );
}
