import 'package:deshi/core/constance/icons.dart';
import 'package:deshi/core/constance/textStyle.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget infoTile({required String icon, required String title}) {
  return Row(
    children: [
      Image.asset(icon, width: 30, height: 30),
      Text(
        title,
        style: TextConst.subheading.copyWith(color: Colors.white, fontSize: 13),
      ),
    ],
  );
}
