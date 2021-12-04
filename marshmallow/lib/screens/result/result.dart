import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:marshmallow/models/user.dart';
import 'package:marshmallow/screens/home/home.dart';
import 'package:marshmallow/utils/colors.dart';
import 'package:get/get.dart';
import 'package:marshmallow/utils/text.dart';
import 'package:marshmallow/widgets/button.dart';

var _getArguments = Get.arguments;
var _currentPlayerUIDS = _getArguments;


class ResultPage extends StatefulWidget {
  @override
  _ResultPageState createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final firestore = FirebaseFirestore.instance;
 

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    print('line 26 ${_currentPlayerUIDS.length}');
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: backgroundBlue,
      appBar: AppBar(
        backgroundColor: backgroundBlue,
        elevation: 0,
        title: Image.asset('assets/logo.png', width: 95),
      ),
      body: SafeArea(
        
        child: Padding(
          padding: EdgeInsets.all(size.width*0.08),
          child: Column(
            children: [
              Image.asset('assets/result.png'),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: point2style(data:'game over!!',color: blue),
              ),
              Expanded(
                child: Container(
                  decoration:  BoxDecoration(
                    color: white.withOpacity(0.5),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.all( Radius.circular(15))
                    
                  ),
                  padding: EdgeInsets.all(15),
                  child: ListView(
                    //children: rankList,
                    //children: [Text('${_currentPlayerUIDS.length}'),]
                  ),
                ),
              ),
              SizedBox(height:20),
              Center(
                child: mediumButtonTheme('홈으로', () {
                  Get.off(HomePage());
                }),
              ),
     
            ],
          ),
        )
      
      )
    );
  }
}