import 'package:flutter/material.dart';
import 'package:music_player/config/colors.dart';

final darkTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: bg_color,
  colorScheme: const ColorScheme.dark(
    surface: div_color,
    primary: primary_color,
    secondary: primary_color,
  ),
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.transparent,
    elevation: 0,
    iconTheme: IconThemeData(color: font_color),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(
      fontFamily: "Poppins",
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: font_color,
    ),
    bodyMedium: TextStyle(
      fontFamily: "Poppins",
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: font_color,
    ),
    bodySmall: TextStyle(
      fontFamily: "Poppins",
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: label_color,
    ),
    titleLarge: TextStyle(
      fontFamily: "Poppins",
      fontSize: 24,
      fontWeight: FontWeight.w700,
      color: font_color,
    ),
    titleMedium: TextStyle(
      fontFamily: "Poppins",
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: font_color,
    ),
    labelMedium: TextStyle(
      fontFamily: "Poppins",
      fontSize: 14,
      fontWeight: FontWeight.w600,
      color: label_color,
    ),
  ),
  sliderTheme: SliderThemeData(
    activeTrackColor: primary_color,
    inactiveTrackColor: label_color.withOpacity(0.35),
    thumbColor: primary_color,
  ),
  cardTheme: CardThemeData(
    color: div_color,
    elevation: 0,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
  ),
);
