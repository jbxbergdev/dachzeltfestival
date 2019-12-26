import 'package:flutter/material.dart';


final ColorScheme colorScheme = ColorScheme(
    primary: Color(0xFFF9847A),
    primaryVariant: Color(0xFFC2544E),
    secondary: Color(0xFF52C0E8),
    secondaryVariant: Color(0xFF0090b6),
    surface: Colors.white,
    background: Colors.white,
    error: Colors.red,
    onPrimary: Colors.black,
    onSecondary: Colors.black,
    onSurface: Colors.black,
    onBackground: Colors.black,
    onError: Colors.black,
    brightness: Brightness.light);

final ThemeData appTheme = ThemeData(
  colorScheme: colorScheme,
  primaryColor: colorScheme.primary,
  primaryColorBrightness: Brightness.light,
  splashColor: colorScheme.secondary.withOpacity(0.2),
  highlightColor: colorScheme.primary.withOpacity(0.2),
  accentColor: colorScheme.secondary,
  accentColorBrightness: Brightness.light,
  brightness: Brightness.light,
  appBarTheme: AppBarTheme(
    brightness: Brightness.light,
    color: colorScheme.background,
  ),
//  fontFamily: "AdventPro",
);
