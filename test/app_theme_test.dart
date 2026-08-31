import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meal_mate_delivery/config/theme/app_theme.dart';

void main() {
  test('keeps app bar flat when scrollable content passes under it', () {
    final appBarTheme = AppTheme.lightTheme.appBarTheme;

    expect(appBarTheme.elevation, 0);
    expect(appBarTheme.scrolledUnderElevation, 0);
    expect(appBarTheme.surfaceTintColor, Colors.transparent);
    expect(appBarTheme.shadowColor, Colors.transparent);
  });
}
