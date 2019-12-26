import 'dart:ui';

import 'package:flutter/material.dart';

Color hexToColor(String code) {
  if (code == null) {
    return Colors.transparent;
  }
  return new Color(int.parse(code.substring(1, 7), radix: 16) + 0xFF000000);
}

bool isNotNullOrEmpty(String string) => string?.isNotEmpty == true;