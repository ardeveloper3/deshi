import 'package:deshi/core/constance/color_const.dart';
import 'package:deshi/core/constance/textStyle.dart';
import 'package:flutter/material.dart';

class ProgressStep extends StatelessWidget {
  final List<int> completedSteps;

  const ProgressStep({super.key, this.completedSteps = const [0]});

  @override
  Widget build(BuildContext context) {
    const steps = ['পরিমাণ', 'ওজন', 'সময়', 'ডেলিভারি'];
    return Row(
      children: List.generate(steps.length, (index) {
        final number = index + 1;
        final completed = completedSteps.contains(number);
        return Expanded(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircleAvatar(
                    radius: 15,
                    backgroundColor: completed
                        ? ColorConst.darkGreenColor
                        : ColorConst.lightGreen.withAlpha(50),
                    child: Text(
                      completed ? '✓' : '$number',
                      style: TextConst.body.copyWith(
                        color: completed
                            ? Colors.white
                            : ColorConst.darkGreenColor,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Text(
                    steps[index],
                    style: TextConst.body.copyWith(
                      color: ColorConst.darkGreenColor,
                      fontSize: 9,
                    ),
                  ),
                ],
              ),
              if (index < steps.length - 1)
                Expanded(
                  child: Container(
                    height: 1,
                    color: completed
                        ? ColorConst.darkGreenColor
                        : ColorConst.lightGreen.withAlpha(50),
                  ),
                ),
            ],
          ),
        );
      }),
    );
  }
}
