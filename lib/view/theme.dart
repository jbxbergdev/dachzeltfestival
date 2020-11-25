import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

@singleton
class AppTheme with WidgetsBindingObserver {

  AppTheme() {
    _platformBrightness = WidgetsBinding.instance.window.platformBrightness;
    WidgetsBinding.instance.addObserver(this);
  }

  Brightness _platformBrightness;

  final ColorScheme _lightColors = ColorScheme(
      brightness: Brightness.light, 
      primary: Color(0xFF61CE70),
      primaryVariant: Color(0xFF3D8720),
      secondary: Color(0xFFF9847A),
      secondaryVariant: Color(0xFFC2544E),
      surface: Colors.white,
      background: Colors.white,
      error: Colors.red,
      onPrimary: Colors.black,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onBackground: Colors.black,
      onError: Colors.black);
  
  final ColorScheme _darkColors = ColorScheme(
      brightness: Brightness.dark,
      primary: Color(0xFF61CE70),
      primaryVariant: Color(0xFF3D8720),
      secondary: Color(0xFFF9847A),
      secondaryVariant: Color(0xFFC2544E),
      surface: Colors.black,
      background: Colors.grey[850],
      error: Colors.red,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: Colors.white,
      onBackground: Colors.white,
      onError: Colors.white);
  
  ThemeData _themeData(ColorScheme colorScheme) => ThemeData(
    colorScheme: colorScheme,
    primaryColor: colorScheme.primary,
    splashColor: colorScheme.secondary.withOpacity(0.2),
    highlightColor: colorScheme.primary.withOpacity(0.2),
    accentColor: colorScheme.secondary,
    canvasColor: colorScheme.background,
    brightness: colorScheme.brightness,
    appBarTheme: AppBarTheme(
      color: colorScheme.background,
    ),
  );
  
  ThemeData get dark => _themeData(_darkColors);
  
  ThemeData get light => _themeData(_lightColors);

  ThemeData get current {
    switch(_platformBrightness) {
      case Brightness.dark:
        return dark;
      case Brightness.light:
        return light;
    }
    throw Exception();
  }

  @override
  void didChangePlatformBrightness() {
    _platformBrightness = WidgetsBinding.instance.window.platformBrightness;
  }

}