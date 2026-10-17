import 'package:deshi/core/constance/color_const.dart';
import 'package:deshi/core/constance/textStyle.dart';
import 'package:flutter/material.dart';

class SellerProfile extends StatelessWidget {
  final String imageUrl;
  final String name;
  final String address;
  const SellerProfile({
    super.key,
    required this.imageUrl,
    required this.name,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(width: 0.6, color: ColorConst.lightGreen),
          ),
          child: ClipOval(
            child: imageUrl.isEmpty
                ? const Icon(Icons.person_outline, size: 36)
                : Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.person_outline, size: 36),
                  ),
          ),
        ),
        SizedBox(height: 10),
        Text(
          name.isEmpty ? 'নাম নেই' : name,
          style: TextConst.body.copyWith(color: ColorConst.darkGreenColor),
        ),
        const SizedBox(height: 3),
        Text(
          address.isEmpty ? 'ঠিকানা নেই' : address,
          style: TextStyle(color: ColorConst.muted, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
