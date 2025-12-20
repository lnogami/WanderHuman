import 'package:flutter/material.dart';
import 'package:wanderhuman_app/utilities/properties/color_palette.dart';

class MyTextFormatter {
  static Text h1({
    required String text,
    Color color = MyColorPalette.titleTextColor,
    double fontsize = (kDefaultFontSize + 7),
    FontStyle fontStyle = FontStyle.normal,
    FontWeight fontWeight = FontWeight.w700,
  }) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: fontsize,
        fontStyle: fontStyle,
        fontWeight: fontWeight,
        color: color,
      ),
    );
  }

  static Text h3({
    required String text,
    Color color = MyColorPalette.subtitleTextColor,
    double fontsize = (kDefaultFontSize + 4),
    FontStyle fontStyle = FontStyle.normal,
    FontWeight fontWeight = FontWeight.w600,
  }) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: fontsize,
        fontStyle: fontStyle,
        // fontWeight: FontWeight.w600,
        color: color,
        fontWeight: fontWeight,
      ),
    );
  }

  static Text h5({
    required String text,
    Color color = MyColorPalette.subtitleTextColor,
    double fontsize = (kDefaultFontSize + 1.5),
    FontStyle fontStyle = FontStyle.normal,
    FontWeight fontWeight = FontWeight.w500,
  }) {
    return Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: fontsize,
        fontStyle: fontStyle,
        // fontWeight: FontWeight.w600,
        color: color,
      ),
    );
  }

  static Text p({
    required String text,
    Color? color,
    double fontsize = kDefaultFontSize,
    FontStyle fontStyle = FontStyle.normal,
    int maxLines = 1,
    // FontWeight fontWeight = FontWeight.w600,
  }) {
    return Text(
      text,
      maxLines: maxLines,
      overflow: (maxLines > 1) ? TextOverflow.clip : TextOverflow.ellipsis,
      softWrap: (maxLines > 1) ? true : false,
      style: TextStyle(
        fontSize: fontsize,
        fontStyle: fontStyle,
        // fontWeight: FontWeight.w600,
        color: color ?? Colors.black87,
      ),
    );
  }
}
