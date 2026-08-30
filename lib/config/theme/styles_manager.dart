import 'package:flutter/material.dart';

import 'font_manager.dart';

TextStyle _getTextStyle(
  double fontSize,
  FontWeight fontWeight,
  String fontFamily,
  FontStyle fontStyle, [
  Color? color,
]) {
  return TextStyle(
    color: color,
    fontFamily: fontFamily,
    fontSize: fontSize,
    fontStyle: fontStyle,
    fontWeight: fontWeight,
  );
}

TextStyle getRegularStyle({
  double fontSize = FontSize.size12,
  Color? color,
  required String fontFamily,
  FontStyle? fontStyle,
}) {
  return _getTextStyle(
    fontSize,
    FontWeightManager.regular,
    fontFamily,
    fontStyle ?? FontStyle.normal,
    color,
  );
}

TextStyle getMediumStyle({
  double fontSize = FontSize.size12,
  Color? color,
  required String fontFamily,
  FontStyle? fontStyle,
}) {
  return _getTextStyle(
    fontSize,
    FontWeightManager.medium,
    fontFamily,
    fontStyle ?? FontStyle.normal,
    color,
  );
}

TextStyle getLightStyle({
  double fontSize = FontSize.size12,
  Color? color,
  required String fontFamily,
  FontStyle? fontStyle,
}) {
  return _getTextStyle(
    fontSize,
    FontWeightManager.light,
    fontFamily,
    fontStyle ?? FontStyle.normal,
    color,
  );
}

TextStyle getBoldStyle({
  double fontSize = FontSize.size12,
  Color? color,
  required String fontFamily,
  FontStyle? fontStyle,
}) {
  return _getTextStyle(
    fontSize,
    FontWeightManager.bold,
    fontFamily,
    fontStyle ?? FontStyle.normal,
    color,
  );
}

TextStyle getSemiBoldStyle({
  double fontSize = FontSize.size12,
  Color? color,
  required String fontFamily,
  FontStyle? fontStyle,
}) {
  return _getTextStyle(
    fontSize,
    FontWeightManager.semiBold,
    fontFamily,
    fontStyle ?? FontStyle.normal,
    color,
  );
}
