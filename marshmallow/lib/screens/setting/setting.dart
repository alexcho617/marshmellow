import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../services/firebase.dart';

class SettingPage extends StatelessWidget {
  late TextEditingController _idController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Nickname'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _idController,
                  decoration: InputDecoration(hintText: "활동할 닉네임을 입력하세요."),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if(checkID(_idController.value.toString()) == true){
                    //id is ok
                  }else{
                    //id is not ok
                  }
                },
                child: Text("중복확인"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
