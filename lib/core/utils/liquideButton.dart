import 'package:deshi/core/constance/textStyle.dart';
import 'package:flutter/material.dart';

class LiquidButton extends StatelessWidget {
  final String title;
  Color? color = Colors.white;
  LiquidButton({super.key, required this.title, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsetsGeometry.symmetric(vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.45),
            Colors.white.withOpacity(0.18),
            Colors.white.withOpacity(0.08),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.60)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),

            spreadRadius: 1,
            blurRadius: 12,
            offset: Offset(0, 4), // changes position of shadow
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 2,
            left: 8,
            right: 9,
            child: Container(
              height: 10,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: Colors.white.withAlpha(30),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsetsGeometry.symmetric(horizontal: 10, vertical: 13),
            child: Text(
              title,
              style: TextConst.body.copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
