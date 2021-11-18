import 'package:flutter/material.dart';
import 'package:marshmallow/utils/text.dart';

Widget UserMArshInfo(int data){
  
  return Row(
    children: [
      Image.asset('assets/m.png', width: 30),
      SizedBox(width: 15),
      Text('$data', style: body5style(),)
    ],
  );
}