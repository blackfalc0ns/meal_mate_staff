import 'package:flutter/material.dart';

import 'font_manager.dart';

TextStyle _getTextStyle(
  double fontSize,
  FontWeight fontWeight,
  String fontFamily,
  FontStyle fontStyle, {
  Color? color,
  double? height,
}) {
  return TextStyle(
    color: color,
    fontFamily: fontFamily,
    fontSize: fontSize,
    fontStyle: fontStyle,
    fontWeight: fontWeight,
    height: height,
  );
}

TextStyle getRegularStyle({
  double fontSize = FontSize.size12,
  Color? color,
  String fontFamily = FontConstant.alexandria,
  FontStyle? fontStyle,
  double? height,
}) {
  return _getTextStyle(
    fontSize,
    FontWeightManager.regular,
    fontFamily,
    fontStyle ?? FontStyle.normal,
    color: color,
    height: height,
  );
}

TextStyle getMediumStyle({
  double fontSize = FontSize.size12,
  Color? color,
  String fontFamily = FontConstant.alexandria,
  FontStyle? fontStyle,
  double? height,
}) {
  return _getTextStyle(
    fontSize,
    FontWeightManager.medium,
    fontFamily,
    fontStyle ?? FontStyle.normal,
    color: color,
    height: height,
  );
}

TextStyle getLightStyle({
  double fontSize = FontSize.size12,
  Color? color,
  String fontFamily = FontConstant.alexandria,
  FontStyle? fontStyle,
  double? height,
}) {
  return _getTextStyle(
    fontSize,
    FontWeightManager.light,
    fontFamily,
    fontStyle ?? FontStyle.normal,
    color: color,
    height: height,
  );
}

TextStyle getBoldStyle({
  double fontSize = FontSize.size12,
  Color? color,
  String fontFamily = FontConstant.alexandria,
  FontStyle? fontStyle,
  double? height,
}) {
  return _getTextStyle(
    fontSize,
    FontWeightManager.bold,
    fontFamily,
    fontStyle ?? FontStyle.normal,
    color: color,
    height: height,
  );
}

TextStyle getSemiBoldStyle({
  double fontSize = FontSize.size12,
  Color? color,
  String fontFamily = FontConstant.alexandria,
  FontStyle? fontStyle,
  double? height,
}) {
  return _getTextStyle(
    fontSize,
    FontWeightManager.semiBold,
    fontFamily,
    fontStyle ?? FontStyle.normal,
    color: color,
    height: height,
  );
}
