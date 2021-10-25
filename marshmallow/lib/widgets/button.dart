import 'package:flutter/material.dart';
import 'package:marshmallow/utils/text.dart';
import 'package:marshmallow/utils/colors.dart';



Widget smallButtonTheme(String text, VoidCallback? onpressed){
  return Container(
    width: 135.0,
    height: 40.0,
    child: OutlinedButton(
      child: Text(
        text, 
        style: buttonTextstyle()
      ),
      style: OutlinedButton.styleFrom (
        backgroundColor: blue,
        side: BorderSide(color: darkGrey),
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        ),
      ),
      onPressed: onpressed,
    )
  );
}

Widget mediumButtonTheme(String text, VoidCallback? onpressed){
  return Container(
    width: 175.0,
    height: 55.0,
    child: OutlinedButton(
      child: Text(
        text, 
        style: buttonTextstyle()
      ),
      style: OutlinedButton.styleFrom (
        backgroundColor: pink,
        side: BorderSide(color: darkGrey),
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(36.5),
        ),
      ),
      onPressed: onpressed,
    )
  );
}

Widget bigButtonTheme(String text, VoidCallback? onpressed){
  return Container(
    width: 300.0,
    height: 70.0,
    child: OutlinedButton(
      child: Text(
        text, 
        style: buttonTextstyle()
      ),
      style: OutlinedButton.styleFrom (
        backgroundColor: yellow,
        side: BorderSide(color: darkGrey),
        shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(35),
        ),
      ),
      onPressed: onpressed,
    )
  );
}