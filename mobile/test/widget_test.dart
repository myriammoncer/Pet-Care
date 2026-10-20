import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:petcare/core/theme/app_theme.dart';

void main() {
  test('Les thèmes clair et sombre se construisent', () {
    expect(AppTheme.light, isA<ThemeData>());
    expect(AppTheme.dark, isA<ThemeData>());
    expect(AppTheme.light.brightness, Brightness.light);
    expect(AppTheme.dark.brightness, Brightness.dark);
  });
}
