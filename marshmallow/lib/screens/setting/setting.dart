import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marshmallow/screens/landing/landing.dart';
import 'package:marshmallow/utils/colors.dart';
import 'package:marshmallow/utils/text.dart';
import 'package:marshmallow/utils/utils.dart';
import 'package:marshmallow/widgets/button.dart';
import '../../services/firebase.dart';
import '../../models/user.dart';
import 'localwidget/logoAndTitle.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: yellow,
      body: SafeArea(
        child: Column(children: [
          logoAndTitle('WELCOME!'),
          SizedBox(height: 17),
          Text(
            '마쉬멜로는 함께 즐기는 사물인식 게임입니다',
            style: body2style(),
          ),
          SizedBox(height: 226),
          mediumButtonTheme('다음', () {
            Get.to(() => SettingPage());
          })
        ]),
      ),
    );
  }
}

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
        backgroundColor: yellow,
        body: SafeArea(
            child: Center(
          child: currentState == settingState.id
              ? Column(
                  children: [
                    logoAndTitle('Nickname'),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(42, 10, 42, 32),
                      child: TextField(
                          controller: _idController,
                          decoration: InputDecoration(
                              hintText: "활동할 닉네임을 입력하세요.",
                              hintStyle: body1style())),
                    ),
                    smallButtonTheme("중복확인", performIdCheck),
                    SizedBox(height: 132),
                    mediumButtonTheme('다음', () {
                      Get.to(() => SettingPage());
                    })
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                      logoAndTitle('Character'),
                      Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 150,
                              height: 150,
                              child: CircleAvatar(
                                  radius: 60.0,
                                  backgroundColor: backgroundBlue,
                                  child: buildImage(context, index)),
                            ),
                            SizedBox(width: 30),
                            Column(
                              children: [
                                smallButtonTheme(
                                  '다시뽑기',
                                  () {
                                    setState(() {
                                      index = random.nextInt(9);
                                      user.avatarIndex = index;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ]),
                      SizedBox(height: 95),
                      mediumButtonTheme('등록', () async {
                        await firestoreAddUser(user);
                        Get.to(() => LandingPage(), arguments: user);
                      })
                    ]),
        )));
  }

  void performIdCheck() async {
    String targetId = _idController.text;
    if (targetId != '') {
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
    } else {
      print('EMPTY STRING');
    }
  }

  Container buildImage(BuildContext context, int index) {
    String image_name = listAvatarImages[index].toString();
    return Container(
        width: 113,
        height: 113,
        child: Image(
          image: AssetImage(image_name.toString()),
        ));
  }
}
