import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marshmallow/utils/utils.dart';
import '../../services/firebase.dart';
import '../../models/user.dart';

enum settingState { id, avatar }

List listAvatarImages = avatarRepository;

class SettingPage extends StatefulWidget {
  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  User user = User(globalToken: 0, localToken: 0, avatarIndex: 0);
  Random random = Random();
  TextEditingController _idController = TextEditingController();
  var currentState = settingState.id;
  int index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
            child: currentState == settingState.id
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Nickname'),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: TextField(
                          controller: _idController,
                          decoration:
                              InputDecoration(hintText: "활동할 닉네임을 입력하세요."),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: performIdCheck,
                        child: Text("중복확인"),
                      )
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircleAvatar(
                        radius: 60.0,
                        backgroundImage: buildImage(context, index),
                      ),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('${user.avatarIndex.toString()}'),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  index = random.nextInt(9);
                                  user.avatarIndex = index;
                                });
                              },
                              child: Text('다시뽑기'),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                          onPressed: performUserRegistration, child: Text('등록'))
                    ],
                  )),
      ),
    );
  }

  void performUserRegistration() async {
    await firestoreAddUser(user);
  }

  void performIdCheck() async {
    String targetId = _idController.text;
    if (await firestoreTestId(targetId) == true) {
      //id is ok
      setState(() {
        print('$targetId AVAILABLE');
        user.id = targetId;
        currentState = settingState.avatar;
      });
      print('$targetId AVAILABLE');
      user.id = targetId;
      currentState = settingState.avatar;
    } else {
      //id is not ok
      print('$targetId TAKEN');
    }
  }

  AssetImage buildImage(BuildContext context, int index) {
    String image_name = listAvatarImages[index].toString();
    return AssetImage(image_name.toString());
  }
}
