import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class InfoCard extends StatelessWidget {
  final String icon;
  final String title;
  final String shortText;

  const InfoCard({
    super.key,
    required this.icon,
    required this.title,
    required this.shortText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD8F3E5), width: 1),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF05DF72).withOpacity(0.08),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Image.asset(icon, width: 50, height: 50),

          const SizedBox(height: 7),

          // Title
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.notoSansBengali(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF075B3A),
            ),
          ),

          const SizedBox(height: 2),

          // Short Text
          Text(
            shortText,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.notoSansBengali(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF05A95B),
            ),
          ),
        ],
      ),
    );
  }
}
