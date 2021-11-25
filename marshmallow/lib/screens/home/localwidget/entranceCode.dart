import 'package:flutter/material.dart';
import 'package:marshmallow/widgets/button.dart';

Future _asyncInputDialog(BuildContext context) async {
  String teamName = '';
  return showDialog(
    context: context,
    barrierDismissible: false, // dialog is dismissible with a tap on the barrier
    builder: (context) {
      return AlertDialog(
        title: Text('Enter current team'),
        content: new Row(
          children: [
            new Expanded(
                child: new TextField(
              autofocus: true,
              decoration: new InputDecoration(
                  labelText: '입장코드', 
                  hintText: '네자리 숫자를 입력하세요'
                ),
              onChanged: (value) {
                teamName = value;
              },
            ))
          ],
        ),
        actions: [
          smallButtonTheme('들어가기', (){})
        ],
      );
    },
  );
}