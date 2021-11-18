import 'package:flutter/material.dart';
import 'package:marshmallow/utils/colors.dart';
import 'package:bordered_text/bordered_text.dart';

Widget point1style({required String data, double? height, Color? color: blue, double? opacity:1.0}) {
  return BorderedText(
    strokeWidth: 2.0,
    strokeColor: darkGrey,
    child: Text(
      data,
      style: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w400,
        fontFamily: 'Point',
        color: color!.withOpacity(opacity!),
        height: height,
      )
    )
  );
}

Widget point2style({required String data, double? height, Color? color: pink, double? opacity:1.0}) {
  return BorderedText(
    strokeWidth: 2.0,
    strokeColor: darkGrey,
    child: Text(
      data,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        fontFamily: 'Point',
        color: color!.withOpacity(opacity!),
        height: height,
      )
    )
  );
}

TextStyle buttonTextstyle({double? height, Color? color: darkGrey, double? opacity:1.0}) {
  return TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    fontFamily: 'Main',
    color: color!.withOpacity(opacity!),
    height: height,
  );
}

TextStyle head1style({double? height, Color? color: darkGrey, double? opacity:1.0}) {
  return TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w800,
    fontFamily: 'Main',
    color: color!.withOpacity(opacity!),
    height: height,
  );
}

TextStyle body1style({double? height, Color? color: darkGrey, double? opacity:1.0}) {
  return TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w400,
    fontFamily: 'Main',
    color: color!.withOpacity(opacity!),
    height: height,
  );
}

TextStyle body2style({double? height, Color? color: darkGrey, double? opacity:1.0}) {
  return TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    fontFamily: 'Main',
    color: color!.withOpacity(opacity!),
    height: height,
  );
}

TextStyle body3style({double? height, Color? color: darkGrey, double? opacity:1.0}) {
  return TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    fontFamily: 'Main',
    color: color!.withOpacity(opacity!),
    height: height,
  );
}

TextStyle body4style({double? height, Color? color: darkGrey, double? opacity:1.0}) {
  return TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    fontFamily: 'Main',
    color: color!.withOpacity(opacity!),
    height: height,
  );
}


TextStyle body5style({double? height, Color? color: darkGrey, double? opacity:1.0}) {
  return TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    fontFamily: 'Main',
    color: color!.withOpacity(opacity!),
    height: height,
  );
}


TextStyle body6style({double? height, Color? color: darkGrey, double? opacity:1.0}) {
  return TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.w400,
    fontFamily: 'Main',
    color: color!.withOpacity(opacity!),
    height: height,
  );
}

TextStyle cautionstyle({double? height, Color? color: caution, double? opacity:1.0}) {
  return TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.bold,
    fontFamily: 'Main',
    color: color!.withOpacity(opacity!),
    height: height,
  );
}