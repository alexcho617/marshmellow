import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:marshmallow/screens/landing/landing.dart';
import 'package:marshmallow/utils/colors.dart';
import 'package:marshmallow/utils/text.dart';
import 'package:marshmallow/utils/utils.dart';
import 'package:marshmallow/widgets/button.dart';
import '../../services/firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/user.dart';
import 'localwidget/logoAndTitle.dart';
// import 'package:firebase_auth/firebase_auth.dart';

class WelcomePage extends StatelessWidget {
  
  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: yellow,
      body: SafeArea(
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Column(
              children: [
                logoAndTitle('WELCOME!'),
                SizedBox(height: 17),
                Text(
                  '마쉬멜로는 함께 즐기는 사물인식 게임입니다',
                  style: body2style(),
                ),
                SizedBox(height: size.height*0.2),
              ],
            ),
            Positioned(
              top: size.height*0.78,
              child: mediumButtonTheme('다음', () {
                Get.to(() => SettingPage());
              })
            ),
          ]
        ),
      ),
    );
  }
}

enum settingState { id, avatar }

List listAvatarImages = avatarRepository;
final _auth = FirebaseAuth.instance;

class SettingPage extends StatefulWidget {
  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  GameUser user = GameUser(globalToken: 0, localToken: 0, avatarIndex: 0);
  Random random = Random();
  TextEditingController _idController = TextEditingController();
  var currentState = settingState.id;
  int index = 0;

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: yellow,
        body: SafeArea(
          child: Center(
            child: currentState == settingState.id
              ? Stack(
              alignment: Alignment.topCenter,
              children: [
                Column(
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
                 
                  ],
                ),
                Positioned(
                  top: size.height*0.78,
                  child: mediumButtonTheme('다음', () {
                    Get.to(() => SettingPage());
                  })
                )   
              ],
              )
              : Stack(
              alignment: Alignment.topCenter,
              children: [
                Column(
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
                  ]
                ),
                Positioned(
                  top: size.height*0.78,
                  child: mediumButtonTheme('등록', () async {
                    await signInAnonymously();

                    if (_auth.currentUser == null) {
                      print("user is null");
                    } else {
                      user.uid = _auth.currentUser!.uid;
                      print('sign in confirm ${_auth.currentUser!.uid}');
                      await firestoreAddUser(user, user.uid);
                      Get.to(() => LandingPage(), arguments: user);
                    }
                  })
                )
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
          snackbar('중복체크', '사용 가능한 아이디입니다.');
          user.id = targetId;
          currentState = settingState.avatar;
        });
        print('$targetId AVAILABLE');
        user.id = targetId;
        currentState = settingState.avatar;
      } else {
        //id is not ok
        snackbar('중복체크', '이미 사용중인 아이디입니다.');

        print('$targetId TAKEN');
      }
    } else {
      print('EMPTY STRING');
    }
  }

  SnackbarController snackbar(String title, String message) {
    return Get.snackbar(
      title,
      message,
      icon: Icon(Icons.person, color: Colors.white),
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: blue,
      borderRadius: 20,
      margin: EdgeInsets.all(15),
      colorText: darkGrey,
      duration: Duration(seconds: 2),
      isDismissible: true,
      dismissDirection: DismissDirection.horizontal,
      forwardAnimationCurve: Curves.easeOutBack,
    );
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
