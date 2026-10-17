import 'dart:ui';

import 'package:flutter/src/painting/text_style.dart';
import 'package:google_fonts/google_fonts.dart';

class TextConst {
  static final TextStyle heading = GoogleFonts.notoSerifBengali(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle subheading = GoogleFonts.notoSerifBengali(
    fontSize: 18,
    fontWeight: FontWeight.w500,
  );

  static final TextStyle body = GoogleFonts.notoSerifBengali(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );
}
