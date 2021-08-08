import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF04AFD3);
  static const Color secondaryColor = Color(0xFFA74CDF);
  static const Color tertiaryColor = Colors.white;

  static const Color primaryBG = Color(0xFF0D1117);
  static const Color cardBG = Color(0xFF1A1D29);
  static const Color inputBG = Color(0xFF1A1D29);
  static const Color appBarBG = Color(0xFF1A1D29);

  String primaryFontFamily = "Poppins";
  String secondaryFontFamily = "Roboto";

  static TextStyle get title1 => GoogleFonts.getFont(
    "IBM Plex Mono",
    color: const Color(0xFF04AFD3),
    fontWeight: FontWeight.w500,
    fontSize: 24,
    fontStyle: FontStyle.normal,
  );
  static TextStyle get title2 => GoogleFonts.getFont(
    "Roboto",
    color: Colors.white,
    fontWeight: FontWeight.w500,
    fontSize: 22,
  );
  static TextStyle get title3 => GoogleFonts.getFont(
    "Roboto",
    color: tertiaryColor,
    fontWeight: FontWeight.w500,
    fontSize: 18,
  );
  static TextStyle get subtitle1 => GoogleFonts.getFont(
    "Roboto Mono",
    color: tertiaryColor,
    fontWeight: FontWeight.w500,
    fontSize: 18,
  );
  static TextStyle get subtitle2 => GoogleFonts.getFont(
    "Roboto Mono",
    color: tertiaryColor,
    fontWeight: FontWeight.normal,
    fontSize: 15,
  );
  static TextStyle get bodyText1 => GoogleFonts.getFont(
    "Roboto",
    color: tertiaryColor,
    fontWeight: FontWeight.normal,
    fontSize: 14,
  );
  static TextStyle get bodyText2 => GoogleFonts.getFont(
    "Roboto",
    color: tertiaryColor,
    fontWeight: FontWeight.normal,
    fontSize: 12,
  );
}

extension TextStyleHelper on TextStyle {
  TextStyle override(
      {String fontFamily,
        Color color,
        double fontSize,
        FontWeight fontWeight,
        FontStyle fontStyle}) =>
      GoogleFonts.getFont(
        fontFamily ?? fontFamilyFallback[0],
        color: color ?? this.color,
        fontSize: fontSize ?? this.fontSize,
        fontWeight: fontWeight ?? this.fontWeight,
        fontStyle: fontStyle ?? this.fontStyle,
      );
}
