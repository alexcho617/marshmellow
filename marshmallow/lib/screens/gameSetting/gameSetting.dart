import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marshmallow/utils/colors.dart';
import 'package:marshmallow/utils/text.dart';
import 'package:marshmallow/widgets/button.dart';
import 'package:marshmallow/widgets/userMarshInfo.dart';

class GameSettingPage extends StatefulWidget {
  @override
  State<GameSettingPage> createState() => _GameSettingPageState();
}

class _GameSettingPageState extends State<GameSettingPage> {
  final List<String> _dropdownValues = ["3", "4", "5", "6", "7"];
  var _currentlySelected;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: backgroundBlue,
        appBar: AppBar(
          backgroundColor: backgroundBlue,
          elevation: 0,
          title: Image.asset('assets/logo.png', width: 95),
        ),
        body: Container(
          padding: EdgeInsets.symmetric(horizontal: 34),
          child: Column(
            children: [
              SizedBox(height: 90),
              Container(
                  width: 346,
                  decoration: new BoxDecoration(
                      color: yellow,
                      border: Border.all(color: darkGrey),
                      borderRadius: new BorderRadius.only(
                        topLeft: const Radius.circular(30.0),
                        topRight: const Radius.circular(30.0),
                      )),
                  child: Column(
                    children: [
                      SizedBox(height: 20),
                      Image.asset(
                        'assets/m.png',
                        width: 41,
                      ),
                      SizedBox(height: 5),
                      Text(
                        'RANDOM KEYWORDS',
                        style: body3style(),
                      ),
                      SizedBox(height: 10),
                      Container(
                        width: 326,
                        height: 229,
                        decoration: new BoxDecoration(
                          color: white.withOpacity(0.6),
                          border: Border.all(color: darkGrey),
                        ),
                      ),
                      TextButton(
                          onPressed: () {},
                          child: Text(
                            '🔄 다시 뽑기',
                            style: body3style(),
                          ))
                    ],
                  )),
              SizedBox(height: 15),
              Container(
                width: 346,
                height: 59,
                decoration: new BoxDecoration(
                  color: yellow,
                  border: Border.all(color: darkGrey),
                ),
                child:
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    '인원 선택',
                    style: body3style(),
                  ),
                  SizedBox(
                    width: 35,
                  ),
                  Container(
                    width: 91,
                    height: 35,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                          color: darkGrey, style: BorderStyle.solid, width: 1),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton(
                        value: _currentlySelected,
                        hint: Text(
                          '3',
                          style: body3style(),
                        ),
                        items: _dropdownValues
                            .map((value) => DropdownMenuItem(
                                  child: Padding(
                                    padding: EdgeInsets.only(right: 10),
                                    child: Text(value),
                                  ),
                                  value: value,
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _currentlySelected = value;
                            print(_currentlySelected);
                          });
                        },
                        isExpanded: false,
                        style: body3style(),
                      ),
                    ),
                  ),
                  SizedBox(width: 20),
                  Text(
                    '명',
                    style: body3style(),
                  )
                ]),
              ),
              // SizedBox(height:R109),
              mediumButtonTheme('방 만들기', () {
                //go to game zone
              })
            ],
          ),
        ));
  }
}
