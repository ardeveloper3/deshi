import 'package:deshi/core/constance/color_const.dart';
import 'package:deshi/core/widgets/session_gate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'দেশি',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: ColorConst.scafoldColor,
          colorScheme: ColorScheme.fromSeed(
            seedColor: ColorConst.darkGreenColor,
            primary: ColorConst.darkGreenColor,
            secondary: ColorConst.lightGreen,
            surface: ColorConst.appBarColor,
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.notoSansBengaliTextTheme(),
          appBarTheme: AppBarTheme(
            backgroundColor: ColorConst.appBarColor,
            foregroundColor: ColorConst.darkGreenColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            centerTitle: false,
            titleTextStyle: GoogleFonts.notoSansBengali(
              color: ColorConst.darkGreenColor,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFDDE9E1)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(
                color: ColorConst.darkGreenColor,
                width: 1.5,
              ),
            ),
          ),
          cardTheme: CardThemeData(
            color: Colors.white,
            elevation: 0,
            margin: EdgeInsets.zero,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
        ),
        home: const SessionGate(),
      ),
    );
  }
}
