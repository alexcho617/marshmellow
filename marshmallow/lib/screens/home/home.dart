import 'package:flutter/material.dart';
import 'package:marshmallow/utils/colors.dart';
import 'package:marshmallow/utils/text.dart';
import 'package:marshmallow/widgets/button.dart';

class HomePage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var size =MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: backgroundBlue,
      appBar: AppBar(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          point1style(data: 'hello' ),
          smallButtonTheme('small', (){}),
          mediumButtonTheme('medium',(){}),
          bigButtonTheme('big',(){})
        ],
      ),
    );
  }
}
