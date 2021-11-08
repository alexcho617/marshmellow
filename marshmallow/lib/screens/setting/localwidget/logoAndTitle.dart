import 'package:flutter/material.dart';
import 'package:marshmallow/utils/text.dart';

Widget logoAndTitle (String text){
  return Center(
    child: Column(
      children: [
        SizedBox(height: 250),
        Image.asset('assets/m.png', width: 100),
        point1style(data: text),
      ],
    ),
  );
}